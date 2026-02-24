#!/bin/sh
osascript <<'EOF'
tell application "System Events"
	tell application process "System Preferences"
		tell window 1
			tell tab group 1
				click button 2
			end tell
		end tell
	end tell
end tell
EOF
