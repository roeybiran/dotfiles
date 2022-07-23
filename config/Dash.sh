#!/bin/sh

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

# sync folder
defaults write com.kapeli.dashdoc syncFolderPath -string ~/.dash

# syncing options
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
# shortcuts
defaults write com.kapeli.dashdoc NSUserKeyEquivalents -dict-add "Show Bookmarks..." @~b
