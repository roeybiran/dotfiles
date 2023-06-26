#!/bin/bash

list=(
	.aliases:"$HOME/.aliases"
	.Brewfile:"$HOME/.Brewfile"
	.dash:"$HOME/.dash"
	.gitconfig:"$HOME/.gitconfig"
	.gitignore:"$HOME/.gitignore"
	.hammerspoon:"$HOME/.hammerspoon"
	.history:"$HOME/.history"
	.site-functions:"$HOME/.site-functions"
	.vim:"$HOME/.vim"
	.vimrc:"$HOME/.vimrc"
	.zshrc:"$HOME/.zshrc"
	autojump:"$HOME/Library/autojump"
	com.googlecode.iterm2.plist:"$HOME/.iterm2/com.googlecode.iterm2.plist"
	finbar_recents.json:"$HOME/Library/Application Support/com.roeybiran.Finbar/recents.json"
	iterm2_scripts:"$HOME/Library/Application Support/iTerm2/Scripts"
	karabiner.json:"$HOME/.config/karabiner/karabiner.json"
	LaunchBar:"$HOME/Library/Application Support/LaunchBar"
	nvim:"$HOME/.config/nvim"
	kitty:"$HOME/.config/kitty"
	xcode_keybindings:"$HOME/Library/Developer/Xcode/UserData/KeyBindings"
	xcode_macros.plist:"$HOME/Library/Developer/Xcode/UserData/IDETemplateMacros.plist"
	xcode_snippets:"$HOME/Library/Developer/Xcode/UserData/CodeSnippets"
	xcode_themes:"$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
)

for f in "${list[@]}"; do
	src="$(echo "$f" | cut -d ':' -f 1)"
	dst="$(echo "$f" | cut -d ':' -f 2)"
	if [ -z "$src" ] || [ -z "$dst" ]; then
		echo "Symlinks: invalid source or destination (resolving $src -> $dst)"
		continue
	fi

	dst_dir="$(dirname "$dst")"
	if [ ! -d "$dst_dir" ]; then
		mkdir -p "$dst_dir" 2>/dev/null
	fi

	final_src="$PWD/symlink/$src"

	if [ ! -e "$final_src" ]; then
		echo "Symlinks: $src not found, update list"
		continue
	fi

	ln -sfn "$final_src" "$dst"

	if [[ ! -L "$dst" ]]; then
		echo "Failed to create symlink at $dst"
	fi
done
