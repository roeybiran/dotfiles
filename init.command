#!/bin/bash

# init.command - https://github.com/roybrian

#************************************************#
# Variables			 						     #
#************************************************#

# colored output
red='\033[0;31m'
green='\033[0;32m'
magenta='\033[95m'
yellow='\033[93m'
blue='\033[34m'
nc='\033[0m'

current_os=$(system_profiler SPSoftwareDataType | grep "System Version"); current_os="${current_os#*.}"; current_os="${current_os%.*}"

if [[ "${current_os}" -ge 14 ]]; then
	current_os="mojave"
else
	current_os="highsierra"
fi

name_of_me=$(basename "${BASH_SOURCE[0]}")
path_to_my_parent="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # no trailing slash
path_to_me="${path_to_my_parent}/${name_of_me}"
errlog=$(mktemp)

#************************************************#
# Imports				 					     #
#************************************************#

source "${path_to_my_parent}/data/secrets.sh"

#************************************************#
# Testing Area			 					     #
#************************************************#

loadscript () {
	osascript - "${path_to_me}" <<-EOF
	on run { thisScript }
	set thisScript to quoted form of thisScript
		tell application "Terminal"
			activate
			tell window 1
				if busy or history contains "[Process completed]" then
					do script "source " & thisScript & " --menu"
				else
					do script "source " & thisScript & " --menu" in window 1
				end if
			end tell
		end tell
	end run
	EOF
}

red_msg () {
	echo -e ${red}"${1}"${nc}
}

green_msg () {
	echo -e ${green}"${1}"${nc}
}

checkfile () {
	if [[ ! -e "${1}" ]]; then
		red_msg "Could not locate \"${1}\"." >> "${errlog}"
		return 1
	else
		green_msg "\"${1}\" exists and valid." >> "${errlog}"
		return 0
	fi
}

config3 () {

	while IFS=$'\t' read util plist key type value; do
		# comments and empty lines
		if [[ "${util}" == "#"* ]] || [[ -z "${util}" ]]; then
			continue
		# defaults
		elif [[ "${util}" == "dfw"* ]]; then
			# if the settings depends on the existence of a file
			if [[ "${util}" == "dfw_file" ]]; then
				if ! checkfile "${value}"; then
					continue
				fi
			fi
		 	defaults write "${plist}" "${key}" "${type}" "${value}"
		 elif [[ "${util}" == "plb" ]]; then
		 	/usr/libexec/PlistBuddy -c "Delete ${key}" "${plist}" 2>/dev/null
	 		/usr/libexec/PlistBuddy -c "Add ${key} ${type} ${value}" "${plist}"
 		else
 			red_msg "Error: could not parse ${plist} ${key} ${type} ${value}"
		fi
	done <<< "${1}"
}

#************************************************#
# Global Functions			 					 #
#************************************************#

mas_uninstall () {
	# $1 is the numeric code for the MAS app
	# this converts it to the app's name
	osascript -e 'tell application "Terminal" to activate'
	app_name=$(mas info "${1}" | head -n 1 | rev | cut -d' ' -f3- | rev)
	app_path="/Applications/${app_name}.app"
	osascript - "${app_path}" <<-EOF &>/dev/null
		on run { theApp }
			set theFile to POSIX file theApp as alias
			tell application "Finder" to delete theFile
		end run
	EOF

	if [[ $? -eq 0 ]]; then
		echo -e ${green}"${app_name} has been uninstalled."${nc}
	else
		echo -e ${red}"${app_name} failed to uninstall."${nc}
		return 1
	fi

}

listcompare () {
	# package managers installations
	# function takes 4 arguments
		# $1: my list of apps
		# $2: currently installed apps
		# $3: the utility's install command
		# $4: the utility's uninstall command

	echo -e $magenta"${1}"$nc
	# declare the arrays
	list_a=()
	list_b=()

	# make an array out of my list
	# ignoring comments
	while IFS= read -r item; do
		if [[ "${item}" != "#"* ]]; then
	  		list_a+=("${item}")
	  	fi
	done < "${2}"

	# make an array out of existing packages
	while IFS= read -r item; do
		list_b+=("${item}")
	done <<< "${3}"

	# find commons
	for (( i = 0; i < "${#list_a[@]}"; i++ )); do

		for (( j = 0; j < "${#list_b[@]}"; j++ )); do

			# if a given app in my list has a match, remove both fron the array
			if [[ "${list_a[i]}" == "${list_b[j]}" ]]; then

				echo -e $green"${list_a[i]} is in both lists"$nc

				unset 'list_a[i]'
				unset 'list_b[j]'

				list_b=("${list_b[@]}")
				list_a=("${list_a[@]}")

				# resetting i to 0 doesnt work
				i=-1

				# terminate this loop and resume its parent
				continue 2

			fi

		done

		# if we reached here, it means that a given app in MY list didnt have a match:
		# so we'll install it, and remove it from the array
		eval "${4}" "${list_a[i]}"
		unset 'list_a[i]'
		list_a=("${list_a[@]}")
		# resetting i to 0 doesnt work
		i=-1

	done

	# the remainig apps here are to be removed
	for item_to_remove in "${list_b[@]}"; do
		eval "${5}" "${item_to_remove}"
	done
}

open_updated_file () {
	# uses `mdls` to check if the 'last opened date' attribute is older than the 'modified date' attribute. if so, opens the file
	last_opened_date=$(mdls "${1}" | grep -E "kMDItemLastUsedDate\s" | awk '{print $3" "$4}')
	modified_date=$(mdls "${1}" | grep "kMDItemContentModificationDate" | awk '{print $3" "$4}')
	if [[ "${modified_date}" > "${last_opened_date}" ]]; then
		open "${1}"
	fi
}

#************************************************#
# Start 			 						     #
#************************************************#

start () {
	# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
	osascript -e 'tell application "System Preferences" to quit'

	# Ask for the administrator password upfront
	sudo -v

	# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

	# miscs
	# "Disable the “Are you sure you want to open this application?” dialog" (- Mathias Bynens)
	defaults write com.apple.LaunchServices LSQuarantine -bool false
	# "Disable the crash reporter" (- Mathias Bynens)
	defaults write com.apple.CrashReporter DialogType -string "none"
	# "Set Help Viewer windows to non-floating mode" (- Mathias Bynens)
	defaults write com.apple.helpviewer DevMode -bool true
	# "Save to disk (not to iCloud) by default" (- Mathias Bynens)
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
	# "Show language menu in the top right corner of the boot screen" (- Mathias Bynens)
	sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
}

#************************************************#
# Ignition 			 						     #
#************************************************#

ignition () {
	ignition_mode=1
}

installations () {
	# Install Homebrew + Xcode Command Line Tools
	if ! which brew &>/dev/null; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	# Install pip
	if ! which pip &>/dev/null; then
		sudo easy_install pip
	fi

	# brew
	brewlist=$(brew leaves)
	listcompare "configuring Brew" "${path_to_my_parent}/data/brew.txt" "${brewlist}" "brew install" "brew uninstall"

	# brew cask
	casklist=$(brew cask list -1)
	listcompare "configuring Cask" "${path_to_my_parent}/data/cask.txt" "${casklist}" "brew cask install" "brew cask uninstall"

	# mas
	maslist=$(mas list | cut -d' ' -f1)
	listcompare "configuring MAS" "${path_to_my_parent}/data/mas.txt" "${maslist}" "mas install"  "mas_uninstall"

	# npm
	npmlist=$(npm list -g -depth 0 | grep -v "npm" | grep -v "/" | sed "s/^[^ ]* //g;s/\(.*\)@.*/\1/" | perl -pi -e "chomp if eof" 2>/dev/null)
	listcompare "configuring npm" "${path_to_my_parent}/data/npm.txt" "${npmlist}" "npm install --global" "npm -g uninstall"

	# pip
	piplist=$(pip list --user --not-required | tail -n+3 | sed 's/ .*$//')
	listcompare "configuring pip" "${path_to_my_parent}/data/pip.txt" "${piplist}" "pip install --user" "pip uninstall -y"

	brew update
	brew upgrade
	brew cask upgrade
	mas upgrade
	brew cleanup


	# Safari Extensions from Extension Gallery
	# sVim
	if [[ ! -e ~/Library/Safari/Extensions/sVim.safariextz ]]; then
		open "https://safari-extensions.apple.com/details/?id=com.flipxfx.svim-6Q2K7JYUZ6" #sVim
		echo -e ${yellow}'Pausing execution until the "sVim" Safari extensions has been installed.'
		echo -e "Once installed, press any key and/or ⮐  to continue."${nc}
		read
	fi

	# Alerter

}

#************************************************#
# Security 			 						 	 #
#************************************************#

security () {

	# remove the "are you sure you want to open" warning for all 3rd party apps
	_apps=$(mdfind -onlyin /Applications "kMDItemContentType == 'com.apple.application-bundle'")
	while IFS= read -r _app; do
	  _md=$(mdls "${_app}" | grep "kMDItemCFBundleIdentifier")
	  if ! [[ "${_md}" == *"com.apple."* ]]; then
	    sudo xattr -r -d com.apple.quarantine "${_app}"
	  fi
	done <<< "${_apps}"

	# dir to store symlinks
	accessibility_dir="${HOME}/.apps_with_accessibility_access"
	mkdir "${accessibility_dir}" 2>/dev/null

	# dir to store symlinks
	fulldiskaccess_dir="${HOME}/.apps_full_disk_accesss"
	mkdir "${fulldiskaccess_dir}" 2>/dev/null

	# flags
	auth_accessibility=0
	auth_fulldiskaccess=0

	# strings to display in user prompt
	accessibility_app_names=""
	fulldiskaccess_app_names=""

	# read relevant entries from the TCC.db database
	# the resulting arrays will contain the bundle ids of all currently installed apps that have assistive/full disk access ENABLED.
	while IFS= read -r line; do
		if [[ "${line}" == "kTCCServiceAccessibility|"* ]]; then
			line="${line##kTCCServiceAccessibility|}"; line="${line%%|*}"
			accessibility_array+=("${line}")
		elif [[ "${line}" == "kTCCServiceSystemPolicyAllFiles|"* ]]; then
			line="${line##kTCCServiceSystemPolicyAllFiles|}"; line="${line%%|*}"
			fulldiskaccess_array+=("${line}")
		else
			:
		fi
	done < <(sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db 'select * from access')

	# read data from my files
	while IFS=$'\t' read -r path id; do
			if ! echo "${accessibility_array[@]}" | grep --silent "${id}"; then
				ln -s "${path}" "${accessibility_dir}" 2>/dev/null
				auth_accessibility=1
				app_name=$(basename "${path}")
				accessibility_app_names="${accessibility_app_names}${app_name}, "
			fi
	done < ~/Dropbox/dotfiles/data/apps_accessibility.txt

	if [[ "${current_os}" == "mojave" ]]; then
		while IFS=$'\t' read -r path id; do
				if ! echo "${fulldiskaccess_array[@]}" | grep --silent "${id}" ; then
					ln -s "${path}" "${fulldiskaccess_dir}" 2>/dev/null
					auth_fulldiskaccess=1
					app_name=$(basename "${path}")
					fulldiskaccess_app_names="${fulldiskaccess_app_names}${app_name}, "
				fi
		done < ~/Dropbox/dotfiles/data/apps_fulldiskaccess.txt
	fi

	if [[ "${auth_accessibility}" -eq 1 ]] || [[ "${auth_fulldiskaccess}" -eq 1 ]]; then
		osascript - "${auth_accessibility}" "${accessibility_dir}" "${accessibility_app_names}" \
		"${auth_fulldiskaccess}" "${fulldiskaccess_dir}" "${fulldiskaccess_app_names}" <<-EOF &
		on run {authAccessibility, accessibilityDir, accessibilityAppNames, authFullDiskAccess, fullDiskAccessDir, fullDiskAccessAppNames}
			if authAccessibility = "1" then
				if (button returned of (display dialog accessibilityAppNames & " require assitive access. Press OK to proceed." buttons {"Cancel", "OK"} default button "OK") is "OK") then
					do shell script "open " & accessibilityDir
					tell application "System Preferences"
						reveal anchor "Privacy_Accessibility" of pane id "com.apple.preference.security"
						activate
						authorize current pane
					end tell
				end if
			end if
			if authFullDiskAccess = "1" then
				if (button returned of (display dialog fullDiskAccessAppNames & " require full disk access. Press OK to proceed." buttons {"Cancel", "OK"} default button "OK") is "OK") then
					do shell script "open " & fullDiskAccessDir
					tell application "System Preferences"
						reveal anchor "Privacy_AllFiles" of pane id "com.apple.preference.security"
						activate
						authorize current pane
					end tell
				end if
			end if
		end run
		EOF
	fi

	# Firewall
	# Turn On Firewall
	sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

	if [[ "${ignition_mode}" -eq 1 ]]; then
		# Security & Privacy
		# General
		# [✓] Require password [immediately] after sleep or screen saver begins
		sysadminctl -screenLock immediate -password -
	fi

}

#************************************************#
# Apps config 			 						 #
#************************************************#

app_Adobe_Lightroom_Classic_CC () {
	_prefs="
	# Turn off various prompts
	dfw	com.adobe.LightroomClassicCC7	doNotShowPrompts	-string	exitDialog,lrupdate_doNotShowKeyFor_8.0,AgLibrary_relaunchLightroomForNewLibrary,
	dfw	com.adobe.LightroomClassicCC7	lrupdate_doNotShowKeyFor_8.0	-string	ok
	# Turn off tips
	dfw	com.adobe.LightroomClassicCC7	AgTipsDlg_TurnOffTips	-bool	true"
	config3 "${_prefs}"
}

app_Amphetamine () {

	_prefs="
	# [ ] Show this window at launch
	dfw	com.if.Amphetamine	Show Welcome Window	-int	0
	# hide in the dock
	dfw	com.if.Amphetamine	Hide Dock Icon	-int	1
	# Left-click to show menu, right click to start/end session
	dfw	com.if.Amphetamine	Status Item Click	-int	0
	# [✓] Start a new session when Amphetamine launches
	dfw	com.if.Amphetamine	Start Session At Launch	-int	1
	# During a session, send a reminder...
	dfw	com.if.Amphetamine	Enable Session Notifications	-int	1
	# Icon Style: [Owl]
	dfw	com.if.Amphetamine	Icon Style	-int	9
	# [✓] Show session time remaining in system menu/status bar
	dfw	com.if.Amphetamine	Show Session Time In Status Bar	-int	1
	# [✓] Use 24-hour clock
	dfw	com.if.Amphetamine	Use 24 Hour Clock	-int	1"
	config3 "${_prefs}"
}

app_AppCleaner () {
	_prefs="# update automatically
	dfw	net.freemacsoft.AppCleaner	SUAutomaticallyUpdate	-bool	true
	dfw	net.freemacsoft.AppCleaner	SUEnableAutomaticChecks	-bool	true
	dfw	net.freemacsoft.AppCleaner	SUHasLaunchedBefore	-bool	true"
	config3 "${_prefs}"
}

app_Bartender_3 () {
	
	_prefs="
	# apps to show
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:AppleTextInputExtra:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.flexibits.fantastical2.mac:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.bjango.istatmenus.statuscom.bjango.istatmenus.combined:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:AirPortExtra:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:AppleBluetoothExtra:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:AppleVolumeExtra:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.getdropbox.dropbox:controlled	integer	3
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.macility.typinator2:controlled	integer	3
	
	# apps to hide
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.agilebits.onepassword7:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.apple.Spotlight:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.flexibits.cardhop.mac:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.runningwithcrayons.Alfred-3:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.stairways.keyboardmaestro.engine:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.stclairsoft.DefaultFolderX5:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.mailbutler.app:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:com.udoncode.copiedmac:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:DisplaysExtra:controlled	integer	1
	plb	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	:appSettings:org.pqrs.Karabiner-Menu:controlled	integer	1
	
	# Bartender menu bar icon [Bartender]
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	statusBarImageNamed	-string	Bartender
	
	# [✓] Decrease check for...
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	ReduceUpdateCheckFrequencyWhenOnBattery	-bool	true
	
	# Disable the welcome screen
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	UpdateWelcomeMessageShowAgain	-bool	true
	
	# Automatically update
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	SUAutomaticallyUpdate	-bool	true
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	SUHasLaunchedBefore	-bool	true
	
	# license
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	license2	-string	${_bartender_license}
	dfw	$HOME/Library/Preferences/com.surteesstudios.Bartender.plist	license2HoldersName	-string	${_bartender_user}"

	config3 "${_prefs}"
}

app_BetterZip () {

	_prefs="
	# [ ] Tell macOS to open archives in BetterZip
	# [ ] Add a BetterZip button to Finder's toolbar
	# [ ] Add services... to the macOS services menu
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBFirstStart	-int	100
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBMoreOptions	-bool	false

	# [✓] Quit after the last window...
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBShouldTerminateAfterLastWindowClosed2	-bool	true

	# [✓] Opening an archive from the Finder immediately extracts it
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBDirectExtractByDefault	-bool	true

	# Update automatically
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	SUAutomaticallyUpdate	-bool	true
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	SUEnableAutomaticChecks	-bool	true
	dfw	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	SUHasLaunchedBefore	-bool	true

	# Extraction presets
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets	array
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0	dict
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:closeWindow	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:favorite	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:reveal	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:folder	string	1
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:imageTint	data	040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a656374008584016301840466666666008322bf173f83926f0d3d0186
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:isService	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:isToolbar	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:moveArchiveTo	string	1
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:name	string	Extract
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:openExtracted	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:overwriteWithoutWarning	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:resolutionFiles	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:resolutionFolders	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:shortName	string	Ex&Trash
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBExtractPresets:0:tag	integer	9

	# Save presets
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets	array
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0	dict
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:additionalParams	string	
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:cleanPattern	string	*/.svn;*/CVS;*/.git
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:closeWindow	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:compression	integer	2
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:encryption	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:favorite	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:folder	string	1
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:format	bool	false
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:imageTint	data	040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a656374008584016301840466666666008322bf173f83926f0d3d0186
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:isService	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:isToolbar	bool	true
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:name	string	Zip & Clean
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:shortName	string	Zip/Clean
	plb	$HOME/Library/Preferences/com.macitbetter.betterzip.plist	MIBSavePresets:0:tag	integer	15

	# Quick Look
	# Dont exapnd packages
	dfw	com.macitbetter.betterzip.quicklookgenerator-config	showPackageContents	-bool	false
	
	# Dont show hidden files
	dfw	com.macitbetter.betterzip.quicklookgenerator-config	showHiddenFiles	-bool	false
	
	# license
	dfw	com.macitbetter.betterzip	MIBRegCode	-string	${_betterzip_license}"

	config3 "${_prefs}"

	}

app_Cardhop () {
	_prefs="
	# Hide Cardhop in Dock
	dfw	com.flexibits.cardhop.mac	HideInDock	-bool	true

	# Keyboard shortcut: [Record Shortcut]
	dfw	com.flexibits.cardhop.mac	HotKeyEmpty	-int	1

	# Skip first run setup
	dfw	com.flexibits.cardhop.mac	FirstRunSetup	-bool	true

	# Update automatically
	dfw	com.flexibits.cardhop.mac	SUAutomaticallyUpdate	-bool	true
	dfw	com.flexibits.cardhop.mac	SUEnableAutomaticChecks	-bool	true
	dfw	com.flexibits.cardhop.mac	SUHasLaunchedBefore	-bool	true

	# Allow dialing local numbers
	dfw	com.flexibits.cardhop.mac	AllowDialingLocalNumbers	-bool	true
	dfw	com.flexibits.cardhop.mac	Code	-string	${_cardhop_license}
	dfw	com.flexibits.cardhop.mac	Name	-string	${_cardhop_user}"

	config3 "${_prefs}"
}

app_Contexts () {
	_prefs="
	# Keyboard Layout [ABC]
	dfw	com.contextsformac.Contexts	CTPreferenceInputSourceIdToUse	-string	com.apple.keylayout.ABC

	# Show Sidebar on: (·) No display
	dfw	com.contextsformac.Contexts	CTPreferenceSidebarDisplayMode	-string	CTDisplayModeNone

	# [ ] Auto adjust windows widths so they are not overlapped by Siderbar
	dfw	com.contextsformac.Contexts	CTPreferenceWorkspaceConstrainWindowFrames	-bool	false

	# [ ] Moving the cursor over Panel changes the selected item
	dfw	com.contextsformac.Contexts	CTPreferencePanelChangeSelectionOnScrollEnabled	-bool	false

	# [ ] Scrolling when Panel is visible changes the selected item
	dfw	com.contextsformac.Contexts	CTPreferencePanelUpdatesSelectionOnMouseMove	-bool	false

	# Search with: [ ] [Control-Space]
	dfw	com.contextsformac.Contexts	CTKeyboardEventCommandModeActive	-bool	false

	# Fast Search with: [ ] Fn-<characters>
	dfw	com.contextsformac.Contexts	CTPreferenceSearchShortcutFunctionKeyEnabled	-bool	false

	# Define basic hotkeys: move up list with [Shift-Command-Tab], disable Command-Backtick
	dfw	com.contextsformac.Contexts	CTPreferenceSwitchers	-data	62706c6973743030d40102030405066b6c582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0af10170708112122282f32333438434447494a5354575963656855246e756c6cd2090a0b105a4e532e6f626a656374735624636c617373a40c0d0e0f8002800a800f80138016d80a12131415161718191a1b1a1d1a1f205f10176d696e696d697a656457696e646f7773446973706c617957656e61626c65645f101a77696e646f776c65737350726f636573736573446973706c61795c6e65787453686f72746375745f101468696464656e57696e646f7773446973706c61795c7370616365734f7074696f6e5f101070726576696f757353686f72746375748009800880038008800480088007800609d3230a24252627574b6579436f64655d4d6f646966696572466c616773103080051200100000d2292a2b2c5a24636c6173736e616d655824636c61737365735a435453686f7274637574a32b2d2e5b4d415353686f7274637574584e534f626a656374d3230a24252631800512001200005f101143545370616365734f7074696f6e416c6c5f101343544974656d446973706c61794e6f726d616cd2292a35365a43545377697463686572a2372e5a43545377697463686572d9390a131415121617183a193c1a3e1a1a1f425f10196e6f6e61637469766550726f636573736573446973706c6179800e8009800b8008800c800880088007800d1000d3230a2445262710328005d3230a2445263180055f101343544974656d446973706c617948696464656ed80a12131415161718191a4d1a4f1a1f528009800880108008801180088007801208d3230a2425265680051200080000d3230a244526568005d9390a131415121617183a194d1a5e1a1a1f62800e80098010800880148008800880078015d3230a244526568005d3230a24452667800512000a0000d2292a696a574e534172726179a2692e5f100f4e534b657965644172636869766572d16d6e54726f6f74800100080011001a0023002d0032003700510057005c0067006e0073007500770079007b007d008e00a800b000cd00da00f100fe01110113011501170119011b011d011f0121012201290131013f014101430148014d01580161016c0170017c0185018c018e019301a701bd01c201cd01d001db01ee020a020c020e02100212021402160218021a021c021e0225022702290230023202480259025b025d025f02610263026502670269026a027102730278027f0281029402960298029a029c029e02a002a202a402a602ad02af02b602b802bd02c202ca02cd02df02e202e70000000000000201000000000000006f000000000000000000000000000002e9

	# [✓] Typing characters starts Fast Search when Panel is visible
	dfw	com.contextsformac.Contexts	CTPreferenceRecentItemsSwitcherSearchEnabled	-bool	true"

	config3 "${_prefs}"
}

app_Dash () {

	_prefs="
	# sync folder
	dfw_file	com.kapeli.dashdoc	syncFolderPath	-string	${HOME}/Dropbox/dotfiles/extra/dash
	# snippets file
	dfw_file	com.kapeli.dashdoc	snippetSQLPath	-string	${HOME}/Dropbox/dotfiles/extra/dash/snippets.dash

	# syncing options
	dfw	com.kapeli.dashdoc	shouldSyncBookmarks	-bool	true
	dfw	com.kapeli.dashdoc	shouldSyncDocsets	-bool	true
	dfw	com.kapeli.dashdoc	shouldSyncGeneral	-bool	true
	dfw	com.kapeli.dashdoc	shouldSyncView	-bool	true

	# Surpress the docsets tooltip
	dfw	com.kapeli.dashdoc	DHNotificationDocsetPressEnterOrClickIconTip	-bool	true
	# Surpress table of contexts tooltip
	dfw	com.kapeli.dashdoc	DHNotificationTableOfContentsTip	-bool	true
	# Surpress nested contents tooltip
	dfw	com.kapeli.dashdoc	DHNotificationNestedResultTip	-bool	true
	# surpress find in page tooltip
	dfw	com.kapeli.dashdoc	DHNotificationFindTip	-bool	true
	# surpress the menu bar icon tooltip
	dfw	com.kapeli.dashdoc	didShowStatusIconHello	-bool	true

	# dark style for docs
	dfw	com.kapeli.dashdoc	actuallyDarkWebView	-bool	true

	# Automatically update
	dfw	com.kapeli.dashdoc	SUAutomaticallyUpdate	-bool	true
	dfw	com.kapeli.dashdoc	SUEnableAutomaticChecks	-bool	true
	dfw	com.kapeli.dashdoc	SUHasLaunchedBefore	-bool	true"

	config3 "${_prefs}"
}

app_Default_Folder_X () {

	_prefs="
	# List folders before files
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	menusSortFoldersFirst	-bool	true
	# Disable Finder-click
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	finderClick	-bool	false
	# Don't show extra info below Open dialogs
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	toolbarShowAttributesOnOpen	-bool	false
	# Don't show extra info below Save dialogs
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	toolbarShowAttributesOnSave	-bool	false
	# Open folders in Finder's frontmost window
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	openInFrontFinderWindow	-bool	true
	# Automatically update
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	SUEnableAutomaticChecks	-bool	true
	dfw	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	SUAutomaticallyUpdate	-bool	true
	# shortcuts
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings	array
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:0	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:0:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:0:name	string	Copy Folder Path to Clipboard
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:0:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:0:action	string	copyPathOfFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:1	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:1:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:1:name	string	Copy Folder Name to Clipboard
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:1:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:1:action	string	copyNameOfFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:2	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:2:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:2:name	string	Duplicate
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:2:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:2:action	string	duplicateSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:3	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:3:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:3:name	string	Make Alias
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:3:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:3:action	string	aliasSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:4	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:4:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:4:name	string	Copy Selected Path to Clipboard
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:4:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:4:action	string	copyPathOfSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:5	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:5:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:5:name	string	Copy Selected Name to Clipboard
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:5:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:5:action	string	copyNameOfSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:6	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:6:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:6:name	string	Compress
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:6:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:6:action	string	zipSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:7	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:7:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:7:name	string	Uncompress
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:7:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:7:action	string	unzipSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:8	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:8:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:8:name	string	Quicklook
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:8:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:8:action	string	quicklookSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:9	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:9:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:9:name	string	Preferences
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:9:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:9:action	string	showPreferences:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:10	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:10:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:10:name	string	Add to Favorites
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:10:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:10:action	string	addToFavorites:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:11	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:11:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:11:name	string	Remove From Favorites
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:11:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:11:action	string	removeFromFavorites:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:12	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:12:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:12:name	string	Go to Application Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:12:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:12:action	string	switchToApplicationFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:13	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:13:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:13:name	string	Set Default Folder for Application
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:13:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:13:action	string	setDefaultFolderForApp:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:14	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:14:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:14:name	string	Set Default Folder for Application & File Type
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:14:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:14:action	string	setDefaultFolderForAppAndType:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:15	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:15:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:15:name	string	Set Default Folder for File Type
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:15:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:15:action	string	setDefaultFolderForType:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:16	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:16:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:16:name	string	Show Utility Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:16:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:16:action	string	showUtilityMenu:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:17	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:17:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:17:name	string	Show Computer Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:17:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:17:action	string	showComputerMenu:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:18	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:18:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:18:name	string	Show Favorites Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:18:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:18:action	string	showFavoritesMenu:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:19	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:19:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:19:name	string	Show Recent Folder Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:19:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:19:action	string	showRecentFolderMenu:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:20	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:20:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:20:name	string	Show Recent File Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:20:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:20:action	string	showRecentFileMenu:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:21	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:21:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:21:name	string	Show Finder Window Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:21:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:21:action	string	showFinderWindowMenu:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:22	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:22:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:22:name	string	Show / Hide Toolbar
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:22:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:22:action	string	toggleToolbar:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:23	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:23:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:23:name	string	Enter Tags
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:23:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:23:action	string	selectTagField:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:24	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:24:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:24:name	string	Enter Comments
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:24:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:24:action	string	selectCommentField:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:25	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:25:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:25:name	string	Add to Favorites
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:25:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:25:action	string	addToFavoritesInFinder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:26	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:26:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:26:name	string	Remove From Favorites
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:26:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:26:action	string	removeFromFavoritesInFinder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:27	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:27:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:27:name	string	Show / Hide Finder Drawer
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:27:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:27:action	string	toggleFinderBezel:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:28	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:28:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:28:name	string	Switch to Previous Folder Set
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:28:context	integer	5
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:28:action	string	switchToPreviousFolderSet:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:29	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:29:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:29:name	string	Switch to Next Folder Set
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:29:context	integer	5
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:29:action	string	switchToNextFolderSet:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:30	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:30:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:30:name	string	Show Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:30:context	integer	4
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:30:action	string	showMenuSystemWide:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:name	string	File Dialog Menu Commands
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:31:action	string	groupName:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:name	string	File Dialog Menu Commands
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:32:action	string	groupName:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:name	string	File Dialog Menu Commands
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:33:action	string	groupName:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:name	string	File Dialog Menu Commands
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:34:action	string	groupName:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:name	string	File Dialog Menu Commands
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:35:action	string	groupName:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:name	string	Open in Finder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:36:action	string	finderOpenFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:name	string	New Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:37:action	string	createNewFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:name	string	Rename
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:38:action	string	renameSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:name	string	Copy
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:39:action	string	copySelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:name	string	Move
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:40:action	string	moveSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:name	string	Get Info
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:41:action	string	getInfoOnSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:name	string	Show in Finder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:42:action	string	revealSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:name	string	Move to Trash
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:43:action	string	trashSelection:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:name	string	Desktop
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:44:action	string	goToDesktop:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:name	string	Home
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:45:action	string	goToHome:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:name	string	iCloud
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:46:action	string	goToICloud:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:name	string	Go to Default Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:47:action	string	switchToDefaultFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:name	string	Previous Recent Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:48:action	string	goToPreviousRecentFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:name	string	Next Recent Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:49:action	string	goToNextRecentFolder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:name	string	Previous Finder Window
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:50:action	string	goToPreviousFinderWindow:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:name	string	Next Finder Window
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:context	integer	1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:51:action	string	goToNextFinderWindow:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:name	string	Previous Recent Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:52:action	string	goToPreviousRecentFolderInFinder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:name	string	Next Recent Folder
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:53:action	string	goToNextRecentFolderInFinder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:name	string	Previous Finder Window
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:54:action	string	goToPreviousFinderWindowInFinder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:name	string	Next Finder Window
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:55:action	string	goToNextFinderWindowInFinder:
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:key	dict
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:key:charactersIgnoringModifiers	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:key:characters	string
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:key:keyCode	string	-1
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:key:modifierFlags	integer	0
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:name	string	Show Menu
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:context	integer	2
	plb	$HOME/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist	:keyBindings:56:action	string	showMenu:"

	config3 "${_prefs}"

	# ?
	# ~/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist askedToLaunchAtLogin -bool true
	# ~/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist askedToRemoveV4 -bool true
}

app_duti () {	
	while IFS=$'\t' read -r bundleid uti role; do
		if [[ "${bundleid}" != "#"* ]]; then
			duti -s "${bundleid}" "${uti}" "${role}"
		fi
	done < "${path_to_my_parent}/data/duti.txt"
}

app_FastScripts () {
	# remove /Library/Scripts from FastScripts
	defaults write com.red-sweater.fastscripts ScriptTreePathsKey '("~/Library/Scripts")'
}

app_Fantastical_2 () {
	
	_prefs="
	# Default Event Duration [0 Minutes]
	dfw	com.flexibits.fantastical2.mac	DefaultEventDuration	-float	0
	# Weeks per month: [4]
	dfw	com.flexibits.fantastical2.mac	WeeksPerMonth	-int	4
	# Mini window keyboard shortcut: [Record shortcut]
	dfw	com.flexibits.fantastical2.mac	HotKeyEmpty	-bool	true

	# [✓] Hide Fantastical in Dock
	dfw	com.flexibits.fantastical2.mac	HideDockIcon	-bool	true
	# Menu bar icon shows: Date & Weekday
	dfw	com.flexibits.fantastical2.mac	StatusItemBadge	-string	StatusItemStyleDateAndWeekday

	# automatically download and install updates
	dfw	com.flexibits.fantastical2.mac	SUAutomaticallyUpdate	-bool	true
	dfw	com.flexibits.fantastical2.mac	Registration	-string	${_fantastical2_license}
	dfw	com.flexibits.fantastical2.mac	User	-string	${_fantastical2_user}"

	config3 "${_prefs}"
}

app_IINA () {
	
	_prefs="# [✓] Quit after all...
	dfw	com.colliderli.iina	quitWhenNoOpenedWindow	-bool	true
	# [ ] Resume last playback...
	dfw	com.colliderli.iina	resumeLastPosition	-bool	false
	# [✓] Check for updates [Daily]
	dfw	com.colliderli.iina	SUEnableAutomaticChecks	-bool	true
	# [✓] Receive beta updates
	dfw	com.colliderli.iina	receiveBetaUpdate	-bool	true
	# [ ] Play next item automatically
	dfw	com.colliderli.iina	playlistAutoPlayNext	-bool	false
	# enable automatic updates
	dfw	com.colliderli.iina	SUAutomaticallyUpdate	-bool	true"

	config3 "${_prefs}"
}

app_iStat_Menus () {

	if checkfile "${HOME}/Dropbox/dotfiles/extra/istat_menus/iStat Menus Settings.ismp"; then
		open_updated_file "${HOME}/Dropbox/dotfiles/extra/istat_menus/iStat Menus Settings.ismp"
	fi
}

app_Karabiner-Elements () {

	# start on login
	launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server
}

app_Keyboard_Maestro () {
	
	_prefs="# [ ] Show this window when...
	dfw	com.stairways.keyboardmaestro.editor	DisplayWelcomeWindow	-bool	false
	# [✓] Launch Engine at Login
	# [ ] Show Applications Palette
	dfw	com.stairways.keyboardmaestro.engine	ShowApplicationsPalette	-bool	false
	# Surpress the Send Contact Info window
	dfw	com.stairways.keyboardmaestro.editor	SentContactInfo	-bool	true
	# Disable the Macro Cancelled notification
	dfw	com.stairways.keyboardmaestro.engine	Notification-MacroCancelled	-bool	false
	# macros sync file
	dfw_file	com.stairways.keyboardmaestro.editor	MacroSharingFile	-string	${HOME}/Dropbox/dotfiles/extra/keyboard_maestro/Keyboard Maestro Macros.kmsync
	# license
	dfw	com.stairways.keyboardmaestro	Username	-string	${_keyboard_maestro_user}
	dfw	com.stairways.keyboardmaestro	Serial	-string	${_keyboard_maestro_license}"

	config3 "${_prefs}"

	# Expose Keyboard Maestro to $PATH + set $USER
	osascript - "${PATH}" "${USER}"	<<-EOF
	on run { pathVar, userVar  }
		tell application "Keyboard Maestro Engine"
			setvariable "ENV_PATH" to pathVar
			setvariable "ENV_USER" to userVar
		end tell
	end run
	EOF
	
}

app_LaunchBar () {

	_prefs="
	# Switch to Open Location... [Leading Dot Only]
	# at.obdev.LaunchBar	OpenLocationMode	-bool	true

	# Show all subtitles
	dfw	at.obdev.LaunchBar	ShowItemListSubtitles	-bool	true

	# [ ] Search in Spotlight
	dfw	at.obdev.LaunchBar	SpotlightHotKeyEnabled	-bool	false

	# Instant Send: [Double Shift]
	dfw	at.obdev.LaunchBar	ModifierTapInstantSend	-int	24

	# alternative arrow keys: none
	dfw	at.obdev.LaunchBar	ControlKeyNavigationMode	-string	-1

	# instant info browsing
	dfw	at.obdev.LaunchBar	InstantInfoBrowsing	-bool	true

	# instant-open folders: browse in LaunchBar
	dfw	at.obdev.LaunchBar	InstantOpenBrowseFolders	-bool	true

	# open applescripts with editor
	dfw	at.obdev.LaunchBar	RunAppleScripts	-bool	false

	# open automator workflows with automator
	dfw	at.obdev.LaunchBar	RunWorkflows	-bool	false

	# Open contacts in Cardhop
	dfw	at.obdev.LaunchBar	ShowInAddressBookURLPrefix	-string	x-cardhop://show?id=

	# Phone numbers: call with iPhone
	dfw	at.obdev.LaunchBar	PhoneHandler	-string	%@/Contents/Resources/Actions/Call with iPhone.lbaction

	# [✓] Show files and folders in currnet Finder window
	dfw	at.obdev.LaunchBar	UseCurrentFileBrowserWindow	-bool	true

	# [✓] Open URLs in current Safari window/tab
	# at.obdev.LaunchBar	UseCurrentWebBrowserDocument	-bool	true

	# preferred file browser: finder
	dfw	at.obdev.LaunchBar	PreferredFileBrowser	-int	1

	# create calendar events with fantastical
	dfw	at.obdev.LaunchBar	CalendarEventParser	-int	1

	# create emails with Mail
	dfw	at.obdev.LaunchBar	EmailHandler	-string	com.apple.mail

	# don't switch to calculator when typing digits
	dfw	at.obdev.LaunchBar	SwitchToCalculatorAutomatically	-bool	false

	# clipboard capacity: 1 week
	dfw	at.obdev.LaunchBar	ClipboardHistoryCapacity	-string	-7

	# make the clipboard ignore apps
	dfw	at.obdev.LaunchBar	ClipboardHistoryIgnoreApplicationsEnabled	-bool	true

	# [✓] Show clipboard history: ⌃⌥⇧⌘V
	dfw	at.obdev.LaunchBar	ShowClipboardHistoryHotKey	-string	6912@9

	# [ ] Select from history
	dfw	at.obdev.LaunchBar	SelectFromClipboardHistoryHotKeyEnabled	-bool	false

	# [ ] Paste and remove from history
	dfw	at.obdev.LaunchBar	PasteClipboardHistoryHotKeyEnabled	-bool	false

	# [✓] Abbreviate home folder with ~ in copied paths
	dfw	at.obdev.LaunchBar	AbbreviateFilePaths	-bool	true

	# [✓] Convert filename extension to lowercase when renaming
	dfw	at.obdev.LaunchBar	RenameConvertsExtensionToLowercase	-bool	true

	# [ ] Show Dock Icon
	dfw	at.obdev.LaunchBar	ShowDockIcon	-bool	false

	# Preferred input source: [ABC]
	dfw	at.obdev.LaunchBar	PreferredKeyboardInputSource	-string	com.apple.keylayout.ABC

	# Skip the welcome window
	dfw	at.obdev.LaunchBar	WelcomeWindowVersion	-int	2

	# set personal bundle identifier for LaunchBars action editor
	dfw	at.obdev.LaunchBar.ActionEditor	myBundleIdentifier	-string	com.rb"

	config3 "${_prefs}"

	# ignore these apps in clipboard history
	defaults write at.obdev.LaunchBar ClipboardHistoryIgnoreApplications -array com.apple.keychainaccess com.agilebits.onepassword
}

app_MAMP () {
	
	_prefs="# don't show the pop up page
	dfw	de.appsolute.MAMP	checkForMampPro	-bool	false
	# start servers on launch
	dfw	de.appsolute.MAMP	startServers	-bool	true
	# don't open WebStart page
	dfw	de.appsolute.MAMP	openPage	-bool	false"

	config3 "${_prefs}"

	# # Uninstall MAMP Pro
	if [[ -a "/Applications/MAMP PRO.app/Contents/MacOS/MAMP PRO Uninstaller.app" ]]; then
		open -a "/Applications/MAMP PRO.app/Contents/MacOS/MAMP PRO Uninstaller.app"
	fi
}

app_Script_Debugger () {
	_prefs="
	# For New Documents: (·) Use template: AppleScript
	dfw	com.latenightsw.ScriptDebugger7	PrefDefaultTemplate	-string	/Applications/Script Debugger.app/Contents/Library/Templates/AppleScript/AppleScript/AppleScript.sdtemplate
	dfw	com.latenightsw.ScriptDebugger7	PrefUseDefaultTemplate	-bool	true
	# Text Substituions: [ ] Enabled
	dfw	com.latenightsw.ScriptDebugger7	PrefEditorDoTextSubstitution	-bool	false
	# Dont bring to foreground when script ends
	dfw	com.latenightsw.ScriptDebugger7	PrefActivateOnScriptEnd	-bool	false
	# Dont bring to foreground when script pauses
	dfw	com.latenightsw.ScriptDebugger7	PrefActivateOnScriptPause	-bool	false
	# Enable automatic updates
	dfw	com.latenightsw.ScriptDebugger7	SUAutomaticallyUpdate	-bool	true
	dfw	com.latenightsw.ScriptDebugger7	SUHasLaunchedBefore	-bool	true"

	config3 "${_prefs}"

	/usr/libexec/PlistBuddy -c "Delete LNSUserDefaultsKeyEquivs" ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doComment\::key string "/"' ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doComment\::mask integer 1048576' ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doUncomment\::key string "/"' ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doUncomment\::mask integer 1572864' ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoNextTab\::key string \"\\t\"" ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist 
	/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoNextTab\::mask integer 262144" ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoPrevTab\::key string \"\\t\"" ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist
	/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoPrevTab\::mask integer 393216" ~/Library/Preferences/com.latenightsw.ScriptDebugger7.plist

}

app_Sip () {

	_prefs="
	# skip welcome window
	dfw	io.sipapp.Sip-paddle	kUserdefaultsShowOnboard	-bool	false
	# show color dock on bottom left
	dfw	io.sipapp.Sip-paddle	kUserdefaultsColorDockFrame	-string	{{-36, -22}, {86, 467}}
	dfw	io.sipapp.Sip-paddle	kUserdefaultsColorDockOrientation	-string	vertical
	dfw	io.sipapp.Sip-paddle	kUserdefaultsColorDockPosition	-string	left
	# Update automatically
	dfw	io.sipapp.Sip-paddle	SUAutomaticallyUpdate	-bool	true
	dfw	io.sipapp.Sip-paddle	SUEnableAutomaticChecks	-bool	true
	dfw	io.sipapp.Sip-paddle	SUHasLaunchedBefore	-bool	true
	dfw	io.sipapp.Sip-paddle	SUHasLaunchedBefore	-bool	true
	# license
	dfw	io.sipapp.Sip-paddle	kUserdefaultsLicenseSerial	-string	${_sip_license}
	dfw	io.sipapp.Sip-paddle	kUserdefaultsLicenseState	-integer	6"

	config3 "${_prefs}"
}

app_Soulver () {
	_prefs="
	# [✓] Suppress save warning for unsaved documents
	dfw	com.acqualia.soulver	SVSuppressSaveAlert	-bool	true
	# Automatically update
	dfw	com.acqualia.soulver	SUEnableAutomaticChecks	-bool	false
	# Surpress the welcome window
	dfw	com.acqualia.soulver	SVShowWelcomeWindowOnLaunch	-bool	false
	# Skip tutorial
	dfw	com.acqualia.soulver	SVTutorialHasRun	-bool	true"

	config3 "${_prefs}"
}

app_Typinator () {
	_prefs="# --- [ ] Open window when Typinator starts --- #
	dfw	com.macility.typinator2	Open Window at Start	-bool	false
	# --- Show Window [---] --- #
	dfw	com.macility.typinator2	showWindowHotkey	-string
	# --- Pause Expansions [---] --- #
	dfw	com.macility.typinator2	pauseHotkey	-string
	# --- Quick Search [---] --- #
	dfw	com.macility.typinator2	quickSearchHotkey	-string
	# --- Create new item from... Selection [---] --- #
	dfw	com.macility.typinator2	defineSelectionHotkey	-string
	# --- Check for available updates: [never] --- #
	dfw	com.macility.typinator2	updateInterval	-string	0"

	config3 "${_prefs}"
}

app_UI_Browser () {

	_prefs="
	# Accessibility names: (·) Technical
	dfw	com.pfiddlesoft.uibrowser	Terminology style	-int	1

	# [✓] Copy script to clipboard (·) Always
	dfw	com.pfiddlesoft.uibrowser	Copy new script to clipboard	-bool	true

	# [✓] Send script to script editor (·) Always
	dfw	com.pfiddlesoft.uibrowser	Send new script to script editor	-bool	true

	# [✓] Include application process
	dfw	com.pfiddlesoft.uibrowser	New script includes process reference	-bool	true

	# [ ] Hot keys active
	dfw	com.pfiddlesoft.uibrowser	Hotkeys active	-bool	false

	# defaults write com.pfiddlesoft.uibrowser Application hotkey Control down	-bool	false
	# defaults write com.pfiddlesoft.uibrowser Application hotkey modifier flags	-int	1048576
	# defaults write com.pfiddlesoft.uibrowser Systemwide hotkey Control down	-bool	false
	# defaults write com.pfiddlesoft.uibrowser Systemwide hotkey modifier flags	-int	1048576

	# Don‘t show
	dfw	com.pfiddlesoft.uibrowser	noOptionalAlertsSuppressed	-bool	false

	# Don‘t show
	dfw	com.pfiddlesoft.uibrowser	targetApplicationTerminatedAlertSuppressed	-bool	true

	# Don‘t show the ‘UI Element Destroyed‘ pop-up
	dfw	com.pfiddlesoft.uibrowser	selectedElementDestroyedAlertSuppressed	-bool	true

	# Don‘t show
	dfw	com.pfiddlesoft.uibrowser	applescriptWindowOpenAlertSuppressed	-bool	true

	# skip welcome
	dfw	com.pfiddlesoft.uibrowser	First run	-bool	false

	# Send scripts to Script Debugger
	dfw	com.pfiddlesoft.uibrowser	Use AppleScript URL Protocol	-bool	false
	dfw	com.pfiddlesoft.uibrowser	Use AppleScript default script editor	-bool	false
	dfw	com.pfiddlesoft.uibrowser	Default script editor	-bool	true
	dfw	com.pfiddlesoft.uibrowser	Ignore AppleScript default script editor	-bool	true

	# license
	dfw	com.pfiddlesoft.uibrowser	EProduct	-string	uibrowser5457
	dfw	com.pfiddlesoft.uibrowser	EKey	-string	${_ui_browser_license}
	dfw	com.pfiddlesoft.uibrowser	EName	-string	${_ui_browser_user}"

	config3 "${_prefs}"
}

app_StopTheMadness () {
	if checkfile "${HOME}/Dropbox/dotfiles/extra/stopthemadness/StopTheMadness Website Protections.stopthemadness"; then
		open_updated_file "${HOME}/Dropbox/dotfiles/extra/stopthemadness/StopTheMadness Website Protections.stopthemadness"
	fi
}

app_MailButler () {

	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGFollowUpShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGLinkTrackingShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGNoteShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGPreviewShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGSendLaterShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGSnippetShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGSnoozeShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGTaskShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGTemplateShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGTrackingShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0
	defaults write ~/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist "FGUndoSendShortcut" -dict "characters" -string "" "charactersIgnoringModifiers" -string "" "keyCode" -string "-1" "modifierFlags" -int 0

	_prefs="
	# automatically update
	dfw	$HOME/Library/Preferences/com.mailbutler.app.plist	SUAutomaticallyUpdate	-bool	true
	dfw	$HOME/Library/Preferences/com.mailbutler.app.plist	SUHasLaunchedBefore	-bool	true
	# disable various tooltips
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGSkipPopoverTutorial	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGSuppressUnsubscribeWarning	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGSettingsOnce	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedAddNoteButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedAddTaskButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedComposeTemplateButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedContactInfoButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedFollowUpButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedLinkTracking	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedMessageSnippetsButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedNoteButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedReadTracking	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedSendLaterButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedSnoozeButton	-bool	true
	dfw	$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/com.mailbutler.mailplugin.plist	FGShowedTaskButton	-bool	true"

	config3 "${_prefs}"

}

########################################
# Apple Apps                           #
########################################

apple_Pages () {
	# skip welcome screen
	defaults write com.apple.iWork.Pages TMAFirstLaunchVersion -integer 65550
}

apple_Keynote () {
	defaults write com.apple.iWork.Keynote TMAFirstLaunchVersion -integer 65550
}

apple_Numbers () {
	defaults write com.apple.iWork.Numbers TMAFirstLaunchVersion -integer 65550
}

apple_Voice_Memos () {
 	defaults write com.apple.VoiceMemos voicememos.welcome.last_completed -string 2.0
}

apple_Finder () {

	# Show the ~/Library folder
	xattr -d com.apple.FinderInfo ~/Library 2>/dev/null
	chflags nohidden ~/Library
	# Show the /Volumes folder ( - M. Bynens )
	sudo chflags nohidden /Volumes

	# View Settings (Mojave+)
	# Finder
		# global views
		# Columns
			# sort options
				# name: dnam
				# kind: kipl
				# date last opened: ludt
				# date added: pAdd
				# date modified: modd
				# date created: ascd
				# size: logs
				# tags: ftat
		# per-container views
			# computer
				# icons
				# list
				# gallery
			# desktop
				# icons
			# icloud
				# icons
				# list
				# gallery
			# search
				# icons
				# list
				# gallery
			# recents
				# icons
				# list
				# gallery
			# standard
				# icons
				# list
				# gallery
			# trash
				# icons
				# list
				# gallery
	# FinderKit
	# global views
		# columns
		# per-container views
			# Default
				# icons
				# list
			# iCloud
				# icons
				# list
			# Recents
				# icons
				# list
			# Search
				# icons
				# list
	# sorting options
	# columns
		# kind: kipl
		# date last opened: ludt
		# date added: pAdd
		# date modified: modd
		# date created: ascd
		# size: logs
		# tags: ftat
	# icons
		# Date Modified ('Date' in the gui)
		# Name
		# Tags

	# create the initla dictionaries
	for container in \
		:ComputerViewSettings \
		:DesktopViewSettings \
		:ICloudViewSettings \
		:SearchRecentsViewSettings \
		:SearchViewSettings \
		:StandardViewSettings \
		:TrashViewSettings \
	; do
		config3 "plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}	dict"
	done

	# icons view settings
	for container in \
		:ComputerViewSettings \
		:DesktopViewSettings \
		:ICloudViewSettings \
		:SearchRecentsViewSettings \
		:SearchViewSettings \
		:StandardViewSettings \
		:TrashViewSettings \
	; do
		_prefs="
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:arrangeBy	string	kind
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:backgroundColorBlue	real	1.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:backgroundColorGreen	real	1.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:backgroundColorRed	real	1.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:backgroundType	integer	0
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:gridOffsetX	real	0.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:gridOffsetY	real	0.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:gridSpacing	real	54.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:iconSize	real	64.0000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:labelOnBottom	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:showIconPreview	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:showItemInfo	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:textSize	real	12.0000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:viewOptionsVersion	integer	1"
		config3 "${_prefs}"
	done

	# list ('ExtendedListViewSettingsV2' + 'ListViewSettings') + gallery view settings + 'WindowState'
	for container in \
		:ComputerViewSettings \
		:ICloudViewSettings \
		:SearchRecentsViewSettings \
		:SearchViewSettings \
		:StandardViewSettings \
		:TrashViewSettings \
	; do
		_prefs="
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:calculateAllSizes	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns	array
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:0	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:0:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:0:identifier	string	name
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:0:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:0:width	integer	292
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:1	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:1:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:1:identifier	string	ubiquity
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:1:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:1:width	integer	35
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:2	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:2:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:2:identifier	string	dateModified
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:2:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:2:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:3	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:3:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:3:identifier	string	dateCreated
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:3:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:3:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:4	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:4:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:4:identifier	string	size
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:4:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:4:width	integer	97
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:5	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:5:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:5:identifier	string	kind
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:5:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:5:width	integer	115
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:6	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:6:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:6:identifier	string	label
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:6:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:6:width	integer	100
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:7	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:7:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:7:identifier	string	version
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:7:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:7:width	integer	75
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:8	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:8:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:8:identifier	string	comments
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:8:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:8:width	integer	300
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:9	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:9:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:9:identifier	string	dateAdded
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:9:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:9:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:10	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:10:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:10:identifier	string	dateLastOpened
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:10:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:columns:10:width	integer	200
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:iconSize	real	16.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:showIconPreview	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:sortColumn	string	kind
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:textSize	real	12.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:useRelativeDates	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:viewOptionsVersion	integer	1
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:GalleryViewSettings	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:GalleryViewSettings:arrangeBy	integer	6
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:GalleryViewSettings:iconSize	real	48.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:GalleryViewSettings:showIconPreview	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:GalleryViewSettings:viewOptionsVersion	integer	1
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:calculateAllSizes	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:comments	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:comments:index	integer	7
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:comments:width	integer	300
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:comments:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:comments:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateCreated	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateCreated:index	integer	2
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateCreated:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateCreated:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateCreated:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateLastOpened	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateLastOpened:index	integer	8
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateLastOpened:width	integer	200
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateLastOpened:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateLastOpened:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateModified	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateModified:index	integer	1
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateModified:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateModified:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:dateModified:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:kind	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:kind:index	integer	4
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:kind:width	integer	115
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:kind:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:kind:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:label	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:label:index	integer	5
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:label:width	integer	100
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:label:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:label:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:name	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:name:index	integer	0
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:name:width	integer	292
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:name:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:name:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:size	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:size:index	integer	3
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:size:width	integer	97
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:size:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:size:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:version	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:version:index	integer	6
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:version:width	integer	75
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:version:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:columns:version:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:iconSize	real	16.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:showIconPreview	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:sortColumn	string	kind
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:textSize	real	12.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:useRelativeDates	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ListViewSettings:viewOptionsVersion	integer	1
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:ContainerShowSidebar	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:ShowPathbar	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:ShowSidebar	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:ShowStatusBar	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:ShowTabView	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:ShowToolbar	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:WindowState:WindowBounds	string"
		config3 "${_prefs}"
	done

	# Search + Trash: arrange by date added in all views
	for container in \
		:SearchViewSettings \
		:TrashViewSettings \
	; do
		_prefs="
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:GalleryViewSettings:arrangeBy	integer	4
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:ExtendedListViewSettingsV2:sortColumn	string	dateAdded
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:IconViewSettings:arrangeBy	string	dateAdded"
		config3 "${_prefs}"
	done

	# FinderKit list view settings
	for container in \
		:FK_DefaultListViewSettingsV2 \
		:FK_SearchListViewSettingsV2 \
		:FK_RecentsListViewSettingsV2 \
		:FK_iCloudListViewSettingsV2 \
	; do
		_prefs="
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns	array
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:0	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:0:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:0:identifier	string	name
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:0:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:0:width	integer	406
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:1	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:1:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:1:identifier	string	ubiquity
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:1:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:1:width	integer	35
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:2	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:2:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:2:identifier	string	dateModified
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:2:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:2:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:3	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:3:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:3:identifier	string	dateCreated
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:3:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:3:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:4	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:4:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:4:identifier	string	size
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:4:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:4:width	integer	97
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:5	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:5:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:5:identifier	string	kind
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:5:visible	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:5:width	integer	115
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:6	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:6:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:6:identifier	string	label
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:6:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:6:width	integer	100
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:7	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:7:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:7:identifier	string	version
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:7:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:7:width	integer	75
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:8	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:8:ascending	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:8:identifier	string	comments
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:8:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:8:width	integer	300
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:9	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:9:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:9:identifier	string	dateLastOpened
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:9:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:9:width	integer	200
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:10	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:10:ascending	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:10:identifier	string	dateAdded
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:10:visible	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:columns:10:width	integer	181
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:calculateAllSizes	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:iconSize	real	16.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:showIconPreview	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:sortColumn	string	dateModified
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:textSize	real	12.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:useRelativeDates	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:viewOptionsVersion	integer	1"
		config3 "${_prefs}"
	done

	# FinderKit icon view settings
	for container in \
		:FK_DefaultIconViewSettings \
		:FK_SearchIconViewSettings \
		:FK_RecentsIconViewSettings \
		:FK_iCloudIconViewSettings \
	; do
		_prefs="
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}	dict
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:arrangeBy	string	dateModified
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:backgroundColorBlue	real	1.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:backgroundColorGreen	real	1.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:backgroundColorRed	real	1.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:backgroundType	integer	0
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:gridOffsetX	real	0.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:gridOffsetY	real	0.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:gridSpacing	real	54.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:iconSize	real	64.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:labelOnBottom	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:showIconPreview	bool	true
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:showItemInfo	bool	false
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:textSize	real	12.000000
		plb	$HOME/Library/Preferences/com.apple.finder.plist	${container}:viewOptionsVersion	integer	1"
		config3 "${_prefs}"
	done


	local _prefs="
	#************************************************#
	# Finder Preferences			                 #
	#************************************************#

	# Show these items on the desktop
	# [ ] Hard Disks
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	ShowHardDrivesOnDesktop	-bool	false
	# [ ] External disks
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	ShowExternalHardDrivesOnDesktop	-bool	false
	# [ ] CDs, DVDs, and iPods
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	ShowRemovableMediaOnDesktop	-bool	false

	# New Finder windows show: [Desktop]
	dfw	${HOME}/Library/Preferences/com.apple.finder.plist	NewWindowTarget	-string	PfDe
	dfw	${HOME}/Library/Preferences/com.apple.finder.plist	NewWindowTargetPath	-string	file://${HOME}/Desktop/

	# [✓] Show all filename extensions
	dfw	NSGlobalDomain	AppleShowAllExtensions	-bool	true

	# [ ] Show warning before changing an extension
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXEnableExtensionChangeWarning	-bool	false

	# [ ] Show warning before removing from iCloud Drive
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXEnableRemoveFromICloudDriveWarning	-bool	false

	# [✓] Keep folders on top: In windows when sorting by name
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	_FXSortFoldersFirst	-bool	true

	# When performing a search: [Search the Current Folder]
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXDefaultSearchScope	-string	SCcf

	# Always ‘Show More‘ in the preview pane
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	PreviewPaneInfoExpanded	-bool	true

	#************************************************#
	# Menu Bar/View       			                 #
	#************************************************#

	# Show Path Bar [✓]
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	ShowPathbar	-bool	true

	# Show Status Bar [✓]
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	ShowStatusBar	-bool	true

	# Show Preview
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	ShowPreviewPane	-bool	true

	#************************************************#
	# View Preferences			                     #
	#************************************************#

	# Sort by Kind in all Finder windows by default
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXArrangeGroupViewBy	-string	Kind

	# Group by ‘None‘, so folder disclosure arrows are visible
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXPreferredGroupBy	-string	None

	# Use list view in all Finder windows by default
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXPreferredViewStyle	-string	Nlsv

	# Use List View in Search
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXPreferredSearchViewStyle	-string	Nlsv
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FXPreferredSearchViewStyleVersion	-string	%00%00%00%01

	# Recents
	# Use List View
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	SearchRecentsSavedViewStyle	-string	Nlsv
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	SearchRecentsSavedViewStyleVersion	-string	%00%00%00%01
	# Sort by Date Last Opened
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	RecentsArrangeGroupViewBy	-string	Date Last Opened

	# All containers: Columns View + Gallery View
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions	dict
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions:ColumnViewOptions	dict
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions:ColumnViewOptions:ArrangeBy	string	kipl
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions:ColumnViewOptions:SharedArrangeBy	string	kipl
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions:GalleryViewOptions	dict
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions:GalleryViewOptions:ShowTitles	bool	true
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:StandardViewOptions:GalleryViewOptions:ShowPreviewPane	bool	true

	# specific containers
	# must be run after the main prefs have been set

	# iCloud
	# Show the ‘iCloud Status‘ column
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:ICloudViewSettings:ExtendedListViewSettingsV2:columns:1:visible	bool	true

	# Recents
	# restore the Date Last Opened column
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:SearchRecentsViewSettings:ExtendedListViewSettingsV2:columns:10:visible	bool	true
	# change sort order back to Date Last Opened, in all views
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:SearchRecentsViewSettings:ExtendedListViewSettingsV2:sortColumn	string	dateLastOpened
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:SearchRecentsViewSettings:ListViewSettings:sortColumn	string	dateLastOpened
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:SearchRecentsViewSettings:GalleryViewSettings:arrangeBy	integer	3
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:SearchRecentsViewSettings:IconViewSettings:arrangeBy	string	dateLastOpened

	#************************************************#
	# FinderKit - Open/Save Dialogs                  #
	#************************************************#

	# Show the Sidebar
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FK_AppCentricShowSidebar	-bool	true

	# Group by ‘None‘, so folder disclosure arrows are visible
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FK_ArrangeBy	-string	None
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FK_RecentsArrangeBy	-string	None
	dfw	$HOME/Library/Preferences/com.apple.finder.plist	FK_SearchArrangeBy	-string	None

	# Column View for file open dialogs
	dfw	NSGlobalDomain	NSNavPanelFileLastListModeForOpenModeKey	-int	1
	dfw	NSGlobalDomain	NSNavPanelFileListModeForOpenMode2	-int	1
	dfw	NSGlobalDomain	NavPanelFileListModeForOpenMode	-int	1

	# Column View for file save dialogs
	dfw	NSGlobalDomain	NSNavPanelFileLastListModeForSaveModeKey	-int	1
	dfw	NSGlobalDomain	NSNavPanelFileListModeForSaveMode2	-int	1
	dfw	NSGlobalDomain	NavPanelFileListModeForSaveMode	-int	1

	# Expand save panel by default
	dfw	NSGlobalDomain	NSNavPanelExpandedStateForSaveMode	-bool	true
	dfw	NSGlobalDomain	NSNavPanelExpandedStateForSaveMode2	-bool	true

	# FK_StandardViewOptions2 (AKA Column View)
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2	dict
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions	dict
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:ArrangeBy	string	pAdd
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:ColumnShowFolderArrow	bool	true
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:ColumnShowIcons	bool	true
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:ColumnWidth	integer	205
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:FontSize	integer	10
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:PreviewDisclosureState	bool	true
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:SharedArrangeBy	string	pAdd
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:ShowIconThumbnails	bool	true
	plb	$HOME/Library/Preferences/com.apple.finder.plist	:FK_StandardViewOptions2:ColumnViewOptions:ShowPreview	bool	true"
	
	config3 "${_prefs}"
	
}

apple_Calendar () {
	# Default Calendar: [iCloud]
	calendar_uid=$(osascript <<-EOF
	tell application "Calendar"
		set _uid to uid of calendar "iCloud"
		quit
	end tell
	return _uid
	EOF
	)
	current_cal=$(defaults read com.apple.iCal CalDefaultCalendar)

	if [[ "${current_cal}" != "${calendar_uid}" ]]; then
		defaults delete com.apple.iCal CalDefaultPrincipal
		defaults write com.apple.iCal CalDefaultCalendar "${calendar_uid}"
		defaults write com.apple.iCal CalDefaultCalendarSelectedByUser -bool false
	fi

	# [ ] Show alternate calendar: [Chinese]
	defaults write com.apple.iCal CALPrefOverlayCalendarIdentifier -string ""
}

apple_Dictionary () {
	# Drag reference sources into the order you prefer:
	# [✓] New Oxford American Dictionary (American English)
	# [✓] Oxford American Writer's Thesaurus (American English)
	# [✓] Wikipedia
	# [✓] Apple Dictionary
	# [✓] Hebrew
	defaults write com.apple.DictionaryServices DCSActiveDictionaries -array \
	com.apple.dictionary.NOAD \
	com.apple.dictionary.OAWT \
	/System/Library/Frameworks/CoreServices.framework/Frameworks/DictionaryServices.framework/Resources/Wikipedia.wikipediadictionary \
	com.apple.dictionary.AppleDictionary \
	com.apple.dictionary.he.oup
}

apple_Mail () {
	
	_prefs="
	# When searching all mailboxes, also include results from Junk
	dfw	com.apple.mail	IndexJunk	-bool	true

	# Expand all conversations, for all mailboxes
	# dfw	com.apple.mail	ArchiveViewerAttributes	-dict-add	DisplayInThreadedMode	-string	NO
	# dfw	com.apple.mail	DraftsViewerAttributes	-dict-add	DisplayInThreadedMode	-string	NO
	# dfw	com.apple.mail	InboxViewerAttributes	-dict-add	DisplayInThreadedMode	-string	NO
	# dfw	com.apple.mail	SentMessagesViewerAttributes	-dict-add	DisplayInThreadedMode	-string	NO
	# dfw	com.apple.mail	TrashViewerAttributes	-dict-add	DisplayInThreadedMode	-string	NO

	# Show Tab Bar
	dfw	com.apple.mail	NSWindowTabbingShoudShowTabBarKey-MouseTrackingWindow-MessageViewer-(null)-VT-FS	-bool	true

	# [✓] Check Grammar with Spelling
	dfw	com.apple.mail	CheckGrammarWithSpelling	-bool	true
	dfw	com.apple.mail	WebGrammarCheckingEnabled	-bool	true

	# [✓] Smart Links
	dfw	com.apple.mail	WebAutomaticLinkDetectionEnabled	-bool	true

	# Copy email addresses as foo@example.com instead of Foo Bar <foo@example.com> in Mail.app (- Mathias Bynens) *
	dfw	com.apple.mail	AddressesIncludeNameOnPasteboard	-bool	false

	# Disable inline attachments (just show the icons) (- Mathias Bynens) *
	dfw	com.apple.mail	DisableInlineAttachmentViewing	-bool	true

	# Set favorite mailboxes: Inbox, Sent, Drafts, All Mail, Trash, Flagged, Junk
	# dfw	com.apple.mail	Favorites	-array \
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Inbox</string><key>MailboxUidPersistentIdentifier</key><string>Inbox</string><key>MailboxUidType</key><string>100</string></dict>	\
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Sent</string><key>MailboxUidPersistentIdentifier</key><string>Sent\ Messages</string><key>MailboxUidType</key><string>102</string></dict>	\
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Drafts</string><key>MailboxUidPersistentIdentifier</key><string>Drafts</string><key>MailboxUidType</key><string>103</string></dict>	\
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Archive</string><key>MailboxUidPersistentIdentifier</key><string>Archive</string><key>MailboxUidType</key><string>109</string></dict>	\
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Trash</string><key>MailboxUidPersistentIdentifier</key><string>Trash</string><key>MailboxUidType</key><string>101</string></dict>	\
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Flagged</string><key>MailboxUidPersistentIdentifier</key><string>Flags</string><key>MailboxUidType</key><string>108</string></dict>	\
	<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Junk</string><key>MailboxUidPersistentIdentifier</key><string>Junk</string><key>MailboxUidType</key><string>105</string></dict>

	# Send new messages from:
	dfw	com.apple.mail	NewMessageFromAddress	-string	${_email}
	dfw	com.apple.mail-shared	NewMessageFromAddress	-string	${_email}"

	config3 "${_prefs}"

	# Set favorite mailboxes: Inbox, Sent, Drafts, All Mail, Trash, Flagged, Junk
	defaults write com.apple.mail Favorites -array \
	'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Inbox</string><key>MailboxUidPersistentIdentifier</key><string>Inbox</string><key>MailboxUidType</key><string>100</string></dict>' \
	'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Sent</string><key>MailboxUidPersistentIdentifier</key><string>Sent Messages</string><key>MailboxUidType</key><string>102</string></dict>' \
	'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Drafts</string><key>MailboxUidPersistentIdentifier</key><string>Drafts</string><key>MailboxUidType</key><string>103</string></dict>' \
	'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Archive</string><key>MailboxUidPersistentIdentifier</key><string>Archive</string><key>MailboxUidType</key><string>109</string></dict>' \
	'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Trash</string><key>MailboxUidPersistentIdentifier</key><string>Trash</string><key>MailboxUidType</key><string>101</string></dict>' \
	'<dict><key>IsPrefferedSelection</key><string>1</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Flagged</string><key>MailboxUidPersistentIdentifier</key><string>Flags</string><key>MailboxUidType</key><string>108</string></dict>' \
	'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Junk</string><key>MailboxUidPersistentIdentifier</key><string>Junk</string><key>MailboxUidType</key><string>105</string></dict>'

	defaults write com.apple.mail ArchiveViewerAttributes -dict-add DisplayInThreadedMode -string NO
	defaults write com.apple.mail DraftsViewerAttributes -dict-add DisplayInThreadedMode -string NO
	defaults write com.apple.mail InboxViewerAttributes -dict-add DisplayInThreadedMode -string NO
	defaults write com.apple.mail SentMessagesViewerAttributes -dict-add DisplayInThreadedMode -string NO
	defaults write com.apple.mail TrashViewerAttributes -dict-add DisplayInThreadedMode -string NO

	# Show the mailbox list
	osascript -e 'tell application "Mail" to tell first message viewer to set mailbox list visible to true' 2>/dev/null

}


apple_Messages () { 

	_prefs="
	# --- messages in the cloud --- #
	dfw	com.apple.madrid	CloudKitSyncingEnabled	-bool	true
	dfw	com.apple.madrid	enableCKSyncingV2	-bool	true
	# --- text substitutions --- #
	dfw	com.apple.sms	hasBeenApprovedForSMSRelay	-bool	true"

	config3 "${_prefs}"
		
	# --- Edit > Substitutions --- #
		# Check Spelling While Typing 
		# Correct Spelling Automatically
		# Check Grammar with Spelling
		# Smart Quotes
		# Smart Links
		# Smart Dashes
		# Data Detectors
		# Emoji
		# Text replacement
		# Smart Copy/Paste
		
	defaults write $HOME/Library/Containers/com.apple.soagent/Data/Library/Preferences/com.apple.messageshelper.MessageController.plist SOInputLineSettings -dict \
	automaticSpellingCorrectionEnabled -bool true \
	continuousSpellCheckingEnabled -bool true \
	grammarCheckingEnabled -bool true \
	automaticQuoteSubstitutionEnabled -bool true \
	automaticLinkDetectionEnabled -bool true \
	automaticDashSubstitutionEnabled -bool true \
	automaticDataDetectionEnabled -bool true \
	automaticEmojiSubstitutionEnabledLegacy -bool true \
	automaticEmojiSubstitutionEnablediMessage -bool true \
	automaticTextReplacementEnabled -bool true \
	smartInsertDeleteEnabled -bool true
}

apple_Preview () {
	_prefs="
	# Don't start on the last viewed page when opening documents
	dfw	com.apple.Preview	kPVPDFRememberPageOption	-bool	false
	# Opening for the first time: Show as [Single Page]
	dfw	com.apple.Preferences	kPVPDFDefaultPageViewModeOption	-bool	false
	dfw	com.apple.Preview	kPVPDFDefaultPageViewModeOption	-bool	true
	# Surpress the PDF cropping alert
	dfw	com.apple.Preview	PVSupressPDFCroppingAlert	-bool	true"

	config3 "${_prefs}"
}

apple_Safari () {

	if [[ "${current_os}" == "mojave" ]]; then
			_plist="$HOME/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plist"
		else
			_plist="$HOME/Library/Preferences/com.apple.Safari.Extensions.plist"
	fi

	_prefs='
	# General
	# Safari opens with: [All windows from last session]
	dfw	com.apple.Safari	AlwaysRestoreSessionAtLaunch	-bool	true

	# Remove download list items: [Upon successful download]
	dfw	com.apple.Safari	DownloadsClearingPolicy	-int	2

	# [ ] Open safe files after downloading
	dfw	com.apple.Safari	AutoOpenSafeDownloads	-bool	true

	# [✓] Show website icons in tabs
	dfw	com.apple.Safari	ShowIconsInTabs	-bool	true

	# Dont autofill username and passwords
	dfw	com.apple.Safari	AutoFillPasswords	-bool	false

	# Search
	# [ ] Smart Search Field: Show Favorites
	dfw	com.apple.Safari	ShowFavoritesUnderSmartSearchField	-bool	false

	# Smart Search Field: [✓] Show full website address
	dfw	com.apple.Safari	ShowFullURLInSmartSearchField	-bool	true

	# [✓] Show Develop menu in menu bar
	dfw	com.apple.Safari	IncludeDevelopMenu	-bool	true
	dfw	com.apple.Safari	WebKitDeveloperExtrasEnabledPreferenceKey	-bool	true
	dfw	com.apple.Safari	com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled	-bool	true

	# [✓] Show Favorites Bar
	dfw	com.apple.Safari	ShowFavoritesBar-v2	-bool	true

	# [✓] Show Tab Bar
	dfw	com.apple.Safari	AlwaysShowTabBar	-bool	true

	# [✓] Show Status Bar
	dfw	com.apple.Safari	ShowOverlayStatusBar	-bool	true

	# [✓] Check Grammar With Spelling
	dfw	com.apple.Safari	WebGrammarCheckingEnabled	-bool	true

	# [✓] Smart Quotes
	dfw	com.apple.Safari	WebAutomaticQuoteSubstitutionEnabled	-bool	true

	# [✓] Smart Dashes
	dfw	com.apple.Safari	WebAutomaticDashSubstitutionEnabled	-bool	true

	# [✓] Smart Links
	dfw	com.apple.Safari	WebAutomaticLinkDetectionEnabled	-bool	true

	# Make Safari’s search banners default to Contains instead of Starts With (- Mathias Bynens) *
	dfw	com.apple.Safari	FindOnPageMatchesWordStartsOnly	-bool	false

	# Add a context menu item for showing the Web Inspector in web views (- Mathias Bynens) *
	dfw	NSGlobalDomain	WebKitDeveloperExtras	-bool	true'

	config3 "${_prefs}"

svim_rc='\"unmapAll\\n
map \\\"f\\\" createHint\\n
map \\\"shift+f\\\" createTabbedHint\\n
map \\\"shift+,\\\" moveTabLeft\\n
map \\\"shift+.\\\" moveTabRight\\n
map \\\"g i\\\" goToInput\\n
map \\\"g u\\\" parentDirectory\\n
map \\\"g shift+u\\\" topDirectory\\n
map \\\"i\\\" insertMode\\n
map \\\"escape\\\" normalMode\"'

svim_css='\"@-webkit-keyframes fadein {\\n
  from {\\n
    opacity: 0;\\n
  }\\n
  to {\\n
    opacity: 1;\\n
  }\\n
}\\n
\\n
#sVim-command {\\n
  -webkit-animation: fadein .2s !important;\\n
  -webkit-appearance: none !important;\\n
  background-color: rgba(0, 0, 0, 0.80) !important;\\n
  background-position: none !important;\\n
  background-repeat: none !important;\\n
  border-radius: 0 !important;\\n
  border: 0 !important;\\n
  box-shadow: none !important;\\n
  box-sizing: content-box !important;\\n
  color: #FFFFFF !important;\\n
  display: none;\\n
  font-family: \"Helvetica Neue\" !important;\\n
  font-size: 13px !important;\\n
  font-style: normal !important;\\n
  left: 0 !important;\\n
  letter-spacing: normal !important;\\n
  line-height: 1 !important;\\n
  margin: 0 !important;\\n
  min-height: 0 !important;\\n
  outline-style: none !important;\\n
  outline: 0 !important;\\n
  padding: 2px 0 0 10px !important;\\n
  position: fixed !important;\\n
  right: 0 !important;\\n
  text-align: start !important;\\n
  text-indent: 0px !important;\\n
  text-shadow: none !important;\\n
  text-transform: none !important;\\n
  vertical-align: none !important;\\n
  width: 100% !important;\\n
  word-spacing: normal !important;\\n
  z-index: 2147483647 !important;\\n
}\\n
\\n
.sVim-hint {\\n
  background-color: #FFFF01;\\n
  color: #000000;\\n
  font-size: 12pt;\\n
  font-family: monospace;\\n
  line-height: 10pt;\\n
  padding: 2px;\\n
  opacity: 1;\\n
}\\n
\\n
.sVim-hint.sVim-hint-form {\\n
  background-color: #3EFEFF;\\n
}\\n
\\n
.sVim-hint.sVim-hint-focused {\\n
  opacity: 1;\\n
  font-weight: bold;\\n
}\\n
\\n
.sVim-hint.sVim-hint-hidden {\\n
  visibility: hidden;\\n
}\"'

	svim_css=${svim_css//$'\n'/}
	svim_rc=${svim_rc//$'\n'/}

	/usr/libexec/PlistBuddy -c "Delete :ExtensionSettings-com.flipxfx.svim-6Q2K7JYUZ6:css" "${_plist}"
	/usr/libexec/PlistBuddy -c "Add :ExtensionSettings-com.flipxfx.svim-6Q2K7JYUZ6:css string ${svim_css}" "${_plist}"

	/usr/libexec/PlistBuddy -c "Delete :ExtensionSettings-com.flipxfx.svim-6Q2K7JYUZ6:rc" "${_plist}"
	/usr/libexec/PlistBuddy -c "Add :ExtensionSettings-com.flipxfx.svim-6Q2K7JYUZ6:rc string ${svim_rc}" "${_plist}"

	# gui script to enable relevant extensions
	if [[ "${ignition_mode}" -eq 1 ]]; then
		osascript <<-EOF
		on run
			tell application "System Events"
				tell process "Safari"
					set frontmost to true
					click menu item "Preferences…" of menu 1 of menu bar item "Safari" of menu bar 1
					delay 0.2
					tell window 1
						click button "Extensions" of toolbar 1
						tell list 1 of UI element 1 of scroll area 1 of group 1 of group 1
							set groupList to every group
							repeat with aGroup in groupList
								if (value of attribute "AXValue" of checkbox 1 of aGroup = 0) and (value of static text 1 of group 1 of aGroup ≠ "Open in IINA") then
									click checkbox 1 of aGroup
								end if
							end repeat
						end tell
						click button 1
					end tell
					set frontmost to false
				end tell
			end tell
		end run
		EOF
	fi
}

apple_Screenshot () {
	# [ ] Remember Last Selection
	defaults write com.apple.screencapture save-selections -bool false
}

apple_Terminal () {

	for f in "${path_to_my_parent}/data/"*".terminal"; do
	 file="${f}"
	done

	if checkfile "${file}"; then

		profile_name="$(basename "${file}")"; profile_name="${profile_name%.*}"

		osascript - "${file}" "${profile_name}" <<-EOF
		on run { profilePath, profileName }
			tell application "Terminal"

				local allOpenedWindows
				local initialOpenedWindows
				local windowID
				# set themePath to quoted form of profilePath
				set themeName to profileName

				(* Store the IDs of all the open terminal windows. *)
				set initialOpenedWindows to id of every window

				(* Open the custom theme so that it gets added to the list of available terminal themes (note: this will open two additional terminal windows). *)
				do shell script "open " & quoted form of profilePath

				(* Wait a little bit to ensure that the custom theme is added. *)
				delay 1

				(* Set the custom theme as the default terminal theme. *)
				set default settings to settings set themeName

				(* Get the IDs of all the currently opened terminal windows. *)
				set allOpenedWindows to id of every window

				repeat with windowID in allOpenedWindows
					(* Close the additional windows that were opened in order to add the custom theme to the list of terminal themes. *)
					if initialOpenedWindows does not contain windowID then
						close (every window whose id is windowID)
					(* Change the theme for the initial opened terminal windows to remove the need to close them in order for the custom theme to be applied. *)
					else
						set current settings of tabs of (every window whose id is windowID) to settings set themeName
					end if
				end repeat
			end tell
		end run
		EOF
	fi
}

apple_Time_Machine () {
	# Prevent Time Machine from prompting to use new hard drives as backup volume *
	defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
}

apple_QuickTime_Player () {
	# Auto-play videos when opened with QuickTime Player *
	defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true
}

apple_Photos () {
	# Prevent Photos from opening automatically when devices are plugged in *
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

########################################
# System Preferences Panes             #
########################################

prefpane_General () {
	# Show scroll bars: (·) Always
	defaults write NSGlobalDomain AppleShowScrollBars -string Always
}

prefpane_Desktop_and_Screensaver () {
	if [[ "${current_os}" == "mojave" ]]; then
		# Set desktop to Mojave (Dynamic)
		osascript -e 'tell application "System Events" to set picture of current desktop to "/System/Library/CoreServices/DefaultDesktop.heic"'
		# osascript -e 'tell application "System Events" to set picture of current desktop to "/Library/Desktop Pictures/Solar Gradients.heic"'
	else
		# Pre-Mojave
			# [✓] Change picture: When waking from sleep
			# [✓] Random order
		osascript <<-EOF
			tell application "System Events"
			  tell current desktop
			    if (picture rotation = 3) is false then
			      set picture rotation to 3
			    end if
			    if random order is false then
			      set random order to true
			    end if
			  end tell
			end tell
		EOF
	fi
}

prefpane_Dock () {

	local _prefs="
	# Prefer tabs when opening documents: [Always]
	dfw	NSGlobalDomain	AppleWindowTabbingMode	-string	always
	# [✓] Automatically hide and show the Dock
	dfw	com.apple.dock	autohide	-bool	true
	# Show only open applications in the Dock
	dfw	com.apple.dock	static-only	-bool	true
	# Remove the auto-hiding Dock delay
	dfw	com.apple.dock	autohide-delay	-float	3600
	# minimize windows using scale effect
	dfw	com.apple.dock	mineffect	-string	scale"

	config3 "${_prefs}"
}

prefpane_Mission_Control () {
	# [✓] Group window by application
	defaults write com.apple.dock expose-group-apps -bool true
}

prefpane_Language_and_Region () {
	# Add Hebrew as an input source
	defaults write NSGlobalDomain AppleLanguages -array en-IL he-IL
	defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
	'<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>252</integer><key>KeyboardLayout Name</key><string>ABC</string></dict>' \
	'<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>-18432</integer><key>KeyboardLayout Name</key><string>Hebrew</string></dict>'
}

prefpane_Spotlight () {
	# Spotlight
	defaults write com.apple.Spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
	'{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
	'{"enabled" = 1;"name" = "MESSAGES";}' \
	'{"enabled" = 1;"name" = "CONTACT";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 1;"name" = "DOCUMENTS";}' \
	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 1;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
	'{"enabled" = 1;"name" = "MENU_OTHER";}' \
	'{"enabled" = 1;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 0;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 0;"name" = "IMAGES";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "FONTS";}'
}

prefpane_Notifications () {

	# Prolong presence of Notification Center banners
	defaults write com.apple.notificationcenterui bannerTime -int 10

	#***************#
	# NOTIFICATIONS #
	#***************#

	# Don't run as sudo!
	# Don't touch _SYSTEM_CENTER_, "com.apple.appstore" & "com.apple.TelephonyUtilities"
	# Calendar and Reminders: leave as alerts, but disable on lock screen
	# Disable Fantastical 2, with all options unchecked
	# Everything else: banners + don't show on lockscreen

	# initial flags values
	# mojave
	# apps that default to alerts + show on lock screen + always with preview: 8214 (also 8270, but rare)
		# to leave as alerts, but hide on lock screen: 12310
		# to change to banners and hide on lock screen: 12366
		# to disable completely: 28993
	# apps that default to banners + show on lock screen + always with preview: 8206
		# to leave as banners, but hide on lock screen: 12302
	# apps that default to banners + show on lock screen + preview when unlocked (Mail, Messages only): 14
		# to leave as banners but hide on lock screen: 4110

	# high sierra
		# no initial `flags` distinction between apple and 3rd party apps?
		# no initial `flags` distinction showing previews on lock screen, or not?
	# apps that default to banners + ?
		# initial flag: 14
		# to leave as a banner, but hide in lock screen
			# 4110
	# apps that default to alerts + ?
		# initial flag: 22
		# to leave as an alert, but hide in lock screen:
			# 4118
		# to change to banner and hide in lock screen:
			# 4174
		# to disable completely: set to:
			# 4417
	# apps that default to banners + show on lock screen + preview when unlocked (Mail, Messages ONLY)
	# high sierra: 'show message preview' (and sub options) only to mail+messages
	# mojave - expanded to all apps?
	# to leave as banners + hide on lock screen + keep preview
		# flags: 14
		# to leave as banner, but hide in lock screen: 4110

	# location of the notification center preferences plist for the current user
	notification_plist="${HOME}/Library/Preferences/com.apple.ncprefs.plist"

	# count of the bundles existing in the plist
	count=$(/usr/libexec/PlistBuddy -c "Print :apps" "${notification_plist}" | grep -c "bundle-id")

	# create a for loop
	for ((index=0; index<"${count}"; index++)); do
	    
	    # getting each bundle id with PlistBuddy

	    bundle_id=$(/usr/libexec/PlistBuddy -c "Print apps:${index}:bundle-id" "${notification_plist}")
		flag=$(/usr/libexec/PlistBuddy -c "Print apps:${index}:flags" "${notification_plist}")

	 # if [[]]
	case "${bundle_id}" in
	    	# leave as is
	    	*"_SYSTEM_CENTER_"*|*"_WEB_CENTER_"*|"com.apple.appstore"|"com.apple.TelephonyUtilities")
				:
				;;
			# Leave as alerts but don't show on lock screen
			"com.apple.reminders"|"com.apple.iCal")
				case "${current_os}" in
					"mojave")
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 12310" "${notification_plist}"
						;;
					"highsierra")
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 4118" "${notification_plist}"
						;;
				esac
				;;
			# Leave as banners but don't show on lock screen
			"com.apple.iChat"|"com.apple.mail")
				/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 4110" "${notification_plist}"
				;;
			# Disable completely
			"com.flexibits.fantastical2.mac")
				case "${current_os}" in
					"mojave")
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 28993" "${notification_plist}"
						;;
					"highsierra")
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 4417" "${notification_plist}"
						;;
				esac					
				;;
			# all others apps
			*)
				case "${flag}" in
					# Apps that default to "Alerts" (1Password, Dropbox):
					# Mojave
					8214|8270)
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 12366" "${notification_plist}"
						;;
					# High Sierra
					22)
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 4174" "${notification_plist}"
						;;
					# Apps that default to "Banners":
					# Mojave
					8206)
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 12302" "${notification_plist}"
						;;
					# High Sierra
					14)
						/usr/libexec/PlistBuddy -c "Set :apps:${index}:flags 4110" "${notification_plist}"
						;;
					# If app is already set with desired values
					# Mojave
					12366|12302)
						:
						;;
					# High Sierra
					4174|4110)
						:
						;;
					# else, manual check required
					*)
						echo -e ${red}"Notifications: An unknown flags value ${yellow}(${flag}) ${red}has been encountered for ${yellow}${bundle_id}${red}, manual check might be necessary."${nc} >> "${errlog}"
						;;
				esac
				;;
		esac
	done

	# Restart notification center to make changes take effect.
	killall sighup usernoted
	killall sighup NotificationCenter
}

prefpane_Energy_Saver () {
	# Enable Power Nap for laptops (while on battery power) and desktops.
	sudo pmset -a powernap 1
	# Laptops/Power Adapter: [✓] Prevent computer from sleeping automatically when the display is off
	# Desktops: [✓] Start up automatically after a power failure
	sudo pmset -a autorestart 1
}

prefpane_Keyboard () {
	# faster key repeat
	defaults write NSGlobalDomain KeyRepeat -int 6
	# smaller delay until repeat
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	# Keyboard
	# Touch Bar shows [F1, F2, etc. Keys]
	defaults write com.apple.touchbar.agent PresentationModeGlobal -string functionKeys
	# Press Fn key to [Show Control Strip]
	defaults write com.apple.touchbar.agent PresentationModeFnModes -dict appWithControlStrip -string fullControlStrip functionKeys -string fullControlStrip
	# [✓] Use F1, F2, etc. keys as standard function keys
	# [✓] Use F1, F2, etc. keys as standard function keys on external keyboards
	defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
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
	# Text
	# Spelling: [U.S. English]
	defaults write NSGlobalDomain NSPreferredSpellServerLanguage -string en
	defaults write NSGlobalDomain NSPreferredSpellServerVendors -dict en -string Apple
	defaults write NSGlobalDomain NSSpellCheckerAutomaticallyIdentifiesLanguages -bool false
	# [ ] Use smart quotes and dashes
	defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true
	# Full Keyboard Access: [All controls]
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

	# Shortcuts (and Services' Shortcuts)
	# Usage: [shortcut's index] [parameter 1] [parameter 2] [parameter 3]

	local _prefs="
	# Launchpad & Dock
	# [ ] Turn Dock Hiding On/Off [⌥⌘D]
	false	52	100	2	1572864
	# Display
	# [ ] Decrease display brightness [F14]
	false	53	65535	107	8388608
	false	55	65535	107	8912896
	# [ ] Increase display brightness [F15]
	false	54	65535	113	8388608
	false	56	65535	113	8912896
	# Mission Control
	# [ ] Show Dashboard
	false	62	65535	111	8388608
	false	63	65535	111	8519680
	# [ ] Move left a space: [⌃←]
	false	79	65535	123	8650752
	# [ ] Move right a space: [⌃→] 
	false	81	65535	124	8650752
	# [ ] Switch to Desktop 1: [⌃1]
	false	118	65535	18	262144
	# Keyboard
	# [ ] Turn keyboard access on or off [⌃F1]
	false	12	65535	122	8650752
	# [✓] Move focus to the menu bar [⇧⌘1]
	true	7	49	18	1179648
	# [✓] Move focus to the Dock [⌥⌘D]
	true	8	100	2	1572864
	# [✓] Move focus to active or next window [⇧⌘4]
	true	9	52	21	1179648
	# [✓] Move focus to window toolbar [⇧⌘2]
	true	10	50	19	1179648
	# [✓] Move focus to the floating window [⇧⌘3]
	true	11	51	20	1179648
	# Input Sources
	# [✓] Select the previous input source: [^Space]
	true	60	32	49	262144
	# [ ] Select the next source in Input menu
	false	61	32	49	786432
	# Screenshots
	# [ ] Save picture of screen as a file
	false	28	51	20	1179648
	# [ ] Copy picture of screen to the clipboard
	false	29	51	20	1441792
	# [ ] Save picture of selected area as a file
	false	30	52	21	1179648
	# [ ] Copy picture of selected area to the clipboard
	false	31	52	21	1441792
	# [ ] Screenshot and recording options
	false	181	54	22	1179648
	# [ ] Save picture of the Touch Bar as a file
	false	182	54	22	1441792
	# [ ] Save picture of the Touch Bar to the clipboard
	false	184	53	23	1179648
	# Spotlight
	# [✓] Show Spotlight search: [⌥Space]
	true	64	32	49	524288
	# [ ] Show Finder search window: [⌥⌘Space]
	false	65	32	49	1572864
	# Accessibility
	# [ ] Turn VoiceOver on or off [⌘F5]
	false	59	65535	96	9437184
	# [ ] Show Accessibility controls [⌥⌘F5]
	false	162	65535	96	9961472
	# App Shortcuts
	# All Applications
	# Show Help Menu: [⌥E]
	true	98	101	14	524288
	# Dictation
	# Shortcut: [Off]
	false	164	65535	65535	0"

	while IFS=$'\t' read -r toggle index param1 param2 param3; do
		if [[ "${toggle}" == "#"* ]] || [[ -z "${toggle}" ]]; then
			continue
		else
			defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "${index}" "<dict><key>enabled</key><${toggle}/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>${param1}</integer><integer>${param2}</integer><integer>${param3}</integer></array></dict></dict>"
		fi
	done <<< "${_prefs}"

	# Services
	# Get all services names in "~/Library/Preferences/pbs.plist", except user-created ones (those preceded with (null)), format them nicely
	services_list=$(defaults read pbs NSServicesStatus | grep -o '".*"' | grep -v "(null).*" | awk '!/presentation_modes/ && !/ContextMenu/ && !/ServicesMenu/ && !/enabled_services_menu/ && !/enabled_context_menu/ && !/key_equivalent/')
	# the services' file location
	services_file="${path_to_my_parent}/data/services.txt"
	# if a service isn't already in the file, add it
	while IFS= read -r line; do
		if ! grep --silent "${line}" "${services_file}"; then
			echo -e ${yellow}"${line} added to file."${nc}
			printf "%s\n" "${line}" >> "${services_file}"
		fi
	done <<< "${services_list}"

	# now, read the services.txt file line by line, disable each service
	while IFS= read -r service; do
		defaults write pbs NSServicesStatus -dict-add "${service}" '<dict><key>enabled_context_menu</key><false/><key>enabled_services_menu</key><false/><key>key_equivalent</key><string></string></dict>'
	done < "${services_file}"

	# input sources
	# Automaticalyl switch to a document's input source
	defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict-add TextInputGlobalPropertyPerContextInput -bool true
}

prefpane_Mouse () {
	_prefs="
	# [ ] Scroll direction: Natural
	dfw	NSGlobalDomain	com.apple.swipescrolldirection	-bool	false
	# [✓] Secondary click: Click on right side
	dfw	com.apple.AppleMultitouchMouse	MouseButtonMode	-string	TwoButton
	dfw	com.apple.driver.AppleBluetoothMultitouch.mouse	MouseButtonMode	-string	TwoButton
	# [✓] Swipe between pages: Swipe left or right with two fingers
	dfw	com.apple.AppleMultitouchMouse	MouseTwoFingerHorizSwipeGesture	-int	1
	dfw	com.apple.driver.AppleBluetoothMultitouch.mouse	MouseTwoFingerHorizSwipeGesture	-int	1
	# [ ] Mission Control
	dfw	com.apple.AppleMultitouchMouse	MouseTwoFingerDoubleTapGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.mouse	MouseTwoFingerDoubleTapGesture	-int	0"

	config3 "${_prefs}"
}

prefpane_Trackpad () {

	local _prefs="
	# [✓] Look up & data detectors: tap with three fingers
	dfw	NSGlobalDomain	com.apple.trackpad.forceClick	-bool	false
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadThreeFingerTapGesture	-int	2
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadThreeFingerTapGesture	-int	2

	# [✓] Tap to click
	dfw	com.apple.AppleMultitouchTrackpad	Clicking	-bool	true
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	Clicking	-bool	true
	# also for login screen
	dfw	NSGlobalDomain	com.apple.mouse.tapBehavior	-int	1

	# [ ] Scroll direction: Natural
	dfw	NSGlobalDomain	com.apple.swipescrolldirection	-bool	false

	# [ ] Swipe between full-screen apps
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadThreeFingerHorizSwipeGesture	-int	0
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadFourFingerHorizSwipeGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadThreeFingerHorizSwipeGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadFourFingerHorizSwipeGesture	-int	0

	# [ ] Notification Center
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadTwoFingerFromRightEdgeSwipeGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadTwoFingerFromRightEdgeSwipeGesture	-int	0

	# [ ] Mission Control
	# [ ] App Exposé
	dfw	com.apple.dock	showMissionControlGestureEnabled	-bool	false
	dfw	com.apple.dock	showAppExposeGestureEnabled	-bool	false
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadThreeFingerVertSwipeGesture	-int	0
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadFourFingerVertSwipeGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadThreeFingerVertSwipeGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadFourFingerVertSwipeGesture	-int	0

	# [ ] Launchpad
	# [ ] Show Desktop
	dfw	com.apple.dock	showLaunchpadGestureEnabled	-bool	false
	dfw	com.apple.dock	showDesktopGestureEnabled	-bool	false
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadFourFingerPinchGesture	-int	0
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadFiveFingerPinchGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadFourFingerPinchGesture	-int	0
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadFiveFingerPinchGesture	-int	0"

	config3 "${_prefs}"
}

prefpane_Printers_and_Scanners () {

	local _prefs="
	# Expand print panel by default
	dfw	NSGlobalDomain	PMPrintingExpandedStateForPrint	-bool	true
	dfw	NSGlobalDomain	PMPrintingExpandedStateForPrint2	-bool	true
	# 
	dfw	com.apple.print.PrinterProxy	IK_CreateSingleDocument	-bool	true
	# 
	dfw	com.apple.print.PrinterProxy	IK_FileFormatTagColor	-int	6
	# 
	dfw	com.apple.print.PrinterProxy	IK_scannerDisplayMode	-int	1
	# 
	dfw	com.apple.print.PrinterProxy	IK_ScanBitDepth	-int	8
	# 
	dfw	com.apple.print.PrinterProxy	IK_ScanResolution	-int	300
	# 
	dfw	com.apple.print.PrinterProxy	IK_ScannerDocumentType	-int	1
	# 
	dfw	com.apple.print.PrinterProxy	IK_Scanner_downloadURL	-string	$HOME/Desktop
	# 
	dfw	com.apple.print.PrinterProxy	IK_Scanner_preferPostPostProcessApp	-bool	false
	# 
	dfw	com.apple.print.PrinterProxy	IK_Scanner_selectedPathType	-int	2
	# 
	dfw	com.apple.print.PrinterProxy	IK_Scanner_selectedTag	-int	1001
	# Automatically quit printer app once the print jobs complete
	dfw	com.apple.print.PrintingPrefs	Quit When Finished	-bool	true"

	config3 "${_prefs}"
}

prefpane_Siri () {
	# Siri
	# Keyboard Shortcut: [Off]
	defaults write com.apple.Siri HotKeyTag -int 0
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 176 "<dict><key>enabled</key><false/></dict>"
}

prefpane_Accessibility () {
	# General
		# [ ] Zoom
		# [ ] VoiceOver
		# [ ] Sticky Keys
		# [ ] Slow keys
		# [ ] Mouse Keys
		# [ ] Accessibility Keyboard
		# [ ] Invert Display Color
	defaults write com.apple.universalaccess axShortcutExposedFeatures -dict \
	feature.invertDisplayColor -bool false \
	feature.mouseKeys -bool false \
	feature.slowKeys -bool false \
	feature.stickyKeys -bool false \
	feature.switchControl -bool false \
	feature.virtualKeyboard -bool false \
	feature.voiceOver -bool false \
	feature.zoom -bool false

	local _prefs="
	# [✓] Use scroll gesture with modifier keys to zoom: [⌃ Control]
	dfw	com.apple.universalaccess	closeViewScrollWheelToggle	-bool	true
	dfw	com.apple.universalaccess	HIDScrollZoomModifierMask	-int	262144
	# Zoom follows the keyboard focus
	dfw	com.apple.universalaccess	closeViewZoomFollowsFocus	-bool	true
	# Siri
	# [✓] Enable Type to Siri
	dfw	com.apple.Siri	TypeToSiriEnabled	-bool	true
	# Mouse & Trackpad
	# [✓] Enable dragging [three finger drag]
	dfw	com.apple.AppleMultitouchTrackpad	TrackpadThreeFingerDrag	-bool	true
	dfw	com.apple.driver.AppleBluetoothMultitouch.trackpad	TrackpadThreeFingerDrag	-bool	true"

	config3 "${_prefs}"
}

prefpane_Sharing () {

	if [[ ! -e ~/.compname ]]; then
		osascript -e 'tell application "Terminal" to activate'
		echo -e ${yellow}"Enter desired computer name: "${nc}
		read computer_name
		sudo scutil --set ComputerName "${computer_name}"
		sudo scutil --set HostName "${computer_name}"
		sudo scutil --set LocalHostName "${computer_name}"
		sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${computer_name}"
		touch ~/.compname
		echo "${computer_name}" > ~/.compname
	fi
	computer_name=$(cat ~/.compname)
	echo -e ${green}"Chosen computer name is: ${yellow}${computer_name}"${nc}
}

prefpane_Users_and_Groups () {

	# Change the user's profile picture to "Penguin"
	userList=$(dscl . list /Users UniqueID | awk '$2 > 500 {print $1}')
	for user in $userList; do
		sudo dscl . delete "/Users/$user" JPEGPhoto
		sudo dscl . create "/Users/$user" Picture "/Library/User Pictures/Animals/Penguin.tif"
	done
	# [ ] Allow guests to log in to this computer
	sudo sysadminctl -guestAccount off &>/dev/null

	# Login items
		# gets current login items, removing invalid ones
		# reads a file containing my list of login items, iterating over it and making new ones as needed
		# takes only the valid items in my list and adds to a new list
		# eventually overwriting the aforementioned file
	osascript - "${path_to_my_parent}/data/login_items.txt" <<-EOF
	on run { theFile }
		set myNewLoginItemsList to ""
		set theFile to POSIX file theFile
		set myLoginItems to paragraphs of (read file theFile as «class utf8»)
		set trashFolder to ((path to home folder as text) & ".Trash:")
		tell application "System Events"
			set currentLoginItems to every login item
			repeat with aLoginItem in currentLoginItems
				set aLoginItemPath to path of aLoginItem
				if (not (exists file aLoginItemPath)) or (container of file aLoginItemPath is folder trashFolder) then
					delete aLoginItem
				end if
			end repeat
			set currentLoginItems to path of every login item --> update the var with the path of every login item
			repeat with i from 1 to ((count of myLoginItems) - 1) --> last list item is a blank line
				set myLoginItemPath to item i of myLoginItems
				if exists file myLoginItemPath then
					if currentLoginItems does not contain (myLoginItemPath) then
						make new login item with properties {hidden:true, path:myLoginItemPath}
					end if
					set myNewLoginItemsList to myNewLoginItemsList & myLoginItemPath & return
				end if
			end repeat
			my write_to_file(myNewLoginItemsList, theFile, false)
		end tell
	end run
	on write_to_file(this_data, target_file, append_data)
		try
			set the target_file to the target_file as string
			set the open_target_file to open for access file target_file with write permission
			if append_data is false then set eof of the open_target_file to 0
			write this_data to the open_target_file starting at eof
			close access the open_target_file
			# return true
		on error
			try
				close access file target_file
			end try
			return false
		end try
	end write_to_file
	EOF

}

prefpane_SystemUIServer () {	
		
	# Date & Time
		# [ ] Show date and time in menu bar
	# Energy Saver
		# [ ] Show battery status in menu bar
	defaults -currentHost write com.apple.systemuiserver dontAutoLoad -array \
	"/System/Library/CoreServices/Menu Extras/Clock.menu" \
	"/System/Library/CoreServices/Menu Extras/Battery.menu"
	
	defaults write com.apple.systemuiserver menuExtras -array \
	"/System/Library/CoreServices/Menu Extras/AirPort.menu" \
	"/System/Library/CoreServices/Menu Extras/TextInput.menu" \
	"/System/Library/CoreServices/Menu Extras/Volume.menu" \
	"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
	"/System/Library/CoreServices/Menu Extras/Displays.menu"

	# Sound
		# [✓] Show volume in menu bar
		# Set menu bar icon position
	# Network
		# Set menu bar icon position
	# Bluetooth
		# [✓] Show Bluetooth in menu bar
		# Set menu bar icon position
	_prefs="
	# visibility of os icons
	dfw	com.apple.systemuiserver	NSStatusItem Visible com.apple.menuextra.bluetooth	-bool	true
	dfw	com.apple.systemuiserver	NSStatusItem Visible com.apple.menuextra.volume	-bool	true
	dfw	com.apple.systemuiserver	NSStatusItem Visible com.apple.menuextra.airplay	-bool	true
	dfw	com.apple.systemuiserver	NSStatusItem Visible Siri	-bool	false
	dfw	com.apple.Siri	StatusMenuVisible	-bool	false

	# positions of visible icons
	dfw	com.apple.systemuiserver	NSStatusItem Preferred Position com.apple.menuextra.textinput	-float	2.80859
	dfw	com.surteesstudios.Bartender	NSStatusItem Preferred Position statusItem	-float	60
	dfw	com.flexibits.fantastical2.mac	NSStatusItem Preferred Position Fantastical	-float	86.49609
	dfw	com.bjango.istatmenus.status	NSStatusItem Preferred Position com.bjango.istatmenus.combined	-float	152.4297
	dfw	com.apple.systemuiserver	NSStatusItem Preferred Position com.apple.menuextra.airport	-float	200.0195
	dfw	com.apple.systemuiserver	NSStatusItem Preferred Position com.apple.menuextra.bluetooth	-float	236.6562
	dfw	com.apple.systemuiserver	NSStatusItem Preferred Position com.apple.menuextra.volume	-float	258.7188
	dfw	com.getdropbox.dropbox	NSStatusItem Preferred Position Item-0	-float	322.0859
	dfw	com.macility.typinator2	NSStatusItem Preferred Position Item-0	-float	389.3477
	dfw	com.toggl.toggldesktop.TogglDesktop	NSStatusItem Preferred Position Item-0	-float	420

	# positions of bartender 3 hidden icons
	dfw	com.apple.Spotlight	NSStatusItem Preferred Position Item-0	-float	349.7383
	dfw	com.apple.systemuiserver	NSStatusItem Preferred Position com.apple.menuextra.airplay	-float	381.9023
	dfw	NSGlobalDomain	NSStatusItem Preferred Position com.apple.menuextra.airplay	-float	450.1133
	dfw	com.stairways.keyboardmaestro.engine	NSStatusItem Preferred Position Item-0	-float	460
	dfw	org.pqrs.Karabiner-Menu	NSStatusItem Preferred Position Item-0	-float	479.5586
	dfw	com.agilebits.onepassword7	NSStatusItem Preferred Position Item-0	-float	505.4219
	dfw	com.udoncode.copiedmac	NSStatusItem Preferred Position Item-0	-float	524.0742
	dfw	com.flexibits.cardhop.mac	NSStatusItem Preferred Position Item-0	-float	543.793
	dfw	com.runningwithcrayons.Alfred-3	NSStatusItem Preferred Position Item-0	-float	574.5"

	config3 "${_prefs}"

	killall "SystemUIServer"
}

#************************************************#
# Symlinks          						     #
#************************************************#

symlinks () {

echo -e "${magenta}Creating symlinks... ${nc}"
# all files/dirs to be symlinked are marked with a "symlink_this" spotlight comment
# it is imperative that files/dirs to be symlinked have a comment -- and those files/dirs only!
# the comment's content doesn't really matter, as `find` reads it as (null)
# use `find` to get them all
files_to_symlink=$(find ~/Dropbox/dotfiles/symlinks -xattrname com.apple.metadata:kMDItemFinderComment | sort)

	while IFS= read -r file_to_symlink; do
		# check if the file to be linked exists
		if [[ ! -e "${file_to_symlink}" ]]; then
			echo -e ${red}"${file_to_symlink} is supposed to be symlinked, but it wasn't found. Update the list."${nc} >> "${errlog}"
		else
				# extract destination path from the each path in the above list
				# put the full path to the destination folder/file into a variable, use it later for deduplication
				# by taking out `${HOME}/Dropbox/dotfiles/symlinks/` (using bash variable substituion), we get the reference to the destionation file/folder
				destination_file="${file_to_symlink/${HOME}\/Dropbox\/dotfiles\/symlinks/}"
				# most importantly, edit each file's path to match the PARENT destination folder
				# we achieve this by removing the last path component
				destination_dir="${destination_file%/*}"

				# if the dest. dir already exists, cd into it
				if [[ -d "${destination_dir}" ]]; then
					cd "${destination_dir}"
				else
					# otherwise,
					# drill down to the destination directory, create folders if necessary
					# make an array out of each destination path, delimit elements with a /
					IFS='/' read -ra directories <<< "${destination_dir}"
					# put the array's length into a variable
					path_length="${#directories[@]}"
					# create an iterator
					num=1
					# traverse the directory tree
					for i in "${directories[@]}"; do
						# add a trailing / to signal a directory
						i="${i}/"
						# execute this loop until the iterator matches path's length
						if [[ "${num}" -le "${path_length}" ]]; then
							# if the folder exists, move into it
							if [[ -d "${i}" ]]; then
								cd "${i}" 2>/dev/null
							# else, create it and then move to it
						else
							mkdir "${i}" && cd "${i}" 2>/dev/null
						fi
							# add 1 to the iterator
							num=$(( $num + 1 ))
						fi
					done
				fi

				# now we're in the target directory

				# ln -sf doesn't overwrite directories, so if the destination is a dir (and not a symlinked one), move it to trash first
				# if the destination is an existing file or a broken symlink, overwrite it
				if [[ -d "${destination_file}" ]] && [[ ! -L "${destination_file}" ]]; then
					osascript - "${destination_file}" <<-EOF >/dev/null
						on run { theFolder }
							set theFile to POSIX file theFolder as alias
							tell application "Finder"
								delete theFile
							end tell
						end run
					EOF
					echo -e ${red}"Symlinks: trashed \"${destination_file}\"" >> "${errlog}"
				fi
				
				if ln -sf "${file_to_symlink}"; then
					echo -e "${yellow}Symlink created: \n    ⌐ Source: ${green}${file_to_symlink/~/~}${yellow}\n    ⌙ Destination: ${green}${destination_dir/~/~}/${nc}" >> "${errlog}"
				fi
		fi
	done <<< "${files_to_symlink}"

	cd
}

#************************************************#
# rsync 	         						     #
#************************************************#

rsyncs () {
	echo -e "${magenta}Performing rsync tasks...${nc}"
	# Pages' templates
	echo -e ${green}"Syncing 'Pages' templates"
	file="${HOME}/Dropbox/dotfiles/extra/pages-templates/"
		# create the user templates folder (for rsync)
	mkdir -p ~/Library/Containers/com.apple.iWork.Pages/Data/Library/Application\ Support/User\ Templates/
	if checkfile "${file}"; then
		rsync -a --delete "${file}" ~/Library/Containers/com.apple.iWork.Pages/Data/Library/Application\ Support/User\ Templates/
	fi

	# Fonts
	echo -e ${green}"Syncing fonts"
	file="${HOME}/Dropbox/dotfiles/extra/fonts"
	if checkfile "${file}"; then
		rsync -a --delete  "${file}" ~/Library/Fonts/
	fi
}

#************************************************#
# end               	         				 #
#************************************************#

end () {
	if [[ -s "${errlog}" ]]; then
		echo -e "\n${magenta}--- BEGIN REPORT --- ${nc}\n"
		cat "${errlog}"
		echo -e "\n${magenta}--- END REPORT --- ${nc}\n"
	fi
	echo -e "\n${magenta}Done.${nc}"
	return 0
}

########################################
# execution                            #
########################################

preferences () {

	echo -e ${magenta}"Configuring 3rd-party apps:"${nc}
	while IFS= read -r line; do
		echo -e ${green}"${line#app_}"${nc}
		eval "$line"
	done < <(grep "^app_" "${path_to_me}" | sed 's/ .*//g')

	echo -e ${magenta}"Configuring Apple apps:"${nc}
	while IFS= read -r line; do
		echo -e ${green}"${line#apple_}"${nc}
		eval "$line"
	done < <(grep "^apple_" "${path_to_me}" | sed 's/ .*//g')

	echo -e ${magenta}"Configuring System Preferences:"${nc}
	while IFS= read -r line; do
		echo -e ${green}"${line#prefpane_}"${nc}
		eval "$line"
	done < <(grep "^prefpane_" "${path_to_me}" | sed 's/ .*//g')
}

specific () {
	n=0
	while IFS= read -r line; do
		command_name="${line%% *}"
		echo -e "${green}${n}) ${command_name}${nc}"
		functions_array+=("${command_name}")
		((n++))
	done < <(grep -E "^app_|^apple_|^prefpane_" "${path_to_me}")
	echo -e "${magenta}Please enter your choice: ${nc}"
	read
	case $REPLY in
		*)
			${functions_array[$REPLY]}
			;;
	esac
	echo -e "\n${magenta}Done.${nc}"
	source "${path_to_me}" --menu
}

#************************************************#
# options menu      						     #
#************************************************#

if [[ "${1}" == "--menu" ]]; then

	echo -e ${magenta}"Welcome to ${name_of_me}. Options:"
	echo -e ${green}"1) Standard run:"
	echo -e "  I. Apps: installations, uninstallations, updates."
	echo -e "  II. Settings: symlinks; rsync tasks; prefs for 3rd-party apps, Apple apps, and macOS."
	echo -e "2) Apps only."
	echo -e "3) Settings only."
	echo -e "4) Symlinks & rsync tasks."
	echo -e "5) Ignition."
	echo -e "6) Specific app or preference pane."
	echo -e "7) Quit."
	echo -e -n ${magenta}"Enter choice: "${nc}
	read
	case $REPLY in
	    1)
	    	# standard
			start
			installations
			security
			symlinks
			rsyncs
			preferences
			end
			;;
	   	2)
		   	# apps
			start
		    installations
		    security
		    symlinks
		    end
		    ;;
	    3) 
		    # settings
		    start
		    symlinks
		    rsyncs
		    security
			preferences
			end
			;;
	    4)
		    # symlink + rsync
		    symlinks
		    rsyncs
		    end
		    ;;
	    5)	# ignition
			start
			ignition
			installations
			security
			symlinks
			preferences
			end
			;;
	    6) 
	    	# specific
			specific
			end
			;;
	    7) 
	    	# quit
			return 0
			;;
	    *)
		    # invalid choice
		    red_msg "Invalid choice, try again."
		    sleep 0.5
		    loadscript
		    ;;
	esac
else
	# loadscript --init
	loadscript
fi

###############################################################################
# Sources                                                                     #
###############################################################################

# https://github.com/mathiasbynens/dotfiles
# https://github.com/ptb/mac-setup
# https://www.amsys.co.uk/creating-first-boot-script/#.VTqcoc57Urk

# Login itens: http://hints.macworld.com/article.php?story=20111226075701552
# Hotkeys: http://krypted.com/mac-os-x/defaults-symbolichotkeys/
# Hotkeys: https://apple.stackexchange.com/questions/91679/is-there-a-way-to-set-an-application-shortcut-in-the-keyboard-preference-pane-vi
# Hotkeys: https://github.com/diimdeep/dotfiles/blob/master/osx/configure/hotkeys.sh
# Scripting System Preferences: http://www.macosxautomation.com/applescript/features/system-prefs.html
# Input spurces: https://apple.stackexchange.com/questions/127246/mavericks-how-to-add-input-source-via-plists-defaults
# Keyboard > Services: https://osxentwicklerforum.de/index.php/Thread/30969-Shortcuts-in-App-für-Service-festlegen-ändern/
# Notifications: # https://www.jamf.com/jamf-nation/discussions/13986/modify-notification-center-preferences-widgets-etc-from-the-command-line
# Changing the user's picture: https://scriptingosx.com/2018/10/changing-a-users-login-picture/
# Making ~/Library visible to Finder: https://www.reddit.com/r/macsysadmin/comments/7snk0u/macos_high_sierra_unhide_the_user_library_via_cli/
# Colored `read`: https://stackoverflow.com/questions/24998434/read-command-display-the-prompt-in-color-or-enable-interpretation-of-backslas
# https://github.com/paulirish/dotfiles/blob/master/.osx

# in consideration
# com.apple.CloudPhotosConfiguration com.apple.photo.icloud.cloudphoto" = 1;
# com.apple.CloudPhotosConfiguration com.apple.photo.icloud.myphotostream" = 0;
# com.apple.Photos IPXDefaultDidPromoteiCloudPhotosInGettingStarted = 1;
# com.apple.Photos IPXDefaultHasBeenLaunched = 1;
# com.apple.Photos IPXDefaultHasChosenToEnableiCloudPhotosInGettingStarted = 1;

# Deprecated

# com.apple.CharacterPaletteIM CVActiveCategories
# Shown by default in the floating palette (does not correlate with the menu settings):
	# Emoji (Smileys & People, Animals & Nature... Flags)
	# Letterlike Symbols
	# Pictographs
	# Bullets/Stars
	# Technical Symbols
	# Sign/Standard Symbols
# Add:
		# Hebrew
		# app_TextExpander () {

# textexpander
	# don't notify on secure input
	# osascript -e 'tell application "TextExpander" to set notify on Secure Input to false'

# /usr/libexec/PlistBuddy -c 'Delete :ExtensionSettings-com.sidetree.Translate-S64NDGV2C5:keyShortcut string' ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plist
# /usr/libexec/PlistBuddy -c 'Delete :ExtensionSettings-com.sidetree.Translate-S64NDGV2C5:useKeyShortcut bool false' ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plist
# /usr/libexec/PlistBuddy -c 'Delete :ExtensionSettings-com.sidetree.Translate-S64NDGV2C5:translateTo string en' ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plist
# /usr/libexec/PlistBuddy -c 'Add :ExtensionSettings-com.sidetree.Translate-S64NDGV2C5:keyShortcut string \"\"' ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plist
# /usr/libexec/PlistBuddy -c 'Add :ExtensionSettings-com.sidetree.Translate-S64NDGV2C5:useKeyShortcut bool false' ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plist
# /usr/libexec/PlistBuddy -c 'Add :ExtensionSettings-com.sidetree.Translate-S64NDGV2C5:translateTo string \"en\"' ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.Extensions.plis

# app_Alfred_3 () {
# 	_prefs="
# 	# Show workflow creator
# 	dfw	com.runningwithcrayons.Alfred-Preferences-3	workflows.showCreator	-bool	true
# 	# Show workflow hotkeys
# 	dfw	com.runningwithcrayons.Alfred-Preferences-3	workflows.showHotkeys	-bool	true
# 	# sync folder
# 	dfw_file	com.runningwithcrayons.Alfred-Preferences-3	syncfolder	-string	${HOME}/Dropbox/dotfiles/extra/alfred"
# 	config3 "${_prefs}"	
# }

# # [✓] Start at login
# dfw	com.udoncode.copiedmac	CDUserDefaultsStartAtLogin	-bool	false
# # Sort by date added, newest first
# dfw	com.udoncode.copiedmac	CDUserDefaultsSortByAddDate	-bool	true
# # Copied History: [1000]
# dfw	com.udoncode.copiedmac	CDUserDefaultsClipboardSize	-int	1000
# # Double Click: [Paste in Active App]
# dfw	com.udoncode.copiedmac	CDUserDefaultsDoubleClickAction	-int	3
# # Return: [Paste in Active App]
# dfw	com.udoncode.copiedmac	CDUserDefaultsReturnActionKey	-int	3
# # ⌘ Return: [Copy to Clipboard]
# dfw	com.udoncode.copiedmac	CDUserDefaultsCommandReturnActionKey	-int	2
# # ⌥ Return: [Paste in Plain Text]
# dfw	com.udoncode.copiedmac	CDUserDefaultsOptionReturnActionKey	-int	5
# # [✓] Copy/paste action closes window
# dfw	com.udoncode.copiedmac	CDUserDefaultsCopyPasteClosesWindow	-bool	true
# # [ ] Show window on launch: [Mini Window]
# dfw	com.udoncode.copiedmac	CDUserDefaultsHideWindowOnLaunchKey	-bool	true
# # [✓] Select first clipping when window is opened
# dfw	com.udoncode.copiedmac	CDUserDefaultsScrollToTopOnActivation	-bool	true
# # [✓] Hide compact window when it loses focus
# dfw	com.udoncode.copiedmac	CDUserDefaultsCloseDetachedWindowOnResignKey	-bool	true
# # Show close window control
# dfw	com.udoncode.copiedmac	CDUserDefaultsShowWindowControls	-bool	true
# # Don't open compact window under mouse cursor
# dfw	com.udoncode.copiedmac	CDUserDefaultsShowWindowUnderCursor	-bool	false
# # Tone: [None]
# dfw	com.udoncode.copiedmac	CDUserDefaultsPlaySounds	-bool	false
# # Match theme to menu bar
# dfw	com.udoncode.copiedmac	CDUserDefaultsWindowAppearance	-bool	false
# # [✓] iCloud Sync
# dfw	com.udoncode.copiedmac	CDUserDefaultsSyncEnabled	-bool	true
# # Show/Hide Copied [⇧⌘V]
# dfw	com.udoncode.copiedmac	CDHotkeyShowApplication	-dict	"characters" -string '\026' "charactersIgnoringModifiers" -string "V" "keyCode" -int 9 "modifierFlags" -int 1966080
# # Show Clipboard [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyShowClipboard 2>/dev/null
# # Save Current Clipboard [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeySaveClipboard 2>/dev/null
# # Clear Clipboard [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyClearClipboardKey 2>/dev/null
# # Show Paste Queue [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyShowPasteQueue 2>/dev/null
# # Copy Queued Clipping [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyCopyNextClipping 2>/dev/null
# # Paste Queued Clipping [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyPasteNextClippingKey 2>/dev/null
# # Restore Previous Clipping [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyRestorePreviousClippingKey 2>/dev/null
# # Next List [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyNextList 2>/dev/null
# # Toggle Auto Save [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyToggleClipboardRecorder 2>/dev/null
# # Toggle Plain Text Mode [Record Shortcut]
# # defaults delete com.udoncode.copiedmac CDHotkeyTogglePlainText 2>/dev/null
# # float window on top
# dfw	com.udoncode.copiedmac	CDUserDefaultsFloatWindow	-bool	true
# # Position compact window (roughly) in the center
# dfw	com.udoncode.copiedmac	CDUserDefaultsWindowFrame	-string	"{{621, 215}, {320, 600}}"

# # hide status bar item
# dfw	com.evernote.Evernote	showsStatusBarItem	-bool	false
# # Quick Note
# dfw	com.evernote.Evernote	ShortcutRecorder newnote	-dict	keyCode	-1	modifierFlags	0	modifiers	0
# # New Note Window
# dfw	com.evernote.Evernote	ShortcutRecorder newnotewindow	-dict	keyCode	-1	modifierFlags	0	modifiers	0
# # Paste to Evernote
# dfw	com.evernote.Evernote	ShortcutRecorder pasteboard	-dict	keyCode	-1	modifierFlags	0	modifiers	0
# # Clip Rectangle or Window
# dfw	com.evernote.Evernote	ShortcutRecorder screenshot	-dict	keyCode	-1	modifierFlags	0	modifiers	0
# # Clip Full Screen
# dfw	com.evernote.Evernote	ShortcutRecorder fullscreenshot	-dict	keyCode	-1	modifierFlags	0	modifiers	0
# # Search in Evernote
# dfw	com.evernote.Evernote	ShortcutRecorder search	-dict	keyCode	-1	modifierFlags	0	modifiers	0
# # Skip welcome window
# dfw	com.evernote.Evernote	firstLaunch	-bool	false

# # don't show the welcome window
# dfw	com.smileonmymac.textexpander	welcomeVisible	-string	FALSE
# # make the editor much larger
# dfw	com.smileonmymac.textexpander	NSWindow Frame MainWindow	-string	0 52 1680 975 0 0 1680 1027 
# # hide icon in dock
# dfw	com.smileonmymac.textexpander	Hide Dock Icon	-bool	true
# # don't show main window on launch
# dfw	com.smileonmymac.textexpander	Hide Main Window	-bool	true
# # check for updates daily, anonymously
# dfw	com.smileonmymac.textexpander	SUEnableAutomaticChecks	-bool	true
# dfw	com.smileonmymac.textexpander	SUHasLaunchedBefore	-bool	true
# dfw	com.smileonmymac.textexpander	SUSendProfileInfo	-bool	false
# # skip version 6 ?
# dfw	com.smileonmymac.textexpander	TextExpanderReg5	-string	_never_

	# echo -e ${green}"Finished. Press L to log out; R to restart. Press any other key to dismiss."${nc}
	# read -r
	# case $REPLY in
	# 	l|L)
	# 	osascript -e 'tell app "System Events" to log out';;
	# 	r|R)
	# 	osascript -e 'tell app "loginwindow" to «event aevtrrst»';;
	# 	*)
	# 	echo "Done. Note that some of these changes require a logout/restart to take effect.";;
	# esac
	# cd