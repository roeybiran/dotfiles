#!/usr/bin/env bash

align_window () {
	arr=()
	domain="${1}"
	key="${2}"
	values=$(defaults read "${domain}" "${key}")
	for value in $values; do
		arr+=("$value")
	done
	appWindowW=${arr[2]}
	appWindowH=${arr[3]}
	screenW=${arr[6]}
	screenH=${arr[7]}

	appWindowX=$(( ((screenW / 2) - (appWindowW / 2)) ))
	appWindowY=$(( ((screenH / 2) - (appWindowH / 2)) ))

	dimensions="${appWindowX} ${appWindowY} ${appWindowW} ${appWindowH} ${screenW} ${screenH}"
	defaults write "${domain}" "${key}" -string "${dimensions}"
}
