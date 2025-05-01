#!/bin/bash

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER=',,'
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --marker=✅'

# Use fd (https://github.com/sharkdp/fd) instead of the default find command for listing path candidates
_fzf_compgen_path() {
	fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
	fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_complete_defaults() {
	_fzf_complete -- "$@" < <(defaults domains | sed 's/, /\n/g')
}

_fzf_complete_defaults_post() {
	defaults read "$1"
}

git_fuzzy_add() {
	# https://spin.atomicobject.com/2018/04/05/fuzzy-find-git-add/
	git ls-files -m -o --exclude-standard | fzf -m --header="ADD PATHSPEC(s)…" --print0 | xargs -0 -o -t git add
}

git_fuzzy_checkout() {
	if [ -z "$1" ]; then
		git switch "$(git for-each-ref --sort=-creatordate refs/heads/ --format="%(refname:short)" | fzf --header="SWITCH TO BRANCH…")" 2>/dev/null
		return
	fi

	if [ "$1" = "-" ]; then
		git switch -
		return
	fi

	if [ "$1" = "m" ]; then
		git switch $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
		return
	fi

	if git branch | grep -q "$1"; then
		git switch "$1"
	else
		git switch --create "$1"
	fi
}

git_fuzzy_delete_branch() {
	# https://peterp.me/cli-tips-interactive-branch-delete/
	git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)" |
		fzf --multi --print0 --header="DELETE BRANCHES…" |
		xargs -0 -o -t git branch -D 2>/dev/null
}

# https://github.com/bturrubiates/fzf-scripts/blob/master/git-stash-explore
git_fuzzy_stash() {
	git stash list | fzf --ansi --preview="echo {} | cut -d':' -f1 | xargs git stash show"
}

# https://sancho.dev/blog/better-yarn-npm-run
fzf_npm_run() {
	local scripts
	if [[ -f  package.json ]]; then
		scripts=$(jq .scripts package.json | sed '1d;$d' | fzf --height 40%)
		if [[ -n $scripts ]]; then
			script_name=$(echo "$scripts" | awk -F ': ' '{gsub(/"/, "", $1); print $1}')
			print -s "yarn run $script_name"
			yarn run "$script_name"
		else
			echo "Error: No script selected"
		fi
	else
		echo "Error: No package.json"
	fi
}

alias gsw=git_fuzzy_checkout
alias gdb=git_fuzzy_delete_branch
alias fnr=fzf_npm_run
alias gfs=git_fuzzy_stash
alias gfa=git_fuzzy_add
