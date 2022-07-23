#!/bin/bash

# links_dir="${1:?ERR! No links_dir argument supplied}"
# symlink_prefix="_LINK_"
# cd "$links_dir" || exit 1

trash() {
	swift - "$@" <<-EOF
		import Foundation
		CommandLine.arguments.dropFirst().forEach { path in
			try? FileManager.default.trashItem(at: URL(fileURLWithPath: path), resultingItemURL: nil)
		}
	EOF
}

# dirname "$0"
# dir="$(dirname "$0")/links"
# echo "$dir"

list=(
	.Brewfile:"$HOME/.Brewfile"
	.gitconfig:"$HOME/.gitconfig"
	.gitignore:"$HOME/.gitignore"
	.vimrc:"$HOME/.vimrc"
	.zsh_history:"$HOME/.zsh_history"
	.zshrc:"$HOME/.zshrc"
	karabiner.json:"$HOME/.config/karabiner/karabiner.json"
	.site-functions:"$HOME/.site-functions"
	.hammerspoon:"$HOME/.hammerspoon"
	.dash:"$HOME/.dash"
	LaunchBar:"$HOME/Library/Application Support/LaunchBar"
	com.googlecode.iterm2.plist:"$HOME/.iterm2/com.googlecode.iterm2.plist"
	iterm2_scripts:"$HOME/Library/Application Support/iTerm2/Scripts"
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

	# echo "symlinking $src --> $dst/$src"
	ln -sfn "$final_src" "$dst"

	if [[ ! -L "$dst" ]]; then
		echo "Failed to create symlink at $dst"
	fi
done

# tmp="$(mktemp -d)"
# while IFS=$'\n' read -r line; do
# 	dst_dir="$(dirname "${line//$links_dir/$HOME}")"
# 	dst_name="$(basename "${line//$symlink_prefix/}")"
# 	dst_path="$dst_dir/$dst_name"
# 	test -e "$dst_path" && mv "$dst_path" "$tmp"
# 	mkdir -p "$dst_dir" 2>/dev/null
# 	ln -sFh "$line" "$dst_path"
# done < <(find "$(pwd)" -name "$symlink_prefix*")
# trash "$tmp"
