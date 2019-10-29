#!/bin/bash

# this script deletes the "Apple Inc." card and the local version of my personal card
# /usr/bin/osascript 1>/dev/null <<-EOF
#     tell application "Contacts"
#         set n to name of my card
#         delete (every person whose name is n and vcard does not contain "iCloud")

#         --set myId to id of my card
#         --set myName to name of my card
#         --
#         --set myCards to id of every person whose name = myName
#         --
#         --repeat with i from 1 to count myCards
#         --	set theCard to item i of myCards
#         --	if myId is not theCard then
#         --		delete person id theCard
#         --	end if
#         --end repeat

#         if exists person "Apple Inc." then
#             delete person "Apple Inc."
#         end if

#         save

#     end tell
# EOF
