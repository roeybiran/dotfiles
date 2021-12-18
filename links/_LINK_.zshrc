#!/bin/zsh

#### FIG ENV VARIABLES ####
# Please make sure this block is at the start of this file.
[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh
#### END FIG ENV VARIABLES ####

# enable vim mode
# bindkey -v

# ENVIRONMENT VARS
export LANG=en_US.UTF-8
# https://stackoverflow.com/questions/444951/zsh-stop-backward-kill-word-on-directory-delimiter
export WORDCHARS='*?[]~=&;!#$%^(){}<>'

export HOMEBREW_BUNDLE_FILE=~/.Brewfile
export BREW_BUNDLE_NO_LOCK=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--bind tab:down --cycle'

setopt complete_aliases

# ALIASES
alias nr="npm run"
alias bci='brew install --cask'
alias bci='brew install --cask'
alias bcr='brew reinstall --cask'
alias bcu='brew uninstall --cask'
alias bi='brew install'
alias bs='brew search'
alias bu='brew uninstall'
alias defd='defaults delete'
alias defre='defaults read'
alias deft='defaults read-type'
alias ls='ls -G -F -A'
alias grepi='grep -i'
alias gu='cd ..'
alias dbxignore='xattr -w com.dropbox.ignored 1'
alias r='source ~/.zshrc'

alias git-show-ignored='git ls-files . --ignored --exclude-standard --others'
alias git-show-untracked='git ls-files . --exclude-standard --others'
alias git-show-tracked='git ls-tree -r HEAD --name-only'

# PATH
export PATH=$PATH:/usr/local/sbin #brew

if type brew &>/dev/null; then
	FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

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
HISTFILE=~/.zsh_history
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
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

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

### PLUGINS
# source ~/Documents/fzf-tab/fzf-tab.plugin.zsh

# zsh autosuggest
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

### FZF
# https://github.com/junegunn/fzf#tips

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use fd (https://github.com/sharkdp/fd) instead of the default find command for listing path candidates.
_fzf_compgen_path() {
	fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
	fd --type d --hidden --follow --exclude ".git" . "$1"
}

### AUTOJUMP
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# functions
j() {
	cd "$(/usr/local/bin/autojump "$1")" || cd
}

defra() {
	cd ~/Desktop || return
	defaults read >a
	printf "%s\n" "Press any key to continue"
	read -r
	defaults read >b
	icdiff -N -H a b
	cd || return
}

cdf() {
	current_path=$(
		osascript <<-EOF
			tell app "Finder"
				try
					POSIX path of (insertion location as alias)
				on error
					POSIX path of (path to desktop folder as alias)
				end try
			end tell
		EOF
	)
	cd "$current_path"
}

rm() {
	trash "$@"
}

tldr() {
	/usr/local/bin/tldr "$@"
}

keydump() {
	local app="$1"
	if [[ -z "$app" ]]; then
		echo "USAGE: keydump <bundle identifier>"
		return
	fi
	hotkeys="$(defaults read "$app" NSUserKeyEquivalents | sed '1d' | sed '$ d')"
	arr=()
	while IFS=$'\n' read -r hotkey; do
		formatted="$(printf "%s\n" "$hotkey" | sed -E 's/[[:space:]]{2,}/ /' | sed -E 's/^[[:space:]]+//' | sed "s|\"|'|g" | sed 's/ = / -string /g' | sed -E 's/;$//')"
		arr+=("defaults write $app NSUserKeyEquivalents $formatted")
	done <<<"$hotkeys"
	printf "%s\n" "${arr[@]}" | pbcopy
}

top() {
	/usr/bin/top -i 10 -stats command,cpu,mem -s 2
}

fkill() {
	pids=$(ps -r -c -A -o 'command=,%cpu=,pid=' | /usr/local/bin/fzf -m --bind 'tab:toggle' | awk '{ print $NF }')
	while IFS=$'\n' read -A pid; do
		/bin/kill -SIGKILL "$pid"
	done <<<"$pids"
}

mkcd() {
	mkdir -p "$1"
	cd "$1"
}

maintain() {
	dependencies=(
		/usr/local/bin/trash
	)

	dotfiles_prefs=~/Library/Preferences/com.roeybiran.dotfiles.plist

	weekly_maintenance_dirs=(
		~/Dropbox
	)

	for f in "${dependencies[@]}"; do
		test ! -e "$f" && echo "Missing depedency: $f. Exiting" && return
	done

	if test -z "$1"; then
		echo "USAGE: maintain [run] [--status]"
		return
	fi

	now="$(date +%s)"

	if test "$1" = --status; then
		last_update_date="$(defaults read "$dotfiles_prefs" maintainanceLastRunDate 2>/dev/null)"
		if test -z "$last_update_date"; then
			# first run
			echo "has yet to run."
			return
		fi
		time_elapsed_since_last_update=$(((now - last_update_date) / 86400))
		echo "last run was $time_elapsed_since_last_update days ago."
		return
	fi

	defaults write "$dotfiles_prefs" maintainanceLastRunDate -int "$now"

	sudo -v
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &

	echo "Updating package managers..."

	# mas
	echo ">> mas upgrade"
	mas upgrade

	# npm
	echo ">> updating npm"
	npm install -g npm@latest
	echo ">> updating global npm packages"
	npm update -g

	# brew
	# update brew itself and all formulae
	echo ">> brew update"
	brew update
	# update casks and all unpinned formulae
	echo ">> brew upgrade"
	brew upgrade
	echo ">> brew cleanup"
	brew cleanup
	echo ">> brew autoremove"
	brew autoremove
	echo ">> brew doctor"
	brew doctor

	echo "Trashing sync conflicts and broken symlinks..."
	for dir in "${weekly_maintenance_dirs[@]}"; do
		find "$dir" \( -iname '*conflict*-*-*)*' -or -type l ! -exec test -e {} \; \) -exec trash {} \; -exec echo "Trashed: " {} \;
	done

	# launchbar housekeeping
	# remove logging for all actions
	# for f in "$HOME/Library/Application Support/LaunchBar/Actions/"*".lbaction/Contents/Info.plist"; do
	# 	/usr/libexec/PlistBuddy -c "Delete :LBDebugLogEnabled" "$f" 2>/dev/null
	# done

	actions_identifiers=()
	launchbar_dir="$HOME/Library/Application Support/LaunchBar"
	action_support_dir="$launchbar_dir/Action Support"
	lbaction_packages=$(find "$launchbar_dir/Actions" -type d -name "*.lbaction")
	while IFS=$'\n' read -r plist; do
		actions_identifiers+=("$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$plist/Contents/Info.plist" 2>/dev/null)")
	done <<<"$lbaction_packages"
	paths="$(printf "%s\n" "$action_support_dir/"*)"
	while IFS=$'\n' read -r dir; do
		delete=true
		basename="$(basename "$dir")"
		for id in "${actions_identifiers[@]}"; do
			if test "$basename" = "$id"; then
				delete=false
			fi
		done
		if "$delete"; then
			echo "LaunchBar cleanup: $dir"
			trash "$dir"
		fi
	done <<<"$paths"

	# if softwareupdate --all --install --force 2>&1 | tee /dev/tty | grep -q "No updates are available"; then
	# 	sudo rm -rf /Library/Developer/CommandLineTools
	# 	sudo xcode-select --install
	# fi

}

adobe_cleanup() {
	pkill -15 -li adobe
	pkill -15 -li "creative cloud"
	for f in ~/Library/LaunchAgents/* /Library/LaunchDaemons/* /Library/LaunchAgents/*; do
		if echo "$f" | grep -iq adobe; then
			sudo rm -rf "$f"
			echo "deleting $f"
		fi
	done
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

applist() {
	brewfile_list="$(brew bundle list --all --no-upgrade | grep -v "/")"

	npm_list=(
		np
		npm-check-updates
		vercel
		zx
	)

	mylist="$(printf "%s\n" "$brewfile_list" "${npm_list[@]}")"

	brew="$(brew leaves)"
	cask="$(brew list --cask)"
	mas="$(mas list | cut -d" " -f2- | rev | cut -d" " -f2- | rev | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//')"
	npm="$(npm list -g --depth=0 2>/dev/null | grep ── | cut -d" " -f2 | sed -E "s/@.+$//" | grep -ve '^npm$')"

	current="$(printf "%s\n" ">> brew" "$brew" ">> cask" "$cask" ">> mas" "$mas" ">> npm" "$npm")"

	while IFS=$'\n' read -r LINE; do
		if echo "$mylist" | grep -q "$LINE"; then
			echo -e "\033[0;32m$LINE"
		else
			echo -e "\033[0m$LINE"
		fi
	done <<<"${current}"
}

gt() {
	paths=(
		~/Dropbox/
	)
	res="$(fd --no-ignore . "${paths[@]}" | fzf)"
	cd "$res" || cd "$(dirname "$res")"
}

# source /usr/local/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

#### FIG ENV VARIABLES ####
# Please make sure this block is at the end of this file.
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####
