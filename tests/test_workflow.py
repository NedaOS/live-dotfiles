"""Isolated application: never use the real home, user bus, or Git index."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]
GENERATED = ['.config/kitty/themes/noctalia.conf', '.config/fish/noctalia-prompt-colors.fish',
             '.config/hypr/config/colors.lua', '.config/fish/fish_variables',
             '.config/noctalia/greeter-sync.toml', '.local/state/noctalia/settings.toml']

class WorkflowTests(unittest.TestCase):
    def test_isolated_apply_and_review_are_idempotent(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            home = root / 'home'
            home.mkdir()
            source = root / 'source'
            shutil.copytree(SOURCE, source, ignore=shutil.ignore_patterns(
                '.git', 'Pictures', '*.png', '*.jpg', '*.ttf', '__pycache__'))
            binary = root / 'bin'
            binary.mkdir()
            # No live systemd operations even when the tests run as the desktop user.
            (binary / 'systemctl').write_text('#!/bin/sh\nexit 1\n')
            (binary / 'systemctl').chmod(0o755)
            env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / '.config'),
                       XDG_CACHE_HOME=str(root / 'cache'), XDG_DATA_HOME=str(home / '.local/share'),
                       PATH=str(binary) + ':' + os.environ['PATH'])
            config = root / 'chezmoi.toml'
            config.write_text('[git]\nautoadd = false\nautocommit = false\nautopush = false\n')
            command = ['chezmoi', '--config', str(config), '--source', str(source),
                       '--destination', str(home), '--persistent-state', str(root / 'state.boltdb'),
                       '--no-tty']
            def run(*args):
                return subprocess.run([*command, *args], env=env, check=True,
                                      capture_output=True, text=True)
            subprocess.run(['git', 'init', '-q', str(source)], check=True)
            def git_status():
                return subprocess.check_output(['git', '-C', str(source), 'status', '--porcelain'])
            before = git_status()
            wants = home / '.config/systemd/user/default.target.wants/chezmoi-auto-sync.service'
            wants.parent.mkdir(parents=True)
            wants.symlink_to('../chezmoi-auto-sync.service')
            run('apply')
            for target in GENERATED:
                self.assertFalse((home / target).exists())
            self.assertIn('pcall(require, "config.colors")',
                          (home / '.config/hypr/config/appearance.lua').read_text())
            secret = home / '.config/test-app/token'
            secret.parent.mkdir(parents=True)
            secret.write_text('disposable-test-token')
            for target in GENERATED:
                path = home / target
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('mutable sentinel\n')
            for _ in range(2):
                run('apply')
                for target in GENERATED:
                    self.assertEqual((home / target).read_text(), 'mutable sentinel\n')
                self.assertFalse(wants.is_symlink())
                self.assertEqual(git_status(), before)
                self.assertFalse((source / '.git/index').exists())
                self.assertFalse((source / '.git/refs/heads/master').exists())
            self.assertEqual((home / '.config/systemd/user/chezmoi-auto-sync.service').readlink(), Path('/dev/null'))
            fish = (home / '.config/fish/config.fish').read_text()
            self.assertIn(str(home) + '/.kilo/bin', fish)
            self.assertNotIn('/home/nedamani', fish)
            auto = (home / '.config/hypr/config/autostart.lua').read_text()
            self.assertIn('/usr/bin/kdeconnectd', auto)
            self.assertIn('/scripts/start-noctalia.sh', auto)
            # Review a modification and deletion: source must remain untouched.
            (home / '.config/hypr/config/input.lua').unlink()
            (home / '.config/kitty/kitty.conf').write_text('intentional local edit\n')
            status = run('status').stdout
            self.assertIn('input.lua', status)
            self.assertIn('kitty.conf', status)
            self.assertTrue((source / 'dot_config/hypr/config/input.lua').exists())
            self.assertEqual(git_status(), before)
            # Compatibility command delegates only to status and rejects push.
            (binary / 'chezmoi').write_text('#!/bin/sh\n[ "$*" = status ]\n')
            (binary / 'chezmoi').chmod(0o755)
            script = home / '.local/bin/chezmoi-auto-sync'
            subprocess.run([str(script)], env=env, check=True)
            self.assertEqual(subprocess.run([str(script), 'push'], env=env,
                             capture_output=True).returncode, 2)
            self.assertEqual(git_status(), before)

    def test_preflight_greetd_and_sddm_absence(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            binary = root / 'bin'
            binary.mkdir()
            alias = root / 'display-manager.service'
            alias.symlink_to('greetd.service')
            script = (SOURCE / 'dot_config/hypr/scripts/executable_preflight.sh').read_text()
            script = script.replace('/etc/systemd/system/display-manager.service', str(alias))
            for path in ['/usr/bin/noctalia-greeter-session', '/usr/local/bin/hyprland-quiet-session']:
                target = root / Path(path).name
                target.write_text('#!/bin/sh\n')
                target.chmod(0o755)
                script = script.replace(path, str(target))
            commands = {
                'hyprland': 'echo "Hyprland 0.56.0"',
                'systemctl': 'case "$1" in is-enabled) echo enabled;; get-default) echo graphical.target;; esac',
                'noctalia-greeter': 'echo "Hyprland (Quiet)"',
                'rpm': 'exit "${TEST_RPM_STATUS:-1}"',
                'pgrep': '[ "$1" = -cx ] && { echo 1; exit 0; }; exit 1',
                'xdg-settings': 'echo browser.desktop',
            }
            for name in ['noctalia', 'kitty', 'yazi', 'xdg-open', 'pactl', 'wofi', 'obsidian']:
                commands[name] = 'exit 0'
            for name, body in commands.items():
                path = binary / name
                path.write_text('#!/bin/sh\n' + body + '\n')
                path.chmod(0o755)
            path = root / 'preflight.sh'
            path.write_text(script)
            env = dict(os.environ, PATH=str(binary) + ':' + os.environ['PATH'])
            result = subprocess.run(['sh', str(path)], env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            env['TEST_RPM_STATUS'] = '0'
            self.assertNotEqual(subprocess.run(['sh', str(path)], env=env,
                                capture_output=True).returncode, 0)
            alias.unlink()
            alias.symlink_to('other.service')
            env['TEST_RPM_STATUS'] = '1'
            self.assertNotEqual(subprocess.run(['sh', str(path)], env=env,
                                capture_output=True).returncode, 0)

    def test_no_automatic_capture_or_git_writes(self):
        script = (SOURCE / 'dot_local/bin/executable_chezmoi-auto-sync').read_text()
        for forbidden in ['git ', 're-add', 'forget', ' push', ' commit', ' add ']:
            self.assertNotIn(forbidden, script)
        self.assertIn('exec chezmoi status', script)
        self.assertIn('shell', (SOURCE / 'dot_config/noctalia/config.toml').read_text())
        self.assertIn('fish_prompt_colors', (SOURCE / 'dot_config/noctalia/templates.toml').read_text())
        self.assertIn('hyprland_lua_colors', (SOURCE / 'dot_config/noctalia/hyprland-colors.toml').read_text())
        self.assertIn('uwsm app -- noctalia', (SOURCE / 'dot_config/hypr/scripts/executable_start-noctalia.sh').read_text())

if __name__ == '__main__':
    unittest.main()
