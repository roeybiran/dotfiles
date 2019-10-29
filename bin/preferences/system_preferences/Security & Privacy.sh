#!/bin/bash

data=$(cat <<EOF
at.obdev.LaunchBar	/Applications/LaunchBar.app	Accessibility	SystemPolicyAllFiles
at.obdev.LaunchBar-AppleScript-Runner	/Applications/LaunchBar.app/Contents/Resources/LaunchBar AppleScript Runner.app	Accessibility	SystemPolicyAllFiles
com.apple.systemevents	/System/Library/CoreServices/System Events.app	Accessibility
com.apple.Terminal	/Applications/Utilities/Terminal.app	Accessibility	SystemPolicyAllFiles
com.contextsformac.Contexts	/Applications/Contexts.app	Accessibility
com.getdropbox.dropbox	/Applications/Dropbox.app	Accessibility
com.googlecode.iterm2	/Applications/iTerm.app	Accessibility	SystemPolicyAllFiles
com.latenightsw.ScriptDebugger7	/Applications/Script Debugger.app	Accessibility	SystemPolicyAllFiles
com.microsoft.VSCode	/Applications/Visual Studio Code.app	Accessibility	SystemPolicyAllFiles
com.pfiddlesoft.uibrowser	/Applications/UI Browser.app	Accessibility
com.stclairsoft.DefaultFolderX5	/Applications/Default Folder X.app	Accessibility	SystemPolicyAllFiles
io.sipapp.Sip-paddle	/Applications/Sip.app	Accessibility
org.hammerspoon.Hammerspoon	/Applications/Hammerspoon.app	Accessibility	SystemPolicyAllFiles
EOF
)

TCCDB="$(sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" "SELECT service, client, allowed FROM access;" ".exit")"

for SERVICE in 'Accessibility' 'SystemPolicyAllFiles'
do
  ARR=()
  targetFolder="${HOME}/.apps_${SERVICE}"
  mkdir -p "${targetFolder}"
  while IFS=$'\n\t' read -r id path permissions; do
	permission=$(grep --only-matching "${SERVICE}" <<< "${permissions}")
	if [[ -n "${permission}" ]]; then
		if ! printf "%s\n" "${TCCDB}" | grep --silent "kTCCService${permission}|${id}|1"; then
			if [[ "${path}" == *".app" ]]
			then
				source="${path}"
			else
				source="$(dirname "${path}")"
			fi
			ln -sf "${source}" "${targetFolder}"
			ARR+=("$(basename "${path}")")
	  fi
	fi
  done <<< "${data}"

  if [[ "${#ARR[@]}" -gt 0 ]]; then

		case "${SERVICE}" in
			"Accessibility")
			anchor="Privacy_Accessibility"
			;;
			"SystemPolicyAllFiles")
			anchor="Privacy_AllFiles"
			;;
			"ListenEvent")
			anchor="Privacy_Assistive"
			;;
		esac

		/usr/bin/osascript - "${SERVICE}" ".apps_${SERVICE}" "${anchor}" "${ARR[*]}" &>/dev/null <<-EOF
			on run argv
				try
					set theTitle to item 1 of argv
					set targetFolder to item 2 of argv
					set theAnchor to item 3 of argv

					set theSymlinks to (items 4 thru (count argv) of argv)
					set hfsList to {}
					repeat with aLink in theSymlinks
						set theLink to (path to home folder as text) & targetFolder & ":" & aLink
						set end of hfsList to theLink
					end repeat

					set {saveTID, text item delimiters of AppleScript} to {text item delimiters of AppleScript, {", "}}
					set theSymlinks to theSymlinks as text
					set AppleScript's text item delimiters to saveTID

					set theDialog to display dialog theTitle & ": access required for " & theSymlinks & ". Click OK to begin auth process."
					if button returned of theDialog is not "OK" then return
					tell application "Finder"
						reveal hfsList
						activate
					end tell
					tell application "System Preferences"
						reveal anchor theAnchor of pane id "com.apple.preference.security"
						activate
						authorize current pane
					end tell
				on error number -128
					return
				end try
			end run
		EOF
  fi
done

### REMOVE APPS FROM QUARATINE ###
allApps="$(ls -l@ /Applications)"
quarantinedApps=$(python - "${allApps}" <<-EOF
import sys
import re
apps = sys.argv[1]
apps = apps.split("drw")
appsToApprove = []
for app in apps:
    if re.search('com.apple.quarantine', app):
        app = app.split('\n')[0]
        app = re.split(r'(\s+)', app)
        app = ''.join(app[16:])
        appsToApprove.append(app)
print '\n'.join(appsToApprove)
EOF
)

if [[ -n "${quarantinedApps}" ]]; then
	while IFS=$'\n' read -r app; do
		sudo /usr/bin/xattr -r -d "com.apple.quarantine" "/Applications/${app}"
	done <<< "${quarantinedApps}"
fi

# Turn On Firewall
sudo defaults write "/Library/Preferences/com.apple.alf" globalstate -int 1

# Make sure File Vault is on
startupDisk=$(bless -getBoot); startupDisk="${startupDisk##*/}"
diskutilXML=$(diskutil apfs list -plist)
if ! python - "${startupDisk}" "${diskutilXML}" <<-EOF
import sys
import plistlib
xml = plistlib.readPlistFromString(sys.argv[2])
for volume in xml["Containers"][0]["Volumes"]:
    if volume["DeviceIdentifier"] == sys.argv[1]:
        if not volume["FileVault"]:
            sys.exit(1)
        else:
            sys.exit(0)
EOF
then
  open -b "${TERMID}"
	echo "FileVault is turned off. Enable in System Preferences? (y/n)"
  read -r reply
  if [[ "${reply}" == [Yy] ]]; then
    /usr/bin/osascript -e 'tell application "System Preferences"' \
    -e 'reveal anchor "FDE" of pane id "com.apple.preference.security"' \
    -e 'authorize current pane' \
    -e 'activate' \
    -e 'end tell' 2>/dev/null
  fi
fi

# [✓] Require password [immediately] after sleep or screen saver begins
if [[ "${IGNITION_MODE}" ]]; then
	/usr/bin/osascript -e 'Tell application "Terminal" to activate'
	printf "%s" "To require password [immediately] after sleep or screen saver begins, "
	sysadminctl -screenLock immediate -password -
fi
