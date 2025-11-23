#!/bin/sh

url="$(
	osascript <<-EOF
		tell application "Arc"
			tell (window 1 whose visible is true)
				tell active tab
					return URL
				end tell
			end tell
		end tell
	EOF
)"

open -b com.apple.Safari "$url"
