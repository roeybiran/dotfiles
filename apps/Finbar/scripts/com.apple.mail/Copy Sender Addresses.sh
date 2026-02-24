#!/bin/sh
osascript <<'EOF'
tell application "Mail"
	set sendersList to {}
	set theMessages to the selected messages of message viewer 0
	repeat with aMessage in theMessages
		set end of sendersList to extract address from (sender of aMessage)
	end repeat
end tell
set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {return}}
set the clipboard to items of sendersList as text
set AppleScript's text item delimiters to saveTID
EOF
