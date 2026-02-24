#!/bin/sh
osascript <<'EOF'
tell application "Safari" to tell window 1 to set _url to URL of tab 1 whose visible of it = true
tell application "System Events" to click menu item "New Private Window" of menu 1 of menu bar item "File" of menu bar 1 of application process "Safari"
tell application "Safari" to tell window 1 to set URL of (tab 1 whose visible of it = true) to _url
EOF
