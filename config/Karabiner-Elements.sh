#!/bin/sh

if [ -d /Applications/Karabiner-Elements.app ]; then
	# start on login
	# launchctl kickstart -k "gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server" 1>/dev/null 2>&1
fi
