#!/bin/bash

gt() {
	paths=(
		~/Dropbox/
	)
	res="$(fd --no-ignore . "${paths[@]}" | fzf)"
	cd "$res" || cd "$(dirname "$res")"
}
