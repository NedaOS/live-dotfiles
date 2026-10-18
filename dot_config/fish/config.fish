## Set values
# Hide welcome message & ensure we are reporting fish as shell
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT 1
set -x SHELL /usr/bin/fish

# Use bat for man pages
set -xU MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -xU MANROFFOPT -c

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end

## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ]

    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

# Nvim command
function nvim
    env NVIM_APPNAME=nvim-ryoku command nvim $argv
end

# Yazi command
function yazi
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi --cwd-file="$tmp" $argv
    if test -f "$tmp"
        set cwd (cat "$tmp")
        if test -n "$cwd" -a -d "$cwd"
            cd "$cwd"
        end
    end
    rm -f "$tmp"
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

## Useful aliases
# Replace ls with eza
alias ls 'eza -al --group-directories-first --icons=always' # preferred listing
alias lsz 'eza -al --total-size --group-directories-first --icons=always' # include file size
alias la 'eza -a --group-directories-first --icons=always' # all files and dirs
alias ll 'eza -l --group-directories-first --icons=always' # long format
alias lt 'eza -aT --group-directories-first --icons=always' # tree listing
alias l. 'eza -ald --group-directories-first .* --icons=always' # show only dotfiles

# Replace some more things with better alternatives
alias cat 'bat --style header,snip,changes'

# Common use
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias dir 'dir --color=auto'
alias grep 'ugrep --color=auto'
alias egrep 'ugrep -E --color=auto'
alias fgrep 'ugrep -F --color=auto'
alias hw 'hwinfo --short'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias vdir 'vdir --color=auto'
alias wget 'wget -c '

# Get the error messages from journalctl
alias jctl 'journalctl -p 3 -xb'

# kilo
fish_add_path /home/nedamani/.kilo/bin


# Added by Antigravity CLI installer
set -gx PATH "/home/nedamani/.local/bin" $PATH
