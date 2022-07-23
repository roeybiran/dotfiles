#!/bin/sh

if [ -d /Applications/Xcode.app ]; then
	sudo xcodebuild -license accept
	sudo /usr/sbin/DevToolsSecurity --enable
	# sudo xcode-select -s /Applications/Xcode.app/Contents/Developer/
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
# ... at column 100 (default is column 80)
defaults write com.apple.dt.Xcode DVTTextPageGuideLocation -int 100
# don't wrap lines
defaults write com.apple.dt.Xcode DVTTextEditorWrapsLines -bool false
# -- Editing --
# automatically trim trialing whitespace
defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool true
# including whitespace only lines
defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool true
# convert existing files on save
defaults write com.apple.dt.Xcode DVTConvertExistingFilesLineEndings -bool true
# -- Indendation --
# tab width: 2 spaces
defaults write com.apple.dt.Xcode DVTTextIndentTabWidth -int 2
# indent width: 2 spaces
defaults write com.apple.dt.Xcode DVTTextIndentWidth -int 2
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
