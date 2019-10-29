#!/bin/bash

# messages in the cloud
defaults write com.apple.madrid CloudKitSyncingEnabled -bool true
defaults write com.apple.madrid enableCKSyncingV2 -bool true
# text substitutions
defaults write com.apple.sms hasBeenApprovedForSMSRelay -bool true

defaults write com.apple.iChat AddressMeInGroupchat -bool true
defaults write com.apple.iChat SaveConversationsOnClose -bool true

# Edit > Substitutions
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
defaults write "${HOME}/Library/Containers/com.apple.soagent/Data/Library/Preferences/com.apple.messageshelper.MessageController.plist" SOInputLineSettings -dict \
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

defaults write "com.apple.iChat.inputLine" inputLineSettingsKey -dict \
  automaticDashSubstitutionEnabled -bool true \
  automaticDataDetectionEnabled -bool true \
  automaticEmojiSubstitutionEnabled -bool true \
  automaticLinkDetectionEnabled -bool true \
  automaticQuoteSubstitutionEnabled -bool true \
  automaticSpellingCorrectionEnabled -bool true \
  automaticTextReplacementEnabled -bool true \
  continuousSpellCheckingEnabled -bool true \
  grammarCheckingEnabled -bool true \
  smartInsertDeleteEnabled -bool true
