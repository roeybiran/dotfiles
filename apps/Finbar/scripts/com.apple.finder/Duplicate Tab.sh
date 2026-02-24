#!/bin/sh
osascript <<'EOF'
tell application "Finder" to set _t to target of Finder window 1
tell application "System Events"
	tell application process "Finder"
		click menu item "New Tab" of menu 1 of menu bar item "File" of menu bar 1
	end tell
end tell
tell application "Finder" to set target of Finder window 1 to _t
EOF
