#!/bin/sh
osascript <<'EOF'
tell application "Finder"
	set inverted to {}
	set fitems to items of window 1 as alias list
	set selectedItems to the selection as alias list
	repeat with i in fitems
		if i is not in selectedItems then
			set end of inverted to i
		end if
	end repeat
	select inverted
end tell
EOF
