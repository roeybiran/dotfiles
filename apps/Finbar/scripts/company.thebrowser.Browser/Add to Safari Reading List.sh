#!/bin/sh
osascript <<'EOF'
tell application "Arc.app"
	tell («class WiND» 1 whose visible is true)
		set theTitle to name of «class acTa»
		set theURL to «class URL » of «class acTa»
		tell application "Safari" to add reading list item (theURL) and preview text "" with title (theTitle)
	end tell
end tell
EOF
