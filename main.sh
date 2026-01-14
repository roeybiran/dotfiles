#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

CONTAINER=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

source "$CONTAINER/private/secrets.sh"

# BEGIN CONSTANTS

LOGIN_ITEMS=(
	/Applications/Finbar.app
	/Applications/Homerow.app
	/Applications/Knobby.app
	/Applications/Hammerspoon.app
	/Applications/LaunchBar.app
	/Applications/Raycast.app
	/Applications/Velja.app
	/Applications/Ghostty.app
)

BREW_PACKAGES=(
	aria2
	atuin
	bat
	eza
	fd
	ffmpeg
	font-symbols-only-nerd-font
	fzf
	gh
	git-extras
	git-lfs
	icdiff
	jq
	lazygit
	mas
	neovim
	node
	periphery
	qpdf
	ripgrep
	shellcheck
	spaceship
	wp-cli
	xcodes
	zoxide
	zsh-autosuggestions
	# for create-dmg
	graphicsmagick
	imagemagick
)

BREW_CASK_PACKAGES=(
	chatgpt
	cursor
	dash
	dropbox
	figma
	finbar
	font-input
	ghostty
	google-chrome
	hammerspoon
	homerow
	karabiner-elements
	launchbar
	little-snitch
	local
	macsymbolicator
	raycast
	sf-symbols
	shottr
	slack
	spotify
	the-unarchiver
	transmit
	visual-studio-code
	wezterm@nightly
)

declare -A MAS_APPS=(
	["Developer"]=640199958
	["Hush"]=1544743900
	["Keynote"]=409183694
	["Numbers"]=409203825
	["Pages"]=409201541
	["Vimlike"]=1584519802
	["Select Like A Boss For Safari"]=1437310115
	["Shareful"]=1522267256
	["Velja"]=1607635845
	["WhatsApp"]=310633997
	["Wipr"]=1320666476
)

# END CONSTANTS

link() {
	local src="$1"
	local dst="$2"

	local parent
	parent="$(dirname "$dst")"
	if [[ ! -d "$parent" ]]; then
		mkdir -p "$parent" &>/dev/null
	fi

	if [[ -e "$dst" ]]; then
		mv -f "$dst" ~/.Trash &>/dev/null
	fi

	if [[ ! -e "$src" ]]; then
		echo "Error: source '$src' does not exist"
		return 1
	fi

	ln -sFn "$src" "$dst"
}

symlinks() {
	# dotfiles
	link "$CONTAINER/.gitconfig" "$HOME/.gitconfig"
	link "$CONTAINER/.gitignore" "$HOME/.gitignore"
	link "$CONTAINER/.zshrc" "$HOME/.zshrc"

	# ssh
	link "$CONTAINER/.ssh/config" "$HOME/.ssh/config"

	# "XDG" config
	mv -f "$HOME/.config" ~/.Trash &>/dev/null
	for f in "$CONTAINER/config"/*; do
		link "$f" ~/.config/"$(basename "$f")"
	done

	# apps
	link "$CONTAINER/apps/LaunchBar" "$HOME/Library/Application Support/LaunchBar"
	link "$CONTAINER/apps/Xcode/IDETemplateMacros.plist" "$HOME/Library/Developer/Xcode/UserData/IDETemplateMacros.plist"
	link "$CONTAINER/apps/Xcode/CodeSnippets" "$HOME/Library/Developer/Xcode/UserData/CodeSnippets"
	link "$CONTAINER/apps/Xcode/FontAndColorThemes" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
	link "$CONTAINER/apps/Finbar/scripts" "$HOME/Library/Application Scripts/com.roeybiran.Finbar"
	link "$CONTAINER/apps/Finbar/recents.json" "$HOME/Library/Application Support/com.roeybiran.Finbar/recents.json"

	# zoxide
	link "$CONTAINER/private/zoxide" "$HOME/Library/Application Support/zoxide"
}

add_login_items() {
	for app in "${LOGIN_ITEMS[@]}"; do
		if [[ -e "$app" ]]; then
			osascript -e "tell app \"System Events\" to make new login item with properties {hidden:true, path:\"$app\"}" &>/dev/null
		fi
	done
}

set_mouse_option() {
	for domain in com.apple.AppleMultitouchMouse com.apple.driver.AppleBluetoothMultitouch.mouse; do
		defaults write "$domain" "$1" "$2" "$3"
	done
}

set_trackpad_option() {
	for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
		defaults write "$domain" "$1" "$2" "$3"
	done
}

set_symbolic_hotkey() {
	local index="$1"
	local flag="$2"
	local param1="$3"
	local param2="$4"
	local param3="$5"
	local type="${6:-standard}"
	defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$index" \
		"<dict>
		<key>enabled</key>
		<$flag/>
		<key>value</key>
			<dict>
				<key>type</key>
				<string>$type</string>
				<key>parameters</key>
					<array>
						<integer>$param1</integer>
						<integer>$param2</integer>
						<integer>$param3</integer>
					</array>
			</dict>
		</dict>"
}

enable_touchid_sudo() {
	# https://github.com/0xmachos/dotfiles/blob/8af44ce2e59f5bcaa9f529ea9282833a46de0d74/bittersweet#L543
	if [[ -e "/etc/pam.d/sudo_local" ]]; then
		if grep -q 'pam_tid.so' "/etc/pam.d/sudo_local"; then
			return 0
		fi
	else
		if sudo install -m 444 -g "wheel" -o root "/dev/null" "/etc/pam.d/sudo_local"; then
			:
		else
			echo "Failed to create /etc/pam.d/sudo_local"
			return 1
		fi

		if sudo ex -s -c '1i|auth       sufficient     pam_tid.so' -c x! -c x! "/etc/pam.d/sudo_local"; then
			echo "TouchID sudo Enabled"
			return 0
		else
			echo "Failed to enable TouchID sudo"
			return 1
		fi
	fi
}

install_app_from_github_releases() {
	local repo="$1"
	cd "$(mktemp -d)"

	echo "Installing $repo..."
	echo "Downloading..."
	API_URL="https://api.github.com/repos/$repo/releases/latest"
	RELEASE_INFO=$(curl -s "$API_URL")
	DOWNLOAD_URL="$(echo "$RELEASE_INFO" | grep browser_download_url | grep -o -E https.+dmg)"
	curl -LJO -s "$DOWNLOAD_URL"

	echo "Mounting..."
	dmg="$(find "$(pwd)" -name "*.dmg")"
	volume="$(hdiutil attach "$dmg" -nobrowse | tail -n 1 | grep -E -o "/Volumes/.+$")"
	echo "Copying to /Applications..."
	cp -Rf "$(find "${volume}" -maxdepth 1 -name "*.app")" /Applications/

	echo "Cleaning up..."
	hdiutil detach "${volume}" -quiet
	rm -f "$dmg"
}

yn() {
	if test -z "${1}"; then
		echo "Error: no prompt text provided"
		exit 1
	fi

	while true; do
		echo "${1} "
		read -r reply
		test "$reply" = "Y" && exit 0
		test "$reply" = "N" && exit 1
		echo "Invalid option. Try again."
	done
}

trash() {
	osascript -e "tell app \"Finder\" to move POSIX file \"$1\" to trash" &>/dev/null
}

mas_install() {
	local app="$1"
	local id="$2"
	if ! mas list | grep -q "$app"; then
		mas install "$id"
	fi
}

brew_install() {
	local package="$1"
	if ! brew list -1 | grep -q "$package"; then
		brew install "$package"
	fi
}

brew_cask_install() {
	local package="$1"
	if ! brew list --cask -1 | grep -q "$package"; then
		brew install --cask "$package"
	fi
}

config() {
	# https://gist.github.com/stephancasas/236f543b0f9f6509f5fe5878de01e38a?permalink_comment_id=4748936
	defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled 0

	# require password immediately after sleep or screen saver begins
	if ! sysadminctl -screenLock status 2>&1 | grep -q immediate; then
		printf "%s " "To require password [immediately] after sleep or screen saver begins,"
		sysadminctl -screenLock immediate -password -
	fi

	enable_touchid_sudo

	[[ ! -f ~/.hushlogin ]] && printf "%s\n" 'hello' >~/.hushlogin

	# create the ~/Developer folder
	mkdir -p ~/Developer &>/dev/null

	################################
	# Archive Utility
	################################
	defaults write com.apple.archiveutility archive-format -string zip

	################################
	# Calendar
	################################
	# don't show alternate calendar
	defaults write com.apple.iCal CALPrefOverlayCalendarIdentifier -string ""
	# show calendar list
	defaults write com.apple.iCal CalendarSidebarShown -bool true

	################################
	# Crash Reporter
	################################
	# show crash reports as notifications (https://twitter.com/_inside/status/1468770322316943363)
	defaults write com.apple.CrashReporter UseUNC -bool true

	################################
	# Dictionary
	################################
	# New Oxford American Dictionary (American English)
	# Oxford American Writer's Thesaurus (American English)
	# Dictionaries.io Hebrew-English
	# Hebrew
	# Wikipedia
	defaults write com.apple.DictionaryServices DCSActiveDictionaries -array \
		com.apple.dictionary.NOAD \
		com.apple.dictionary.OAWT \
		"${HOME}/Library/Containers/com.apple.Dictionary/Data/Library/Dictionaries/io.dictionaries.he.dictionary" \
		com.apple.dictionary.he.oup \
		/System/Library/Frameworks/CoreServices.framework/Frameworks/DictionaryServices.framework/Resources/Wikipedia.wikipediadictionary

	################################
	# Finder
	################################

	# Add ~/Developer to the sidebar
	# TODO

	# expand save panel by default
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

	# Show the ~/Library folder
	sudo xattr -d com.apple.FinderInfo ~/Library 2>/dev/null
	sudo chflags nohidden ~/Library
	# Show the /Volumes folder
	sudo chflags nohidden /Volumes
	# General
	# "Show these items on the desktop:"
	# "External disks: OFF"
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
	# "CDs, DVDs, and iPods: OFF"
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
	# "New Finder windows show: Desktop"
	defaults write com.apple.finder NewWindowTarget -string PfDe
	defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Desktop/"
	# Advanced
	# "Show all filename extensions: ON"
	defaults write -g AppleShowAllExtensions -bool true
	# "Show warning before before changing an extension: OFF"
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
	# "Show warning before before removing from iCloud Drive: OFF"
	defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
	# "Remove items from the Trash after 30 days: ON"
	defaults write com.apple.finder FXRemoveOldTrashItems -bool true
	# "Keep folders on top:"
	# "In windows when sorting by name: ON"
	defaults write com.apple.finder _FXSortFoldersFirst -bool true
	# "On Desktop: ON"
	defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
	# "When performing a search: Search the Current Folder"
	defaults write com.apple.finder FXDefaultSearchScope -string SCcf
	# Menu Bar Settings
	# "View > Show Path Bar: ON"
	defaults write com.apple.finder ShowPathbar -bool true
	# "View > Show Status Bar: ON"
	defaults write com.apple.finder ShowStatusBar -bool true
	# "View > Show Preview: ON"
	defaults write com.apple.finder ShowPreviewPane -bool true
	# Use list view in all Finder windows by default
	defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

	################################
	# Mail
	################################
	# When searching all mailboxes, also include results from Junk
	defaults write com.apple.mail IndexJunk -bool true

	# try sending later automatically if server isn't available
	defaults write com.apple.mail SuppressDeliveryFailure -bool true

	# dont organize by conversation
	defaults write com.apple.mail ThreadingDefault -bool false

	# highlight conversations
	defaults write com.apple.mail HighlightClosedThreads -bool true

	# show contact photo
	defaults write com.apple.mail EnableContactPhotos -bool true

	# [✓] Check Grammar with Spelling
	defaults write com.apple.mail CheckGrammarWithSpelling -bool true
	defaults write com.apple.mail WebGrammarCheckingEnabled -bool true

	# [✓] Smart Links
	defaults write com.apple.mail WebAutomaticLinkDetectionEnabled -bool true

	# don't insert attachments at end of message
	defaults write com.apple.mail AttachAtEnd -bool false

	# automatically add invitation to calendar
	defaults write com.apple.mail CalendarInviteRuleEnabled -bool true

	# make orange the default flag
	defaults write com.apple.mail FlagColorToDisplay -int 1

	# Disable inline attachments (just show the icons) (https://github.com/mathiasbynens/dotfiles)
	defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

	################################
	# Notes
	################################
	# check grammar with spelling
	defaults write com.apple.Notes ShouldCheckGrammarWithSpelling -bool true

	################################
	# Preview
	################################
	# Don't start on the last viewed page when opening documents
	defaults write com.apple.Preview kPVPDFRememberPageOption -bool false
	# Opening for the first time: Show as [Single Page]
	defaults write com.apple.Preferences kPVPDFDefaultPageViewModeOption -bool false
	defaults write com.apple.Preview kPVPDFDefaultPageViewModeOption -bool true
	# Surpress the PDF cropping alert
	defaults write com.apple.Preview PVSupressPDFCroppingAlert -bool true

	################################
	# Safari
	################################
	# General
	# Safari opens with: [All windows from last session]
	defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true
	# Remove download list items: [Upon successful download]
	defaults write com.apple.Safari DownloadsClearingPolicy -int 2
	# [✓] Show website icons in tabs
	defaults write com.apple.Safari ShowIconsInTabs -bool true
	# Dont autofill username and passwords
	defaults write com.apple.Safari AutoFillPasswords -bool true
	# Dont autofill credit card data
	defaults write com.apple.Safari AutoFillCreditCardData -bool true
	# tabs
	defaults write com.apple.Safari NeverUseBackgroundColorInToolbar -bool true
	# Search
	# [ ] Smart Search Field: Show Favorites
	defaults write com.apple.Safari ShowFavoritesUnderSmartSearchField -bool false
	# Smart Search Field: [✓] Show full website address
	defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
	# Save reading list item for offline reading automatically
	defaults write com.apple.Safari ReadingListSaveArticlesOfflineAutomatically -bool true
	# Websites
	# don't allow for website to ask for permission to send notifications
	defaults write com.apple.Safari CanPromptForPushNotifications -bool false
	# Advanced
	# press tab to highlight each item on a page
	defaults write com.apple.Safari WebKitPreferences.tabFocusesLinks -bool true
	defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
	# [✓] Show Develop menu in menu bar
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
	# menu bar settings
	# don't show favorites bar
	defaults write com.apple.Safari ShowFavoritesBar-v2 -bool false
	# [✓] Show Tab Bar
	defaults write com.apple.Safari AlwaysShowTabBar -bool true
	# [✓] Show Status Bar
	defaults write com.apple.Safari ShowOverlayStatusBar -bool true
	# [✓] Check Grammar With Spelling
	defaults write com.apple.Safari WebGrammarCheckingEnabled -bool true
	# [✓] Smart Quotes
	defaults write com.apple.Safari WebAutomaticQuoteSubstitutionEnabled -bool true
	# [✓] Smart Dashes
	defaults write com.apple.Safari WebAutomaticDashSubstitutionEnabled -bool true
	# [✓] Smart Links
	defaults write com.apple.Safari WebAutomaticLinkDetectionEnabled -bool true
	# allow javascript from appleevents
	defaults write com.apple.Safari AllowJavaScriptFromAppleEvents -bool true
	# Make Safari’s search banners default to Contains instead of Starts With *
	defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
	# Add a context menu item for showing the Web Inspector in web views *
	defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
	# hide the siri suggestions tooltip?
	defaults write com.apple.Safari ForYouExperienceWelcomeViewNumberOfTimesShown -int 5
	# start page
	defaults write com.apple.Safari StartPageSectionOrdering -array \
		readingListItemIdentifier \
		cloudTabsItemIdentifier \
		exploreItemIdentifier \
		favoritesItemIdentifier \
		frequentlyVisitedItemIdentifier \
		privacyReportIdentifier
	defaults write com.apple.Safari ShowFavorites -bool false
	defaults write com.apple.Safari ShowFavorites -bool false
	defaults write com.apple.Safari ShowFrequentlyVisitedSites -bool false
	defaults write com.apple.Safari ShowPrivacyReportInFavorites -bool false
	defaults write com.apple.Safari ShowCloudTabsInFavorites -bool true

	################################
	# Screenshot
	################################
	# don't remember last selection
	defaults write com.apple.screencapture save-selections -bool false

	################################
	# System Settings
	################################
	# "General > Language & Region > Preferred Languages"
	defaults write -g AppleLanguages -array en-IL he-IL

	# "General > Login Items & Extensions > Open at Login"
	add_login_items

	# "Accessibility > Zoom > Use scroll gesture with modifier keys to zoom: ON"
	# TODO

	# "Accessibility > Zoom > Modifier key for scroll gesture"
	# TODO

	# "Accessibility > Display > Reduce transparency: ON"
	defaults write com.apple.Accessibility reduceTransparency -bool true

	# "Accessibility > Display > Diffrentiate without color: ON"
	defaults write com.apple.Accessibility differentiateWithoutColor -bool true

	# "Accessibility > Display > Show window title icons: ON"
	defaults write com.apple.universalaccess showWindowTitlebarIcons -bool true

	# "Accessibility > Pointer Control > Trackpad Options > Use trackpad for dragging: ON"
	# "Accessibility > Pointer Control > Trackpad Options > Dragging style: Three Finger Drag"
	set_trackpad_option TrackpadThreeFingerDrag -bool true

	# "Appearance > Show scroll bars: Always"
	defaults write -g AppleShowScrollBars -string Always

	# "Appearance > Allow wallpaper tinting in windows"
	defaults write -g AppleReduceDesktopTinting -bool true

	# "Apple Intelligence & Siri > Keyboard Shortcut: Press Right Command Key Twice"
	set_symbolic_hotkey 176 true 32 54 1048592 SAE1.0

	# "Control Center > Bluetooth: Show in Menu Bar"
	defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true

	# "Control Center > Sound: Always Show in Menu Bar"
	defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

	# "Control Center > Now Playing: Don't Show in Menu Bar"
	defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false

	# "Control Center > Battery > Show Percentage"
	# TODO

	# "Control Center > Clock > Show Date > Always"
	defaults write com.apple.menuextra.clock ShowDate -int 1

	# "Control Center > Spotlight > Don't Show in Menu Bar"
	defaults delete com.apple.Spotlight "NSStatusItem Visible Item-0" 2>/dev/null

	# "Control Center > Siri > Don't Show in Menu Bar"
	defaults write com.apple.Siri StatusMenuVisible -bool false

	# hide user switcher in the menu bar
	defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -bool false

	# "Desktop & Dock > Minimize windows using: Scale Effect"
	defaults write com.apple.dock mineffect -string scale

	# "Desktop & Dock > Automatically hide and show the Dock: ON"
	defaults write com.apple.dock autohide -bool true

	# "Desktop & Dock > Prefer tabs when opening documents: Always"
	defaults write -g AppleWindowTabbingMode -string always

	# "Desktop & Dock > Close windows when quitting an application: ON"
	defaults write -g NSQuitAlwaysKeepsWindows -bool false

	# "Desktop & Dock > Tiled windows have margins: OFF"
	defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

	# "Desktop & Dock > Automatically rearrange Spaces based on most recent use: OFF"
	defaults write com.apple.dock mru-spaces -bool false

	# "Desktop & Dock > Group windows by application: ON"
	defaults write com.apple.dock expose-group-apps -bool true

	# "Desktop & Dock > Displays have separate Spaces: OFF"
	defaults write com.apple.dock spans-displays -bool true

	# "Desktop & Dock > Drag windows to top of screen to enter Mission Control: OFF"
	defaults write com.apple.dock enterMissionControlByTopWindowDrag -bool false

	# "Desktop & Dock > Hot Corners > Bottom right: –"
	defaults write com.apple.dock wvous-br-corner -int 0

	# show only open applications in the Dock
	defaults write com.apple.dock static-only -bool true

	# remove the auto-hiding Dock delay
	defaults write com.apple.dock autohide-delay -float 3600

	# "Notifications > Allow notifications when the screen is locked: OFF"
	# TODO

	# "Keyboard > Key repeat rate: Fast"
	defaults write -g KeyRepeat -int 2
	# "Keyboard > Delay until repeat: Short"
	defaults write -g InitialKeyRepeat -int 15
	# "Keyboard > Keyboard navigation: ON"
	defaults write -g AppleKeyboardUIMode -int 2
	# "Keyboard > Keyboard Shortcuts > Display > Decrease display brightness: OFF"
	set_symbolic_hotkey 53 false 65535 107 8388608
	# "Keyboard > Keyboard Shortcuts > Display > Increase display brightness: OFF"
	set_symbolic_hotkey 54 false 65535 113 8388608

	# "Keyboard > Keyboard Shortcuts > Keyboard > Change the way Tab moves focus: OFF"
	set_symbolic_hotkey 13 false 65535 98 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Turn keyboard access on or off: OFF"
	set_symbolic_hotkey 12 false 65535 98 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to the menu bar: OFF"
	set_symbolic_hotkey 7 false 65535 122 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to the Dock: OFF"
	set_symbolic_hotkey 8 false 65535 99 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to active or next window: OFF"
	set_symbolic_hotkey 9 false 65535 118 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to the window toolbar: OFF"
	set_symbolic_hotkey 10 false 65535 96 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to the floating window: OFF"
	set_symbolic_hotkey 11 false 65535 97 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to next window: OFF"
	set_symbolic_hotkey 27 false 96 50 1048576
	# "Keyboard > Keyboard Shortcuts > Keyboard > Move focus to status menus: OFF"
	set_symbolic_hotkey 57 false 65535 100 8650752
	# "Keyboard > Keyboard Shortcuts > Keyboard > Show contextual menu: OFF"
	set_symbolic_hotkey 159 false 65535 36 262144

	# "Keyboard > Keyboard Shortcuts > Input Sources > Select the previous input source: OFF"
	set_symbolic_hotkey 61 false 32 49 786432
	# "Keyboard > Keyboard Shortcuts > Input Sources > Select next source in input menu: F12"
	set_symbolic_hotkey 60 true 65535 111 8388608

	# "Keyboard > Keyboard Shortcuts > Screenshots > Save picture of screen as a file: OFF"
	set_symbolic_hotkey 28 false 51 20 1179648
	# "Keyboard > Keyboard Shortcuts > Screenshots > Copy picture of screen to the clipboard: OFF"
	set_symbolic_hotkey 29 false 51 20 1441792
	# "Keyboard > Keyboard Shortcuts > Screenshots > Save picture of selected area as a file: OFF"
	set_symbolic_hotkey 30 false 52 21 1179648
	# "Keyboard > Keyboard Shortcuts > Screenshots > Copy picture of selected area to the clipboard: OFF"
	set_symbolic_hotkey 31 false 52 21 1441792
	# "Keyboard > Keyboard Shortcuts > Screenshots > Screenshot and recording options: OFF"
	set_symbolic_hotkey 184 false 53 23 1179648

	# "Keyboard > Keyboard Shortcuts > Spotlight > Show Spotlight search: ⌃⌥⌘SPACE"
	set_symbolic_hotkey 64 true 32 49 1835008
	# "Keyboard > Keyboard Shortcuts > Spotlight > Show Finder search window: OFF"
	set_symbolic_hotkey 65 false 32 49 1572864

	# "Keyboard > Keyboard Shortcuts > App Shortcuts > All Applications > Show Help menu: OFF"
	set_symbolic_hotkey 98 false 47 44 1179648

	# "Keyboard > Keyboard Shortcuts > Function Keys > Use F1, F2, etc. keys as standard function keys: ON"
	defaults write -g com.apple.keyboard.fnState -bool true

	# "Keyboard > Keyboard Shortcuts > Mission Control > Move left a space: OFF"
	set_symbolic_hotkey 80 false 65535 123 8781824
	# "Keyboard > Keyboard Shortcuts > Mission Control > Move right a space: OFF"
	set_symbolic_hotkey 81 false 65535 124 8650752

	# "Trackpad > Point & Click > Loop up & data detectors: tap with 3 fingers"
	set_trackpad_option TrackpadThreeFingerTapGesture -int 2
	# "Trackpad > Point & Click > Tap to click: ON"
	set_trackpad_option Clicking -bool true
	# "Trackpad > Scroll & Zoom > Natural scrolling: OFF"
	defaults write -g com.apple.swipescrolldirection -bool false
	# "Trackpad > More Gestures > Swipe between pages: OFF"
	defaults write -g AppleEnableSwipeNavigateWithScrolls -bool false
	# "Trackpad > More Gestures > Swipe between full–screen applications: OFF"
	set_trackpad_option TrackpadFourFingerHorizSwipeGesture -int 0
	set_trackpad_option TrackpadThreeFingerHorizSwipeGesture -int 0
	# "Trackpad > More Gestures > Notification Center: OFF"
	set_trackpad_option TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
	# "Trackpad > More Gestures > Mission Control: OFF"
	defaults write com.apple.dock showMissionControlGestureEnabled -bool false
	set_trackpad_option TrackpadFourFingerVertSwipeGesture -int 0
	set_trackpad_option TrackpadThreeFingerVertSwipeGesture -int 0
	# "Trackpad > More Gestures > Launchpad: OFF"
	defaults write com.apple.dock showLaunchpadGestureEnabled -bool false
	# "Trackpad > More Gestures > Show Desktop: OFF"
	defaults write com.apple.dock showDesktopGestureEnabled -bool false
	set_trackpad_option TrackpadFiveFingerPinchGesture -int 0
	set_trackpad_option TrackpadFourFingerPinchGesture -int 0
	# "Mouse > Point & Click > Secondary click: click on right side"
	set_mouse_option MouseButtonMode -string TwoButton
	# "Mouse > enable smart zoom"
	set_mouse_option MouseOneFingerDoubleTapGesture -int 1
	# "Mouse > More Gestures > Swipe between pages: swipe left or right with one finger"
	defaults write -g AppleEnableMouseSwipeNavigateWithScrolls -bool true
	# "Mouse > More Gestures > disable swipe between full screen apps"
	set_mouse_option MouseTwoFingerHorizSwipeGesture -int 0
	# "Mouse > More Gestures > Disable mission control"
	set_mouse_option MouseTwoFingerDoubleTapGesture -int 0

	#################################################################################
	# fzf
	#################################################################################

	if [ ! -f ~/.fzf.zsh ] || [ ! -f ~/.fzf.bash ]; then
		fzfpath=/opt/homebrew/opt/fzf/install
		if [ -f "$fzfpath" ]; then
			yes | "$fzfpath"
		fi
	fi

	################################
	# ChatGPT
	################################
	# Show in Menubar: Never
	defaults write com.openai.chat desktopAppIconBehavior -string '{"showOnlyInDock":{}}'
	defaults write com.openai.chat appPairingDefaultOn -bool false
	defaults write com.openai.chat KeyboardShortcuts_toggleLauncher -string '{"carbonModifiers":6912,"carbonKeyCode":35}'

	################################
	# CleanShot X
	################################
	defaults write pl.maketheweb.cleanshotx SUEnableAutomaticChecks -bool true
	defaults write pl.maketheweb.cleanshotx SUHasLaunchedBefore -bool true
	defaults write pl.maketheweb.cleanshotx activationKey -string "${CLEANSHOT_X_LICENSE_KEY}"
	defaults write pl.maketheweb.cleanshotx afterScreenshotActions -array 3
	defaults write pl.maketheweb.cleanshotx analyticsAllowed -bool false
	defaults write pl.maketheweb.cleanshotx inverseArrowDirection -bool true
	defaults write pl.maketheweb.cleanshotx onboardingDisplayed -bool true

	################################
	# Dash
	################################
	# license
	defaults write license.dash-license Product -string "$DASH_LICENSE_PRODUCT"
	defaults write license.dash-license Name -string "$DASH_LICENSE_NAME"
	defaults write license.dash-license Email -string "$DASH_LICENSE_EMAIL"
	defaults write license.dash-license Licenses -string "$DASH_LICENSE_LICENSES"
	defaults write license.dash-license Timestamp -string "$DASH_LICENSE_TIMESTAMP"
	defaults write license.dash-license Version -string "$DASH_LICENSE_VERSION"
	defaults write license.dash-license TransactionID -string "$DASH_LICENSE_TRANSACTION_ID"
	defaults write license.dash-license Signature -data "$DASH_LICENSE_SIGNATURE"

	plutil -convert xml1 ~/Library/Preferences/license.dash-license.plist
	dst="$HOME/Library/Application Support/Dash/License"
	mkdir -p "$dst"
	mv "$HOME/Library/Preferences/license.dash-license.plist" "$dst/license.dash-license"

	defaults write com.kapeli.dashdoc syncFolderPath -string ~/.config/dash
	defaults write com.kapeli.dashdoc shouldSyncBookmarks -bool true
	defaults write com.kapeli.dashdoc shouldSyncDocsets -bool true
	defaults write com.kapeli.dashdoc shouldSyncGeneral -bool true
	defaults write com.kapeli.dashdoc shouldSyncView -bool true
	# Surpress the docsets tooltip
	defaults write com.kapeli.dashdoc DHNotificationDocsetPressEnterOrClickIconTip -bool true
	# Surpress table of contexts tooltip
	defaults write com.kapeli.dashdoc DHNotificationTableOfContentsTip -bool true
	# Surpress nested contents tooltip
	defaults write com.kapeli.dashdoc DHNotificationNestedResultTip -bool true
	# surpress find in page tooltip
	defaults write com.kapeli.dashdoc DHNotificationFindTip -bool true
	# surpress the menu bar icon tooltip
	defaults write com.kapeli.dashdoc didShowStatusIconHello -bool true
	# surpress unofficial repos warning
	defaults write com.kapeli.dashdoc userContributedRepoUnlocked -bool true
	defaults write com.kapeli.dashdoc githubRepoUnlocked -bool true
	defaults write com.kapeli.dashdoc stackOverflowRepoUnlocked -bool true
	# dark style for docs
	defaults write com.kapeli.dashdoc actuallyDarkWebView -bool true
	# Automatically update
	defaults write com.kapeli.dashdoc SUAutomaticallyUpdate -bool true
	defaults write com.kapeli.dashdoc SUEnableAutomaticChecks -bool true
	defaults write com.kapeli.dashdoc SUHasLaunchedBefore -bool true

	################################
	# Finbar
	################################
	defaults write com.roeybiran.Finbar "NSStatusItem Visible Item-0" -bool true
	defaults write com.roeybiran.Finbar RBInputSourceKit_preferredInputSourceID -string com.apple.keylayout.ABC
	defaults write com.roeybiran.Finbar RBShortcutKit_Shortcuts -dict-add toggleFinbar '{ keyCode = 2; modifiers = 6912; }'
	defaults write com.roeybiran.Finbar SUEnableAutomaticChecks -bool true
	defaults write com.roeybiran.Finbar SUHasLaunchedBefore -bool true
	defaults write com.roeybiran.Finbar license -string "$FINBAR_LICENSE"
	defaults write com.roeybiran.Finbar preferredScreen -string withKeyboardFocus
	defaults write com.roeybiran.Finbar browsingMode -int 1
	defaults write com.roeybiran.Finbar menuBarRules -data '<5B7B22707265646963617465223A227469746C65203D3D205C224170706C655C22222C226964223A2244363343303031312D363445372D343535432D413646422D383635453346333741413237222C226465736372697074696F6E223A224170706C65204D656E75227D2C7B226964223A2232423133303035352D393133422D343841382D423743412D413832323243364136314336222C226465736372697074696F6E223A2253616661726920486973746F7279222C22707265646963617465223A2262756E646C654964656E746966696572203D3D205C22636F6D2E6170706C652E5361666172695C2220414E4420287469746C65203D3D205C22486973746F72795C22204F52207469746C65203D3D205C22426F6F6B6D61726B735C2229227D5D>'

	################################
	# Syphon
	################################
	defaults write com.roeybiran.Syphon RBInputSourceKit_preferredInputSourceID -string "com.apple.keylayout.ABC"
	defaults write com.roeybiran.Syphon SUAutomaticallyUpdate -bool true
	defaults write com.roeybiran.Syphon SUEnableAutomaticChecks -bool true
	defaults write com.roeybiran.Syphon SUHasLaunchedBefore -bool true
	defaults write com.roeybiran.Syphon didOnboard -bool true
	defaults write com.roeybiran.Syphon hiddenAppsSortingStyle -int 2
	defaults write com.roeybiran.Syphon minimizedWindowsSortingStyle -int 2
	defaults write com.roeybiran.Syphon searchFieldHidesWhenEmpty -bool true
	defaults write com.roeybiran.Syphon license -string "$SYPHON_LICENSE"
	defaults write com.roeybiran.Syphon aliases -data '<5B7B22616C696173223A2277222C226964223A2234434434363732372D433930382D344133412D424433322D444639303045303341433437222C2262756E646C654944223A226E65742E77686174736170702E5768617473417070227D2C7B22616C696173223A2263222C226964223A2242444243423246352D304438302D344237352D394146342D464233303531353430414234222C2262756E646C654944223A22636F6D2E6170706C652E6943616C227D2C7B22616C696173223A2274222C226964223A2246373336423542452D373031422D343336362D414141322D353142434334363136343842222C2262756E646C654944223A22636F6D2E6769746875622E77657A2E77657A7465726D227D2C7B22616C696173223A227077222C226964223A2238333846334245392D353330432D344644462D413536432D383834454335334143414245222C2262756E646C654944223A226F72672E6368726F6D69756D2E4368726F6D69756D227D5D>'
	defaults write com.roeybiran.Syphon rules -data '<5B7B226964223A2246313039313034412D344544352D344242322D414230432D353537414546453534464338222C2262756E646C654944223A22636F6D2E6170706C652E6943616C222C226B696E64223A307D2C7B226964223A2230343934433543352D433341432D344634362D414333452D414633363831373139313436222C2262756E646C654944223A22636F6D2E6F70656E61692E63686174222C226B696E64223A307D2C7B226964223A2233433033434346322D453932432D344433362D394245422D333631334635324630453632222C2262756E646C654944223A22636F6D2E6B6170656C692E64617368646F63222C226B696E64223A307D2C7B226964223A2242314644313943342D454435462D343646362D393434392D424244334430304542354536222C2262756E646C654944223A22636F6D2E6170706C652E66696E646572222C226B696E64223A317D2C7B2262756E646C654944223A22636F6D2E676574666C79776865656C2E6C696768746E696E672E6C6F63616C222C226B696E64223A302C226964223A2230313734384245442D413933462D343031372D424533352D374130313138393732424631227D2C7B2262756E646C654944223A22636F6D2E6170706C652E6D61696C222C226B696E64223A302C226964223A2239414530354532312D373037332D343535312D383136362D414642433342443537333532227D2C7B2262756E646C654944223A22636F6D2E6170706C652E4E6F746573222C226B696E64223A302C226964223A2232453131314633302D374334442D344637382D423343352D414545384441453035354237227D2C7B2262756E646C654944223A226E65742E77686174736170702E5768617473417070222C226B696E64223A302C226964223A2235304443343945382D444633432D343037382D424430362D313135333246453436324346227D5D>'

	################################
	# Knobby
	################################

	if [ ! -d /Applications/Knobby.app ]; then
		install_app_from_github_releases roeybiran/Knobby
	fi

	defaults write com.roeybiran.Knobby "NSStatusItem Visible Item-0" -bool true
	defaults write com.roeybiran.Knobby KeyboardShortcuts_toggleKnobby -string '{"carbonKeyCode":40,"carbonModifiers":6912}'

	################################
	# LaunchBar
	################################

	# Show all subtitles
	defaults write at.obdev.LaunchBar ShowItemListSubtitles -bool true
	# visible rows in abbreviation search
	defaults write at.obdev.LaunchBar ItemListVisibleRows -int 32
	# visible rows while browsing
	defaults write at.obdev.LaunchBar ItemListVisibleRowsWhileBrowsing -int 64
	# don't always show abbreviation
	defaults write at.obdev.LaunchBar ShowAbbreviation -bool false
	# [ ] Search in Spotlight
	defaults write at.obdev.LaunchBar SpotlightHotKeyEnabled -bool false
	# Instant Send: [Double Shift]
	defaults write at.obdev.LaunchBar ModifierTapInstantSend -int 24
	# instant info browsing
	defaults write at.obdev.LaunchBar InstantInfoBrowsing -bool true
	### Actions
	### Actions > Default Actions
	# instant-open folders: browse in LaunchBar
	defaults write at.obdev.LaunchBar InstantOpenBrowseFolders -bool true
	# open applescripts with editor
	defaults write at.obdev.LaunchBar RunAppleScripts -bool false
	# open automator workflows with automator
	defaults write at.obdev.LaunchBar RunWorkflows -bool false
	# Phone numbers:
	defaults write at.obdev.LaunchBar PhoneHandler -string "%@/Contents/Resources/Actions/Call with iPhone.lbaction"
	### Actions > Options
	# [✓] Show files and folders in currnet Finder window
	defaults write at.obdev.LaunchBar UseCurrentFileBrowserWindow -bool true
	# play songs: play single song
	defaults write at.obdev.LaunchBar SongPlaybackMode -int 2
	# Calculator
	# don't switch to calculator when typing digits
	defaults write at.obdev.LaunchBar SwitchToCalculatorAutomatically -bool false
	# Clipboard
	# Capacity: 1 week
	defaults write at.obdev.LaunchBar ClipboardHistoryCapacity -string -7
	# Action
	defaults write at.obdev.LaunchBar ClipboardHistoryAction -int 2
	# enable clipmerge
	defaults write at.obdev.LaunchBar ClipMergeEnabled -bool true
	# [✓] Show clipboard history: ⌃⌥⇧⌘G
	defaults write at.obdev.LaunchBar ShowClipboardHistoryHotKey -string 6912@5
	defaults write at.obdev.LaunchBar ShowClipboardHistoryHotKeyEnabled -bool true
	# [ ] Select from history
	defaults write at.obdev.LaunchBar SelectFromClipboardHistoryHotKeyEnabled -bool false
	# [ ] Paste and remove from history
	defaults write at.obdev.LaunchBar PasteClipboardHistoryHotKeyEnabled -bool false
	# Advanced
	# [✓] Abbreviate home folder with ~ in copied paths
	defaults write at.obdev.LaunchBar AbbreviateFilePaths -bool false
	# [✓] Convert filename extension to lowercase when renaming
	defaults write at.obdev.LaunchBar RenameConvertsExtensionToLowercase -bool true
	# [ ] Show Dock Icon
	defaults write at.obdev.LaunchBar ShowDockIcon -bool false
	# Preferred input source: [ABC]
	defaults write at.obdev.LaunchBar PreferredKeyboardInputSource -string com.apple.keylayout.ABC
	# Skip the welcome window
	defaults write at.obdev.LaunchBar WelcomeWindowVersion -int 2
	# snippets
	defaults write at.obdev.LaunchBar SnippetsHotKey -string 6912@27
	defaults write at.obdev.LaunchBar SnippetsHotKeyEnabled -bool false
	# action editor
	defaults write at.obdev.LaunchBar.ActionEditor myBundleIdentifier -string com.roeybiran
	defaults write at.obdev.LaunchBar.ActionEditor personalInformationAuthor -string "Roey Biran"
	defaults write at.obdev.LaunchBar.ActionEditor personalInformationEmailString -string roeybiran@icloud.com
	defaults write at.obdev.LaunchBar.ActionEditor personalInformationWebsite -string https://github.com/roeybiran
	defaults write at.obdev.LaunchBar.ActionEditor personalInformationTwitter -string @RoeyBiran

	################################
	# Velja
	################################
	defaults write com.sindresorhus.Velja hideMenuBarIcon -bool true
	defaults write com.sindresorhus.Velja menuBarIcon -string primaryBrowser

	################################
	# Visual Studio Code
	################################
	defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
	defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false

	################################
	# Cursor
	################################
	defaults write com.todesktop.230313mzl4w4u92 ApplePressAndHoldEnabled -bool false

	################################
	# Hammerspoon
	################################
	defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

	################################
	# Homerow
	################################
	defaults write com.superultra.Homerow "NSStatusItem Visible Item-0" -bool false
	defaults write com.superultra.Homerow SUEnableAutomaticChecks -bool true
	defaults write com.superultra.Homerow SUHasLaunchedBefore -bool true
	defaults write com.superultra.Homerow auto-switch-input-source-id -string "com.apple.keylayout.ABC"
	defaults write com.superultra.Homerow launch-at-login -bool true
	defaults write com.superultra.Homerow non-search-shortcut -string '\U2303\U2325\U21e7\U2318F'
	defaults write com.superultra.Homerow scroll-shortcut -string ""
	defaults write com.superultra.Homerow show-menubar-icon -bool false

	################################
	# Xcode
	################################
	if command -v xcodebuild &>/dev/null; then
		sudo xcodebuild -license accept
		sudo /usr/sbin/DevToolsSecurity --enable 1>/dev/null 2>&1
	fi

	# https://github.com/airbnb/swift/blob/master/resources/xcode_settings.bash
	defaults write com.apple.dt.Xcode AutomaticallyCheckSpellingWhileTyping -bool YES
	defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool YES
	defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool YES
	defaults write com.apple.dt.Xcode DVTTextIndentTabWidth -int 2
	defaults write com.apple.dt.Xcode DVTTextIndentWidth -int 2
	defaults write com.apple.dt.Xcode DVTTextPageGuideLocation -int 100

	# add custom counterparts
	defaults write com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes -array-add Tests tests

	# show build durations
	defaults write com.apple.dt.Xcode "ShowBuildOperationDuration" -bool true

	# "General"
	defaults write com.apple.dt.Xcode IDESuppressStopExecutionWarning -bool true
	defaults write com.apple.dt.Xcode IDESuppressStopExecutionWarningTarget -string IDESuppressStopExecutionWarningTargetValue_Stop
	defaults write com.apple.dt.Xcode IDESuppressStopTestWarning -bool true
	defaults write com.apple.dt.Xcode IDEWorkspaceSuppressCleanBuildPrompt -bool true
	defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool true
	defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool true

	# "Navigation"
	defaults write com.apple.dt.Xcode IDECommandClickOnCodeAction -int 1
	defaults write com.apple.dt.Xcode IDEEditorCoordinatorTarget_Alternate -string SeparateTab
	defaults write com.apple.dt.Xcode IDEEditorNavigationStyle_DefaultsKey -string IDEEditorNavigationStyle_OpenInPlace

	# "Themes"
	defaults write com.apple.dt.Xcode XCFontAndColorCurrentDarkTheme -string "Default (Dark) - Customized.xccolortheme"
	defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme -string "Default (Light) - Customized.xccolortheme"

	# "Text Editing > Display > Wrap Lines to Editor Width: OFF"
	defaults write com.apple.dt.Xcode DVTTextEditorWrapsLines -bool false

	# Text Editing > Editing > Show reformatting guide: ON"
	defaults write com.apple.dt.Xcode DVTTextShowPageGuide -bool true

	# "Text Editing > Editing > Convert existing files on save: ON"
	defaults write com.apple.dt.Xcode DVTConvertExistingFilesLineEndings -bool true

	# "Text Editing > Indentation > Re-indent on paste: ON"
	defaults write com.apple.dt.Xcode DVTTextIndentOnPaste -bool true

	# "Text Editing > Indentation > Align consecutive // comments: ON"
	defaults write com.apple.dt.Xcode DVTTextAlignConsecutiveSlashSlashComments -bool true

	# Key Bindings
	defaults write com.apple.dt.Xcode IDEKeyBindingCurrentPreferenceSet -string "Customized Default.idekeybindings"

	################################
	# UI Browser
	################################
	defaults write com.pfiddlesoft.uibrowser EProduct -string "$UIBROWSER_PRODUCT"
	defaults write com.pfiddlesoft.uibrowser EKey -string "$UIBROWSER_KEY"
	defaults write com.pfiddlesoft.uibrowser EName -string "$UIBROWSER_NAME"
	# Accessibility names: (·) Technical
	defaults write com.pfiddlesoft.uibrowser "Terminology style" -int 1
	# [✓] Copy script to clipboard (·) Always
	defaults write com.pfiddlesoft.uibrowser "Copy new script to clipboard" -bool true
	# [✓] Send script to script editor (·) Always
	defaults write com.pfiddlesoft.uibrowser "Send new script to script editor" -bool true
	# [✓] Include application process
	defaults write com.pfiddlesoft.uibrowser "New script includes process reference" -bool true
	# [ ] Hot keys active
	defaults write com.pfiddlesoft.uibrowser "Hotkeys active" -bool false
	# Don‘t show
	defaults write com.pfiddlesoft.uibrowser noOptionalAlertsSuppressed -bool false
	# Don‘t show
	defaults write com.pfiddlesoft.uibrowser targetApplicationTerminatedAlertSuppressed -bool true
	# Don‘t show the ‘UI Element Destroyed‘ pop-up
	defaults write com.pfiddlesoft.uibrowser selectedElementDestroyedAlertSuppressed -bool true
	# Don‘t show
	defaults write com.pfiddlesoft.uibrowser applescriptWindowOpenAlertSuppressed -bool true
	# skip welcome
	defaults write com.pfiddlesoft.uibrowser "First run" -bool false
	defaults write com.pfiddlesoft.uibrowser "Use AppleScript URL Protocol" -bool false
	defaults write com.pfiddlesoft.uibrowser "Use AppleScript default script editor" -bool false
	defaults write com.pfiddlesoft.uibrowser "Default script editor" -bool true
	defaults write com.pfiddlesoft.uibrowser "Ignore AppleScript default script editor" -bool true
	defaults write com.pfiddlesoft.uibrowser "Background apps listed" -bool true
	defaults write com.pfiddlesoft.uibrowser "Background apps listed separately" -bool true
	defaults write com.pfiddlesoft.uibrowser "Send new script to script editor" -bool false
	defaults write com.pfiddlesoft.uibrowser "Registering notification opens log window" -bool true
	# Suppress Rosetta Alert
	defaults write com.pfiddlesoft.uibrowser RosettaAlertsSuppressed -bool true

}

installations() {
	if ! command -v brew &>/dev/null; then
		# install Homebrew
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		# add Homebrew to PATH
		echo >>"/Users/$USER/.zprofile"
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"/Users/$USER/.zprofile"
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi

	if ! command -v xcodebuild &>/dev/null; then
		xcodes install --latest --select
	fi

	for package in "${BREW_PACKAGES[@]}"; do
		brew_install "$package"
	done

	if [ ! -d "$HOME/.zsh/spaceship-vi-mode" ]; then
		mkdir -p "$HOME/.zsh"
		git clone --depth=1 https://github.com/spaceship-prompt/spaceship-vi-mode.git "$HOME/.zsh/spaceship-vi-mode"
	fi

	npm install -g create-dmg
	npm install -g np

	for package in "${BREW_CASK_PACKAGES[@]}"; do
		brew_cask_install "$package"
	done

	for app in "${!MAS_APPS[@]}"; do
		mas_install "$app" "${MAS_APPS[$app]}"
	done
}

if [[ "$1" == "link" ]]; then
	symlinks
elif [[ $# -eq 0 ]]; then
	symlinks
	config
	install
fi
