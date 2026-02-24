#!/bin/sh
osascript <<'EOF'
tell application "Safari"
	tell window 1
		set visibleTab to index of first tab whose visible is true
		set tabToClose to first tab whose index = visibleTab + 1
		repeat while tabToClose exists
			close tabToClose
		end repeat
	end tell
end tell
EOF
