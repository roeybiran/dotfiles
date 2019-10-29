#!/bin/bash

# for custom app shortcuts
# https://ryanmo.co/2017/01/05/setting-keyboard-shortcuts-from-terminal-in-macos/

setKey () {
	index="${1}"
	state="${2}"
	param1="${3}"
	param2="${4}"
	param3="${5}"
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "${index}" \
	"<dict>
		<key>enabled</key>
		<${state}/>
		<key>value</key>
			<dict>
				<key>type</key>
				<string>standard</string>
				<key>parameters</key>
					<array>
						<integer>${param1}</integer>
						<integer>${param2}</integer>
						<integer>${param3}</integer>
					</array>
			</dict>
	</dict>"
}

# KEYBOARD
# faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 6
# shorter delay until repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Keyboard
# Touch Bar shows [F1, F2, etc. Keys]
defaults write com.apple.touchbar.agent PresentationModeGlobal -string functionKeys
# Press Fn key to [Show Control Strip]
defaults write com.apple.touchbar.agent PresentationModeFnModes -dict appWithControlStrip -string fullControlStrip functionKeys -string fullControlStrip
# [✓] Use F1, F2, etc. keys as standard function keys
# [✓] Use F1, F2, etc. keys as standard function keys on external keyboards
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
# bind caps lock to esc
# https://developer.apple.com/library/archive/technotes/tn2450/_index.html
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' 1>/dev/null
# Customzie Touch Bar
defaults write com.apple.controlstrip "FullCustomized" -array 'NSTouchBarItemIdentifierFlexibleSpace' \
'"com.apple.system.brightness"' \
'"com.apple.system.mission-control"' \
'"com.apple.system.launchpad"' \
'"com.apple.system.group.keyboard-brightness"' \
'"com.apple.system.group.media"' \
'NSTouchBarItemIdentifierFlexibleSpace' \
"com.apple.system.mute" \
'"com.apple.system.volume"'

# TEXT
# Spelling: automatic by language
defaults write NSGlobalDomain NSSpellCheckerAutomaticallyIdentifiesLanguages -bool true

# install hebrew spellchecking dictionary
if [[ ! -f ~/Library/Spelling/he_IL.dic ]] || [[ ! -f ~/Library/Spelling/he_IL.aff ]]; then
	cd ~/Downloads || exit
	curl -L "https://downloads.sourceforge.net/project/aoo-extensions/1155/3/dict-he-2010-11-05.oxt?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Faoo-extensions%2Ffiles%2F1155%2F3%2Fdict-he-2010-11-05.oxt%2Fdownload%3Fuse_mirror%3Djaist&ts=1571244020" -o "dict.zip"
	unzip "dict.zip" he_IL.{dic,aff} -d ~/Library/Spelling/
	rm dict.zip
	cd || exit
fi

# spelling: us english, then hebrew
globalprefs="${HOME}/Library/Preferences/.GlobalPreferences.plist"
if ! /usr/libexec/PlistBuddy -c "Print :NSPreferredSpellServers" "${globalprefs}" &>/dev/null
then
	args=("Add :NSPreferredSpellServers array" \
		"Add :NSPreferredSpellServers:0 array" \
		"Add :NSPreferredSpellServers:0:0 string Open" \
		"Add :NSPreferredSpellServers:0:0 string he_IL" \
		"Add :NSPreferredSpellServers:0 array" \
		"Add :NSPreferredSpellServers:0:0 string Apple" \
		"Add :NSPreferredSpellServers:0:0 string en")
else
	args=("Set :NSPreferredSpellServers:0:0 en" \
		"Set :NSPreferredSpellServers:0:1 Apple" \
		"Set :NSPreferredSpellServers:1:0 he_IL" \
		"Set :NSPreferredSpellServers:1:1 Open")
fi
for arg in "${args[@]}"
do
	/usr/libexec/PlistBuddy -c "${arg}" "${globalprefs}"
done

#
defaults write NSGlobalDomain NSPreferredSpellServerLanguage -string en
defaults write NSGlobalDomain NSPreferredSpellServerVendors -dict en -string Apple

# [ ] Use smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true

# Full Keyboard Access: [All controls]
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# SHORTCUTS

# Launchpad & Dock
# [ ] Turn Dock Hiding On/Off [⌥⌘D]
setKey 52 false 100 2 1572864

# Display
# [ ] Decrease display brightness [F14]
setKey 53 false 65535 107 8388608
setKey 55 false 65535 107 8912896
# [ ] Increase display brightness [F15]
setKey 54 false 65535 113 8388608
setKey 56 false 65535 113 8912896

# Mission Control
# [✓] Show Desktop [⌃⌘⌥F6]
# setKey 7 false 49 18 1179648 ?
# setKey 36 true 65535 97 1835008
# setKey 37 true 65535 97 1966080
# [ ] Show Dashboard
setKey 62 false 65535 111 8388608
setKey 63 false 65535 111 8519680
# [ ] Move left a space: [⌃←]
setKey 79 false 65535 123 8650752
# [ ] Move right a space: [⌃→]
setKey 81 false 65535 124 8650752
# [ ] Switch to Desktop 1: [⌃1]
setKey 118 false 65535 18 262144

# Keyboard
# [ ] Turn keyboard access on or off [⌃F1]
setKey 12 false 65535 122 8650752
# [ ] Move focus to the menu bar
setKey 7 false 49 18 1179648
# [✓] Move focus to the Dock [⌥⌘D]
setKey 8 true 100 2 1572864
# [✓] Move focus to active or next window [⇧⌘4]
setKey 9 true 52 21 1179648
# [✓] Move focus to window toolbar [⇧⌘2]
setKey 10 true 50 19 1179648
# [✓] Move focus to the floating window [⇧⌘3]
setKey 11 true 51 20 1179648

# Input Sources
# [✓] Select the previous input source: [^Space]
setKey 60 true 32 49 262144
# [ ] Select the next source in Input menu
setKey 61 false 32 49 786432

# Screenshots
# [ ] Save picture of screen as a file
setKey 28 false 51 20 1179648
# [ ] Copy picture of screen to the clipboard
setKey 29 false 51 20 1441792
# [ ] Save picture of selected area as a file
setKey 30 false 52 21 1179648
# [ ] Copy picture of selected area to the clipboard
setKey 31 false 52 21 1441792
# [ ] Screenshot and recording options
setKey 181 false 54 22 1179648
# [ ] Save picture of the Touch Bar as a file
setKey 182 false 54 22 1441792
# [ ] Save picture of the Touch Bar to the clipboard
setKey 184 false 53 23 1179648

### Services ###
# Disables and hides all services and unassigns their keyboard shortcuts
# Maintains a running "database" of known services
pbs_plist="${HOME}/Library/Preferences/pbs.plist"
my_plist="${SERVICESFILE}"
if [[ ! -f "${my_plist}" ]]; then
	echo "NOT FOUND: ${my_plist}" && exit 0
fi
pbs_services=$(/usr/libexec/PlistBuddy -c "Print :NSServicesStatus" "${pbs_plist}")
allServices=$(python - "${my_plist}" "${pbs_services}" <<-EOF
import sys
import plistlib
import re
my = sys.argv[1]
os = sys.argv[2]
# print os
my = plistlib.readPlist(my)["services"]
os = os.split('\n')
for line in os:
  if re.match(r"^ {4}\w", line):
    my.append((re.sub(" = Dict {$", "", line).rstrip().lstrip()))
print "\n".join(my)
EOF
)
allServices="$(printf "%s\n" "${allServices}" | sort | uniq)"
/usr/libexec/PlistBuddy -c "Delete :services" "${my_plist}"
/usr/libexec/PlistBuddy -c "Add :services array" "${my_plist}"
while IFS=$'\n' read -r service; do
  /usr/libexec/PlistBuddy -c "Delete :NSServicesStatus:\"${service}\"" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\" dict" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":key_equivalent string" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":presentation_modes dict" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":presentation_modes:ContextMenu bool false" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":presentation_modes:ServicesMenu bool false" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":presentation_modes:TouchBar bool false" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":enabled_context_menu bool false" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :NSServicesStatus:\"${service}\":enabled_services_menu bool false" "${pbs_plist}"
  /usr/libexec/PlistBuddy -c "Add :services:0 string \"${service}\"" "${my_plist}"
done <<< "${allServices}"

# Spotlight
# [✓] Show Spotlight search: [⌥Space]
setKey 64 true 65535 49 524288
# [ ] Show Finder search window: [⌥⌘Space]
setKey 65 false 65535 49 1572864

# Accessibility
# [ ] Turn VoiceOver on or off [⌘F5]
setKey 59 false 65535 96 9437184
# [ ] Show Accessibility controls [⌥⌘F5]
setKey 162 false 65535 96 9961472
# [ ] Increase Contrast
setKey 25 false 46 47 1835008
# [ ] Decrease Contrast
setKey 26 false 44 43 1835008
# [ ] Invert Colors
setKey 21 false 56 28 1835008

# App Shortcuts
# Show Help Menu: [⌥E]
setKey 98 false 47 44 1179648

# INPUT SOURCES
defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
'<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>252</integer><key>KeyboardLayout Name</key><string>ABC</string></dict>' \
'<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>-18432</integer><key>KeyboardLayout Name</key><string>Hebrew</string></dict>' \
'<dict><key>Bundle ID</key><string>com.apple.PressAndHold</string><key>InputSourceKind</key><string>Non Keyboard Input Method</string></dict>' \
'<dict><key>Bundle ID</key><string>com.apple.CharacterPaletteIM</string><key>InputSourceKind</key><string>Non Keyboard Input Method</string></dict>' \
'<dict><key>Bundle ID</key><string>com.apple.KeyboardViewer</string><key>InputSourceKind</key><string>Non Keyboard Input Method</string></dict>' \
'<dict><key>Bundle ID</key><string>com.apple.inputmethod.EmojiFunctionRowItem</string><key>InputSourceKind</key><string>Non Keyboard Input Method</string></dict>'
# automatically switch to a document's input source
defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict-add TextInputGlobalPropertyPerContextInput -bool true

# DICTATION
# Shortcut: [Off]
setKey 164 false 65535 65535 0
