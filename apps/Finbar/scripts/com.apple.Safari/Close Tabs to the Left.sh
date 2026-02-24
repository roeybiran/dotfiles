#!/bin/sh
osascript <<'EOF'
tell application "Safari"
	tell window 1
		set visibleTab to index of first tab whose visible is true
		repeat until visibleTab = 1
			close tab index 1
			set visibleTab to visibleTab - 1
		end repeat
	end tell
end tell
EOF
