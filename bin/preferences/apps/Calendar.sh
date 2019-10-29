#!/bin/bash

# Default Calendar: [iCloud]
current_cal="$(defaults read com.apple.iCal CalDefaultCalendar 2>/dev/null)"

if [[ -z "${current_cal}" ]]; then
	calendar_uid="$(osascript -e 'tell application "Calendar" to return calendar "iCloud"' | sed 's/calendar id //')"
  defaults delete com.apple.iCal CalDefaultPrincipal
  defaults write com.apple.iCal CalDefaultCalendar "${calendar_uid}"
  defaults write com.apple.iCal CalDefaultCalendarSelectedByUser -bool false
fi

# don't show holidays calendar
defaults write com.apple.iCal "add holiday calendar" -bool false
# [ ] Show alternate calendar: [Chinese]
defaults write com.apple.iCal CALPrefOverlayCalendarIdentifier -string ""
