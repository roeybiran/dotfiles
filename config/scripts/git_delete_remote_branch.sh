#!/bin/bash

function git_delete_remote_branch() {
	if [ $# -eq 0 ]; then
		git push origin --delete "$(git branch --show-current)"
	else
		for branch in "$@"; do
			git push origin --delete "$branch"
		done
	fi
}
