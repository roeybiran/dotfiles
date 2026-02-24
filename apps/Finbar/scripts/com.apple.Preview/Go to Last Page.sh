#!/bin/sh
osascript <<'EOF'
tell application "System Events" to tell application process "Preview"
	set lastPageNum to last word of (name of window 1 as text)
	click menu item "Go to Page…" of menu 1 of menu bar item "Go" of menu bar 1
	delay 0.2
	keystroke lastPageNum
	delay 0.1
	key code 36
end tell
EOF
