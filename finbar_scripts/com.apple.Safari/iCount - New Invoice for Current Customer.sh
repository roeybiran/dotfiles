#!/bin/bash

url="$(osascript -e 'tell application "Safari" to tell window 1 to return URL of current tab')"
match="$(printf "%s\n" "${url}" | grep -E -o 'id=\d+' | sed 's/id=//')"

if [[ -n "${match}" ]]; then
	osascript - "${match}" <<-EOF
		on run argv
		tell application "Safari"
		    tell window 1
		      tell current tab
		        set URL to "https://app.icount.co.il/hash/create_doc.php?doctype=invrec&client_id=" & (item 1 of argv)
		      end tell
		    end tell
		  end tell
		end run
	EOF
fi
