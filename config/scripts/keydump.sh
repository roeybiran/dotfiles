#!/bin/bash

function keydump() {
	app="$1"
	if [[ -z "$app" ]]; then
		echo "USAGE: keydump <bundle identifier>"
		return
	fi
	hotkeys="$(defaults read "$app" NSUserKeyEquivalents | sed '1d' | sed '$ d')"
	arr=()
	while IFS=$'\n' read -r hotkey; do
		formatted="$(printf "%s\n" "$hotkey" | sed -E 's/[[:space:]]{2,}/ /' | sed -E 's/^[[:space:]]+//' | sed "s|\"|'|g" | sed 's/ = / -string /g' | sed -E 's/;$//')"
		arr+=("defaults write $app NSUserKeyEquivalents -dict-add $formatted")
	done <<<"$hotkeys"
	printf "%s\n" "${arr[@]}" | pbcopy
	echo "Shortcuts copied to clipboard."
}
