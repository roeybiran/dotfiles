#!/bin/sh

if [ -f ~/.fzf.zsh ] && [ -f ~/.fzf.bash ]; then
	exit
fi

fzfpath=/opt/homebrew/opt/fzf/install
if [ -f "$fzfpath" ]; then
	yes | "$fzfpath"
fi
