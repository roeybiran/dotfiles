#!/bin/bash

pkgmgr() {
	selection="$(printf "%s\n" \
		"$(brew list --cask | sed 's/$/\tcask/g')" \
		"$(brew leaves | sed 's/$/\tbrew/g')" \
		"$(mas list | sed -E 's/  +/ /g' | rev | cut -d ' ' -f2- | rev | sed 's/$/\tMAS/g')" |
		column -ts $'\t' |
		fzf -m)"

	brew=()
	cask=()
	mas=()
	while IFS=$'\n' read -r LINE; do
		app="$(echo "$LINE" | rev | cut -d ' ' -f2- | rev | sed -E 's/  +//g')"
		arg="$(echo "$LINE" | rev | cut -d ' ' -f1 | rev | sed -E 's/  +//g')"
		case "$arg" in
		brew)
			brew+=("$app")
			;;
		cask)
			cask+=("$app")
			;;
		MAS)
			mas+=("$(echo "$app" | cut -d ' ' -f1)")
			;;
		esac
	done <<<"${selection}"
	[ "${#brew[@]}" -gt 0 ] && brew uninstall "${brew[@]}"
	[ "${#cask[@]}" -gt 0 ] && brew uninstall --cask "${cask[@]}"
	[ "${#mas[@]}" -gt 0 ] && sudo mas uninstall "${mas[@]}"

}
