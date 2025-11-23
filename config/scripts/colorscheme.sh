#!/usr/bin/env bash

yellow=#b58900
orange=#cb4b16
red=#dc322f
magenta=#d33682
violet=#6c71c4
blue=#268bd2
cyan=#2aa198
green=#859900

base03=#002b36
# dark > background
# light > ---

base02=#073642
# dark > background highlights
# light > ---

base01=#586e75
# dark > comments / secondary content
# light > optional emphasized content

base00=#657b83
# dark > ---
# light > body text / default code / primary content

base0=#839496
# dark > body text / default code / primary content
# light > ---

base1=#93a1a1
# dark > optional emphasized content
# light > comments / secondary content

base2=#eee8d5
# dark >  ---
# light > background highlights

base3=#fdf6e3
# dark > ---
# light > background

function colorscheme() {
	local mode="$1"

	# tmux
	# ====
	/opt/homebrew/bin/tmux source-file ~/.tmux.conf

	# Alacritty
	# =========
	if [[ "$mode" == "dark" ]]; then
		background=$base03
		foreground=$base0
	else
		background=$base3
		foreground=$base00
	fi
	sed -i "" "s/^background = .*/background = '$background'/" "$(realpath "$HOME"/.config/alacritty/alacritty.toml)"
	sed -i "" "s/^foreground = .*/foreground = '$foreground'/" "$(realpath "$HOME"/.config/alacritty/alacritty.toml)"
}

# this is meant to be called from another process (e.g. Hammerspoon) on macOS theme change
if [[ "$1" == "--run" ]]; then
	colorscheme "$2"
fi
