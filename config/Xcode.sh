#!/bin/sh

if [ -d /Applications/Xcode.app ]; then
	sudo xcodebuild -license accept
	sudo /usr/sbin/DevToolsSecurity --enable 1>/dev/null 2>&1
fi

# --- General ---
defaults write com.apple.dt.Xcode IDESuppressStopExecutionWarning -bool true
defaults write com.apple.dt.Xcode IDESuppressStopExecutionWarningTarget -string IDESuppressStopExecutionWarningTargetValue_Stop
defaults write com.apple.dt.Xcode IDESuppressStopTestWarning -bool true

# --- Navigation ---
defaults write com.apple.dt.Xcode IDECommandClickOnCodeAction -int 1
defaults write com.apple.dt.Xcode IDEEditorCoordinatorTarget_Alternate -string SeparateTab
defaults write com.apple.dt.Xcode IDEEditorNavigationStyle_DefaultsKey -string IDEEditorNavigationStyle_OpenInPlace

# --- Themes ---
defaults write com.apple.dt.Xcode XCFontAndColorCurrentDarkTheme -string "Default (Dark) - Customized.xccolortheme"
defaults write com.apple.dt.Xcode XCFontAndColorCurrentTheme -string "Default (Light) - Customized.xccolortheme"

# --- Text Editing ---
# -- Display --
# show page guide
defaults write com.apple.dt.Xcode DVTTextShowPageGuide -bool true
# don't wrap lines
defaults write com.apple.dt.Xcode DVTTextEditorWrapsLines -bool false
# -- Editing --
# convert existing files on save
defaults write com.apple.dt.Xcode DVTConvertExistingFilesLineEndings -bool true
# align consecutive // comments
defaults write com.apple.dt.Xcode DVTTextAlignConsecutiveSlashSlashComments -bool true
# re-indent on paste
defaults write com.apple.dt.Xcode DVTTextIndentOnPaste -bool true

# --- Key Bindings ---
defaults write com.apple.dt.Xcode IDEKeyBindingCurrentPreferenceSet -string "Customized Default.idekeybindings"

#
defaults write com.apple.dt.Xcode DVTTextShowMinimap -bool false

# --- hidden settigns ---
# add custom counterparts
defaults write com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes -array-add Tests tests
# show build durations
defaults write com.apple.dt.Xcode "ShowBuildOperationDuration" -bool true

# https://github.com/airbnb/swift/blob/master/resources/xcode_settings.bash
defaults write com.apple.dt.Xcode AutomaticallyCheckSpellingWhileTyping -bool YES
defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool YES
defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool YES
defaults write com.apple.dt.Xcode DVTTextIndentTabWidth -int 2
defaults write com.apple.dt.Xcode DVTTextIndentWidth -int 2
defaults write com.apple.dt.Xcode DVTTextPageGuideLocation -int 100
