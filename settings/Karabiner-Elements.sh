#!/bin/sh

test -d /Applications/Karabiner-Elements.app || exit 0

# start on login
launchctl kickstart -k "gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server"
