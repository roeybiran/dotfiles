#!/bin/bash

osascript -e 'tell application "System Preferences" to quit'
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

magenta "Configuring Applications"

NOW="$(date +%s)"

/usr/libexec/PlistBuddy -c "Add :preferencesLastRunTimes dict" "${DOTFILES_PREFS}" &>/dev/null

for script in "${APPS_DIR}/"*.sh "${PANES_DIR}/"*.sh "${PREFS_DIR}/"*.sh; do

	lastModifiedDate="$(date -r "${script}" +%s)"
	scriptName="$(basename "${script}")"
	scriptNameNoExtension="${scriptName%.*}"

	lastRunDate="$(/usr/libexec/PlistBuddy -c "Print :preferencesLastRunTimes:\"${scriptName}\"" "${DOTFILES_PREFS}" 2>/dev/null)"
	if [[ -z "${lastRunDate}" ]]
	then
		lastRunDate=0
	fi

	if [[ "${lastModifiedDate}" -gt "${lastRunDate}" ]] || [[ "${2}" == "-f" ]]; then
		green "${scriptNameNoExtension}"
		"${script}"
		/usr/libexec/PlistBuddy -c "Delete :preferencesLastRunTimes:\"${scriptName}\"" "${DOTFILES_PREFS}" 2>/dev/null
		/usr/libexec/PlistBuddy -c "Add :preferencesLastRunTimes:\"${scriptName}\" integer ${NOW}" "${DOTFILES_PREFS}" 2>/dev/null
	fi

done

# # set +x
