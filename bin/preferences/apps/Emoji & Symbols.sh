#!/bin/sh

# skip the skin tone alerts
for arg in \
	'Add :EMFDefaultsKey dict' \
	'Add :EMFDefaultsKey:EMFDidDisplaySkinToneHelpKey bool true' \
	'Add :EMFDefaultsKey:EMFSkinToneBaseKeyPreferences dict' \
	'Add :EMFDefaultsKey:EMFSkinToneBaseKeyPreferences:👍 string 👍'
do
	/usr/libexec/PlistBuddy -c "${arg}" "${HOME}/Library/Preferences/com.apple.EmojiPreferences.plist" 2>/dev/null
done
