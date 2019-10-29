#!/bin/bash

UTIS="
com.apple.Preview	.eps
com.apple.Preview	.pdf
com.apple.Preview	.svg
com.apple.TextEdit	.nfo
com.apple.TextEdit	.txt
com.colliderli.iina	.avi
com.microsoft.VSCode	.bash_profile
com.microsoft.VSCode	.bashrc
com.microsoft.VSCode	.cnf
com.microsoft.VSCode	.conf
com.microsoft.VSCode	.css
com.microsoft.VSCode	.eslintrc
com.microsoft.VSCode	.gitconfig
com.microsoft.VSCode	.gitignore
com.microsoft.VSCode	.hushlogin
com.microsoft.VSCode	.js
com.microsoft.VSCode	.json
com.microsoft.VSCode	.lua
com.microsoft.VSCode	.md
com.microsoft.VSCode	.npmrc
com.microsoft.VSCode	.php
com.microsoft.VSCode	.pl
com.microsoft.VSCode	.plist
com.microsoft.VSCode	.py
com.microsoft.VSCode	.sh
com.microsoft.VSCode	public.data
com.microsoft.VSCode	public.item
com.microsoft.VSCode	.zshrc
"

while IFS=$'\t\n' read -r handler extension; do

	if [[ -z "${handler}" ]]; then
		continue
	fi

	/usr/local/bin/duti -s "${handler}" "${extension}" all

done <<< "${UTIS}"
