#!/bin/zsh
# shellcheck shell=bash

# git rebase -i --committer-date-is-author-date --strategy-option=theirs --root
export EDITOR="nvim"
export LANG=en_US.UTF-8
export WORDCHARS='*?[]~=&;!#$%^(){}<>' # https://stackoverflow.com/questions/444951/zsh-stop-backward-kill-word-on-directory-delimiter
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

setopt complete_aliases
set -o vi

# case insensitive path-completion
zstyle ':completion:*' \
	matcher-list \
	'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
	'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' \
	'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' \
	'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' select-prompt ''
zstyle ':completion:*' list-prompt ''

# load bashcompinit for some old bash completions
autoload bashcompinit && bashcompinit

### SHELL OPTS
setopt AUTO_CD
setopt NO_CASE_GLOB

# history
HISTFILE=~/.history/.zsh_history

# https://github.com/ohmyzsh/ohmyzsh/blob/95ef2516697aa764d1d4bb93ad3490584cc118ec/lib/history.zsh#L37
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# bindings
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

### PROMPT
autoload -Uz promptinit compinit vcs_info
compinit
promptinit
setopt prompt_subst
precmd_vcs_info() {
	vcs_info
}
precmd_functions+=(precmd_vcs_info)
gitprompt=\$vcs_info_msg_0_

if compaudit | grep -qE "\w"; then
	# https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories
	compaudit | xargs chmod g-w
fi

zstyle ':completion:*' menu select
zstyle ':vcs_info:git:*' formats '%F{240}(📦%r 🌳%b)%f'
zstyle ':vcs_info:*' enable git

pwd_with_blue_underline="%U%F{blue}%~%f%u"
exit_status_bold_and_red_if_0="%B%(?.>.%F{red}x)%f%b"
PROMPT="
$pwd_with_blue_underline $gitprompt
$exit_status_bold_and_red_if_0 "

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

for s in ~/.scripts/* ~/.scripts/private/*; do
	source "$s"
done

source ~/.aliases

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"
