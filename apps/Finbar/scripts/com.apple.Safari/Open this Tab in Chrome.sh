#!/bin/sh
osascript <<'EOF'
tell application "Safari"
	tell its first window
		set _url to URL of its first tab where it is visible
		set _url to _url as text
	end tell
end tell
tell application "Google Chrome"
	activate
	repeat until its first window exists
	end repeat
	tell its first window
		set _tab to make new tab
		set URL of _tab to _url
	end tell
end tell
EOF
