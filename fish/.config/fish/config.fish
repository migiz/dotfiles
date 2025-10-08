set -U fish_greeting

# PATH setup (porting from Omarchy bash configuration)
# Add local binaries to PATH if not already present
if not contains "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

# Add Cargo binaries to PATH if not already present
if not contains "$HOME/.cargo/bin" $PATH
    set -gx PATH "$HOME/.cargo/bin" $PATH
end

# Git abbreviations
abbr gco 'git checkout'
abbr gcob 'git checkout -b'
abbr gcod 'git checkout develop'
abbr gcom 'git checkout main'
abbr gr 'git rebase'
abbr grc 'git rebase --continue'
abbr grea 'git restore .'
abbr gres 'git restore --staged .'
abbr gpf 'git push --force'
abbr lg lazygit
abbr ld lazydocker
abbr gd 'git diff | bat --color always'
abbr gs 'git status'
abbr ga 'git add'
abbr gp 'git push'
abbr gpu 'git push -u origin (git branch --show-current)'
abbr gca 'git commit --amend'
abbr gcm 'git commit -m'
abbr gpr 'git pull --rebase'
abbr gl 'git log | bat --color always'
abbr gaa 'git add .'
abbr gdc 'git diff --cached | bat --color always'
abbr n nvim
abbr nv neovide

# Go test abbreviations
abbr tt 'gotestsum --format testname'
abbr ts gotestsum

# Utility abbreviations
abbr c 'clear -x'

# File system abbreviations
abbr l 'eza -lha --group-directories-first --icons=auto --git'
abbr ll 'eza -ah --icons --group-directories-first'
abbr lt 'eza --tree --level=2 --long --icons --git'
abbr lta 'eza --tree --level=2 --long --icons --git -a'
abbr tre 'eza --tree --long --icons --header --all --git . -L '
abbr ff "fzf --preview 'bat --style=numbers --color=always {}'"

# Fish config reload
abbr fsrc 'source ~/.config/fish/config.fish'

abbr sc 'sesh connect $(sesh list | fzf)'

# Environment variables
set -gx EDITOR nvim

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings

    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursors to an underscore
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore

    # This binds "kj" to switch to normal mode in vi-mode.
    # If you kept it like that, every time you press "j",
    # fish would wait for a "k" or other key to disambiguate
    bind -M insert -m default kj cancel repaint-mode

    # After setting this, fish only waits 200ms for the "k",
    # or decides to treat the "j" as a separate sequence, inserting it.
    set -g fish_sequence_key_delay_ms 200
end

source (/usr/bin/starship init fish --print-full-init | psub)
/usr/bin/mise activate fish | source
