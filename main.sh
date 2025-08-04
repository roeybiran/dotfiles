#!/usr/bin/env bash

# set -e
# set -u
# set -o pipefail
set +x 

sudo -v

# constants
my_login_items=(
	/Applications/Hammerspoon.app
	/Applications/Raycast.app
	/Applications/Finbar.app
	/Applications/Dropbox.app
	/Applications/Knobby.app
	/Applications/Velja.app
	/Applications/LaunchBar.app
	/Applications/kitty.app
)

add_login_items() {
	for app in "${my_login_items[@]}"; do
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

link() {
	local src="$1"
	local dst="$2"

	local parent;
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

source "$PWD/private/secrets.sh"

if ! command -v brew &>/dev/null; then
	# install Homebrew
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# add Homebrew to PATH
	echo >>"/Users/$USER/.zprofile"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"/Users/$USER/.zprofile"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

########################################################
# General
########################################################
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

########################################################
# Symlinks
########################################################
# dotfiles
link "$PWD/.aliases" "$HOME/.aliases"
link "$PWD/.gitconfig" "$HOME/.gitconfig"
link "$PWD/.gitignore" "$HOME/.gitignore"
link "$PWD/.zshrc" "$HOME/.zshrc"
link "$PWD/.scripts" "$HOME/.scripts"
link "$PWD/claude_code/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$PWD/claude_code/settings.json" "$HOME/.claude/settings.json"

# config
link "$PWD/nvim" "$HOME/.config/nvim"
link "$PWD/karabiner" "$HOME/.config/karabiner"
link "$PWD/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
link "$PWD/kitty" "$HOME/.config/kitty"
link "$PWD/atuin/config.toml" "$HOME/.config/atuin/config.toml"
link "$PWD/spaceship/spaceship.zsh" "$HOME/.config/spaceship/spaceship.zsh"
link "$PWD/ghostty/config" "$HOME/.config/ghostty/config"

# tmux
link "$PWD/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$PWD/tmux/.tmux_colorscheme.sh" "$HOME/.tmux_colorscheme.sh"

# apps
link "$PWD/.hammerspoon" "$HOME/.hammerspoon"
link "$PWD/.dash" "$HOME/.dash"
link "$PWD/LaunchBar" "$HOME/Library/Application Support/LaunchBar"
link "$PWD/xcode/xcode_macros.plist" "$HOME/Library/Developer/Xcode/UserData/IDETemplateMacros.plist"
link "$PWD/xcode/xcode_snippets" "$HOME/Library/Developer/Xcode/UserData/CodeSnippets"
link "$PWD/xcode/xcode_themes" "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes"
link "$PWD/finbar_scripts" "$HOME/Library/Application Scripts/com.roeybiran.Finbar"

# private
link "$PWD/private/.history" "$HOME/.history"
link "$PWD/private/.ssh/config" "$HOME/.ssh/config"
link "$PWD/private/finbar_recents.json" "$HOME/Library/Application Support/com.roeybiran.Finbar/recents.json"
link "$PWD/private/zoxide" "$HOME/Library/Application Support/zoxide"

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
# [ ] Open safe files after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
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

# "Keyboard > Keyboard Shortcuts > App Shortcuts"
# defaults write com.apple.AddressBook NSUserKeyEquivalents -dict-add "Edit Card" @e
# defaults write com.apple.AddressBook NSUserKeyEquivalents -dict-add "Hide Groups" @~s
# defaults write com.apple.AddressBook NSUserKeyEquivalents -dict-add "Show Groups" @~s
# defaults write com.apple.Dictionary NSUserKeyEquivalents -dict-add "Select Next Dictionary" '@~→'
# defaults write com.apple.Dictionary NSUserKeyEquivalents -dict-add "Select Previous Dictionary" '@~←'
# defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Go to Date\U2026' -string '@$g'
# defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Hide Calendar List' -string '@^1'
# defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Hide Notifications' -string '@^2'
# defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Show Calendar List' -string '@^1'
# defaults write com.apple.iCal NSUserKeyEquivalents -dict-add 'Show Notifications' -string '@^2'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "New Slide" '@n'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Next Slide" -string '@]'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Previous Slide" -string '@['
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Zoom In" '@='
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Zoom Out" '@-'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add Bigger '@$.'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add Group '@g'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add Smaller '@$,'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add Ungroup '@$g'
# defaults write com.apple.iWork.Numbers NSUserKeyEquivalents -dict-add "Align Center" -string '@$\'
# defaults write com.apple.iWork.Numbers NSUserKeyEquivalents -dict-add "Align Left" -string '@$['
# defaults write com.apple.iWork.Numbers NSUserKeyEquivalents -dict-add "Align Right" -string '@$]'
# defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Zoom In" @=
# defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Zoom Out" @-
# defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add Bigger '@$.'
# defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add Smaller '@$,'
# defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add Strikethrough @^s
# defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Export as PDF…" '@$e'
# defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Save Attachments…" '@$s'
# defaults write com.apple.Notes NSUserKeyEquivalents -dict-add "Zoom In" @=
# defaults write com.apple.Notes NSUserKeyEquivalents -dict-add "Zoom Out" @-
# defaults write com.apple.Notes NSUserKeyEquivalents -dict-add Bigger '@$.'
# defaults write com.apple.Notes NSUserKeyEquivalents -dict-add Smaller '@$,'
# defaults write com.apple.Notes NSUserKeyEquivalents -dict-add Strikethrough @^s
# defaults write com.apple.Photos NSUserKeyEquivalents -dict-add "Show Edit Tools" @e
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Actual Size" @9
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Contact Sheet" @6
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Continuous Scroll" ^1
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Go to Page..." '@$G'
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Hide Sidebar" @1
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Highlights and Notes" @4
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Single Page" ^2
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Table of Contents" @3
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Two Pages" ^3
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add "Zoom to Fit" @0
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add Bookmarks @5
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add Slideshow @~y
# defaults write com.apple.Preview NSUserKeyEquivalents -dict-add Thumbnails @2
# defaults write com.apple.reminders NSUserKeyEquivalents -dict-add "Clear Flag" '@$l'
# defaults write com.apple.reminders NSUserKeyEquivalents -dict-add "Hide Sidebar" @~s
# defaults write com.apple.reminders NSUserKeyEquivalents -dict-add Flag '@$l'
# defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "Hide Sidebar" @~s
# defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "Show Sidebar" @~s
# defaults write com.apple.TextEdit NSUserKeyEquivalents -dict-add "Zoom In" -string '@='
# defaults write com.apple.TextEdit NSUserKeyEquivalents -dict-add "Zoom Out" -string '@-'
# defaults write com.apple.TextEdit NSUserKeyEquivalents -dict-add Bigger -string '@$='
# defaults write com.apple.TextEdit NSUserKeyEquivalents -dict-add Smaller -string '@$-'
# defaults write com.bohemiancoding.sketch3 NSUserKeyEquivalents -dict-add Bigger '@$.'
# defaults write com.bohemiancoding.sketch3 NSUserKeyEquivalents -dict-add Smaller '@$,'
# defaults write com.kapeli.dashdoc NSUserKeyEquivalents -dict-add "Show Bookmarks..." @~b

# "Keyboard > Keyboard Shortcuts > Function Keys > Use F1, F2, etc. keys as standard function keys: ON"
defaults write -g com.apple.keyboard.fnState -bool true
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

brew install "fzf"

if [ ! -f ~/.fzf.zsh ] || [ ! -f ~/.fzf.bash ]; then
	fzfpath=/opt/homebrew/opt/fzf/install
	if [ -f "$fzfpath" ]; then
		yes | "$fzfpath"
	fi
fi

################################
# Action Editor
################################
defaults write at.obdev.LaunchBar.ActionEditor myBundleIdentifier -string com.roeybiran
defaults write at.obdev.LaunchBar.ActionEditor personalInformationAuthor -string "Roey Biran"
defaults write at.obdev.LaunchBar.ActionEditor personalInformationEmailString -string roeybiran@icloud.com
defaults write at.obdev.LaunchBar.ActionEditor personalInformationWebsite -string https://github.com/roeybiran
defaults write at.obdev.LaunchBar.ActionEditor personalInformationTwitter -string @RoeyBiran

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

defaults write com.kapeli.dashdoc syncFolderPath -string ~/.dash
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
defaults write com.roeybiran.Finbar menuBarPredicate -array \
	'{
  "description" = "Apple Menu";
  "id" = "F7ED726A-0D31-4E92-91AA-9F884EA7D280";
  "predicate" = "title == \"Apple\"";
}' \
	'{
  "description" = "Brave Browser - History";
  "id" = "54D06217-282F-4AD4-BE3A-5FE710C3D9EF";
  "predicate" = "bundleIdentifier == \"com.brave.Browser\" AND path BEGINSWITH \"History\" AND index > 3 AND title != \"Show Full History\" AND depth == 1";
}' \
	'{
  "description" = "Safari - Bookmarks";
  "id" = "B61785D9-9F63-46B3-ADDA-02A72FD218F3";
  "predicate" = "bundleIdentifier == \"com.apple.Safari\" AND (path BEGINSWITH \"Bookmarks\" AND title != \"Bookmarks\" AND index >= 14)";
}' \
	'{
  "description" = "Safari - History";
  "id" = "F800D6E4-93BE-489E-9663-734320C5D57D";
  "predicate" = "bundleIdentifier == \"com.apple.Safari\" AND (path BEGINSWITH \"History\" AND title != \"Clear History\U2026\" AND (title == \"Recently Closed\" OR index >= 11))";
}'

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
# clipboard capacity: 1 week
defaults write at.obdev.LaunchBar ClipboardHistoryCapacity -string -7
# enable clipmerge
defaults write at.obdev.LaunchBar ClipMergeEnabled -bool true
# make the clipboard ignore apps
defaults write at.obdev.LaunchBar ClipboardHistoryIgnoreApplicationsEnabled -bool true
# ignore these apps in clipboard history
defaults write at.obdev.LaunchBar ClipboardHistoryIgnoreApplications -array com.apple.keychainaccess com.agilebits.onepassword
# [✓] Show clipboard history: ⌃⌥⇧⌘V
defaults write at.obdev.LaunchBar ShowClipboardHistoryHotKey -string 6912@9
defaults write at.obdev.LaunchBar ShowClipboardHistoryHotKeyEnabled -bool false
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
brew install aria2
brew install xcodes
xcodes install --latest

if [ -d /Applications/Xcode.app ]; then
	sudo xcode-select -s /Applications/Xcode.app/Contents/Developer/
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
# Send scripts to Script Debugger
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

################################
# INSTALLATIONS
################################
brew install bat
brew install eza
brew install fd
brew install ffmpeg
brew install font-symbols-only-nerd-font
brew install gh
brew install git-extras
brew install git-lfs
brew install icdiff
brew install jq
brew install lazygit
brew install mas
brew install neovim
brew install node
brew install periphery
brew install ripgrep
brew install shellcheck
brew install tldr
brew install tmux
brew install tpm
brew install trash
brew install wp-cli
brew install zoxide

# https://github.com/sindresorhus/create-dmg
if ! command create-dmg; then
	npm install --global create-dmg
	brew install graphicsmagick
	brew install imagemagick
fi

# brew install --cask alacritty
# brew install --cask ghostty
# brew install --cask kitty
brew install --cask wezterm@nightly

brew install --cask appcleaner
brew install --cask betterzip
brew install --cask chatgpt
brew install --cask cleanshot
brew install --cask cursor
brew install --cask dash
brew install --cask dropbox
brew install --cask figma
brew install --cask font-input
brew install --cask hammerspoon
brew install --cask homerow
brew install --cask karabiner-elements
brew install --cask launchbar
brew install --cask little-snitch
brew install --cask local
brew install --cask macdown
brew install --cask qlmarkdown
brew install --cask qlvideo
brew install --cask raycast
brew install --cask script-debugger
brew install --cask sf-symbols
brew install --cask slack
brew install --cask spotify
brew install --cask syntax-highlight
brew install --cask the-unarchiver
brew install --cask transmit
brew install --cask ui-browser
brew install --cask visual-studio-code

mas install 640199958  # Developer
mas install 1544743900 # Hush
mas install 409183694  # Keynote
mas install 409203825  # Numbers
mas install 409201541  # Pages
mas install 1584519802 # Vimlike
mas install 1437310115 # Select Like A Boss For Safari
mas install 1522267256 # Shareful
mas install 1607635845 # Velja
mas install 310633997  # WhatsApp
mas install 1320666476 # Wipr
