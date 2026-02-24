#!/bin/sh
osascript <<'EOF'
tell application "System Events" to tell application process "Preview"
	click menu item "Go to Page…" of menu 1 of menu bar item "Go" of menu bar 1
	delay 0.2
	keystroke "1"
	delay 0.1
	key code 36 -- return
end tell
EOF
