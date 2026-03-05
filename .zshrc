#!/bin/zsh
# shellcheck shell=bash

export EDITOR="nvim"
export LANG=en_US.UTF-8
export WORDCHARS='*?[]~=&;!#$%^(){}<>' # https://stackoverflow.com/questions/444951/zsh-stop-backward-kill-word-on-directory-delimiter

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

export XDG_CONFIG_HOME="$HOME/.config"

setopt complete_aliases
set -o vi

### COMPLETIONS
# case insensitive path-completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# load bashcompinit for some old bash completions
autoload bashcompinit && bashcompinit

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' select-prompt ''
zstyle ':completion:*' list-prompt ''

### SHELL OPTS
setopt AUTO_CD
setopt NO_CASE_GLOB

### KEY BINDINGS
# autoload -Uz up-line-or-beginning-search
# autoload -Uz down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search
# bindkey '^y' autosuggest-accept

### SCRIPTS
for s in ~/.config/scripts/* ~/.config/scripts/private/*; do
	source "$s"
done

### ALIASES
source ~/.config/aliases

### SPACESHIP
# source /opt/homebrew/opt/spaceship/spaceship.zsh

### ZSH-AUTOSUGGESTIONS
# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

### FZF
# FZF_CTRL_R_COMMAND= # disable fzf's default Ctrl+R binding in favor of atuin
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

### ZOXIDE
eval "$(zoxide init zsh)"

### ATUIN
# eval "$(atuin init zsh)"

### CLAUDE CODE
export PATH="$HOME/.local/bin:$PATH"
