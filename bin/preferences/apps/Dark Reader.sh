#!/bin/sh

plist="${HOME}/Library/Containers/org.darkreader.DarkReaderSafari.DarkReader/Data/Library/Preferences/org.darkreader.DarkReaderSafari.DarkReader.plist"

defaults write "${plist}" automation -string "system-dark-mode"
defaults write "{plist}" siteList -array \
	"www.amazon.com"d

/usr/libexec/PlistBuddy -c "Delete :customThemes" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes array" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0 dict" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:url array" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:url:0 string app.later.com" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:theme dict" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:theme:brightness real 100.000000" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:theme:contrast real 100.000000" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:theme:engine string dynamicTheme" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:theme:grayscale real 0.000000" "${plist}"
/usr/libexec/PlistBuddy -c "Add :customThemes:0:theme:mode real 0.000000" "${plist}"
