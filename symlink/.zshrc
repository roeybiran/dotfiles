#!/bin/zsh
# shellcheck shell=bash

eval "$(fnm env --use-on-cd)"

export EDITOR="nvim"
alias vim="nvim"

### AUTOJUMP
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# z
# . /opt/homebrew/etc/profile.d/z.sh

# enable vim mode
# bindkey -v

alert() {
	osascript -e "display alert \"${1:-Done!}\"" &>/dev/null
}

# ENVIRONMENT VARS
export LANG=en_US.UTF-8
# https://stackoverflow.com/questions/444951/zsh-stop-backward-kill-word-on-directory-delimiter
export WORDCHARS='*?[]~=&;!#$%^(){}<>'

export HOMEBREW_BUNDLE_FILE=~/.Brewfile
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

setopt complete_aliases

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
SAVEHIST=5000
HISTSIZE=2000
setopt EXTENDED_HISTORY
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST
# do not store duplications
setopt HIST_IGNORE_DUPS
# ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS

# bindings
# bindkey '^[[A' history-beginning-search-backward
# bindkey '^[[B' history-beginning-search-forward
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

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
zstyle ':vcs_info:git:*' formats '%F{240}(%r/%b)%f' # brgreen / # brcyan
zstyle ':vcs_info:*' enable git

pwd_with_blue_underline="%U%F{blue}%~%f%u"
exit_status_bold_and_red_if_0="%B%(?.>.%F{red}x)%f%b"
PROMPT="
$pwd_with_blue_underline $gitprompt
$exit_status_bold_and_red_if_0 "

# zsh autosuggest
# source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

# [ -f ~/.local/fzf-tab/fzf-tab.plugin.zsh ] && source ~/.local/fzf-tab/fzf-tab.plugin.zsh

rm() {
	trash "$@"
}

mkcd() {
	mkdir -p "$1"
	cd "$1"
}

dropboxignore() {
	ignorables=(
		-name
		node_modules
		-or
		-name
		.next
	)

	# https://stackoverflow.com/a/1489405
	find ~/Dropbox \( ${ignorables[@]} \) -prune -exec xattr -w com.dropbox.ignored 1 {} \;
}

dropbox_ignore_all_ignorables() {
	ignorables=(
		-name
		node_modules
		-or
		-name
		.next
	)

	# https://stackoverflow.com/a/1489405
	find ~/Dropbox \( ${ignorables[@]} \) -prune -print -exec xattr -w com.dropbox.ignored 1 {} \;
}

gt() {
	paths=(
		~/Dropbox/
	)
	res="$(fd --no-ignore . "${paths[@]}" | fzf)"
	cd "$res" || cd "$(dirname "$res")"
}

dt() {
	~/Dropbox/projects/code/dotfiles/main.sh "${@}"
}

whichport() {
	sudo lsof -nP -i4TCP:"$1" | grep LISTEN
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# fpath=(~/.site-functions "${fpath[@]}")
# autoload -Uz $fpath[1]/*(.:t)

zf() {
	if [[ -z "$1" ]]; then
		cd "$(z | fzf | sed -E 's:^[^/]*::')"
	else
		z "$1"
	fi
}

source ~/.aliases

for f in ~/.site-functions/*; do
	source "$f"
done

# maintain --check

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/roey/Developer/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/roey/Developer/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/roey/Developer/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/roey/Developer/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
