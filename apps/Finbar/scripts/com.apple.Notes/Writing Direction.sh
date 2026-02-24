#!/bin/sh
direction="$1"
osascript <<EOF
tell application "System Events" to tell application process "Notes" to tell menu bar 1 to tell menu bar item "Format" to tell menu 1 to tell menu item "Text" to tell menu 1 to tell menu item "Writing Direction" to tell menu 1
	click (every menu item whose title contains "$direction")
end tell
EOF
