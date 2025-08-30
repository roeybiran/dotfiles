#!/bin/zsh
# shellcheck shell=bash

export EDITOR="nvim"
export LANG=en_US.UTF-8
export WORDCHARS='*?[]~=&;!#$%^(){}<>' # https://stackoverflow.com/questions/444951/zsh-stop-backward-kill-word-on-directory-delimiter

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

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
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^y' autosuggest-accept

### SCRIPTS
for s in ~/.config/scripts/* ~/.config/scripts/private/*; do
	source "$s"
done

### ALIASES
source ~/.config/aliases

### 3RD-PARTY
source /opt/homebrew/opt/spaceship/spaceship.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -r '^R' # disable fzf's default Ctrl+R binding
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
export PATH="$HOME/.local/bin:$PATH"

