#!/bin/zsh
# shellcheck shell=bash

function workday() {
	case "$1" in
	gm)
		brew services start nginx
		for app in WhatsApp Mail Slack "MeetingBar"; do
			open -jga "$app"
		done
		# open -g "hammerspoon://set-default-browser?id=com.brave.Browser"
		osascript -e 'tell application "iTerm" to launch API script named "workday" arguments "gm"'
		code ~/Developer/mono
		;;
	gn)
		brew services stop nginx 2>/dev/null
		killall Figma Cypress Slack "MeetingBar" "Docker Desktop" 2>/dev/null
		# open -g "hammerspoon://set-default-browser?id=com.apple.Safari"
		osascript -e 'tell application "iTerm" to launch API script named "workday" arguments "gn"'
		;;
	*)
		echo "?"
		;;
	esac

}
