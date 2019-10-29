#!/bin/bash

# When searching all mailboxes, also include results from Junk
defaults write 'com.apple.mail' IndexJunk -bool true

# Show Tab Bar
defaults write 'com.apple.mail' 'NSWindowTabbingShoudShowTabBarKey-MouseTrackingWindow-MessageViewer-(null)-VT-FS' -bool true

# [✓] Check Grammar with Spelling
defaults write 'com.apple.mail' CheckGrammarWithSpelling -bool true
defaults write 'com.apple.mail' WebGrammarCheckingEnabled -bool true

# [✓] Smart Links
defaults write 'com.apple.mail' WebAutomaticLinkDetectionEnabled -bool true

# Copy email addresses as foo@example.com instead of Foo Bar <foo@example.com> in Mail.app (- Mathias Bynens) *
defaults write 'com.apple.mail' AddressesIncludeNameOnPasteboard -bool false

# Disable inline attachments (just show the icons) (- Mathias Bynens) *
defaults write 'com.apple.mail' DisableInlineAttachmentViewing -bool true

# Send new messages from:
# defaults write 'com.apple.mail' NewMessageFromAddress -string "${_email}"
# defaults write 'com.apple.mail-shared' NewMessageFromAddress -string "${_email}"

# Set favorite mailboxes: Inbox, Sent, Drafts, All Mail, Trash, Flagged, Junk
defaults write 'com.apple.mail' Favorites -array \
'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Inbox</string><key>MailboxUidPersistentIdentifier</key><string>Inbox</string><key>MailboxUidType</key><string>100</string></dict>' \
'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Sent</string><key>MailboxUidPersistentIdentifier</key><string>Sent Messages</string><key>MailboxUidType</key><string>102</string></dict>' \
'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Drafts</string><key>MailboxUidPersistentIdentifier</key><string>Drafts</string><key>MailboxUidType</key><string>103</string></dict>' \
'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Archive</string><key>MailboxUidPersistentIdentifier</key><string>Archive</string><key>MailboxUidType</key><string>109</string></dict>' \
'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Trash</string><key>MailboxUidPersistentIdentifier</key><string>Trash</string><key>MailboxUidType</key><string>101</string></dict>' \
'<dict><key>IsPrefferedSelection</key><string>1</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Flagged</string><key>MailboxUidPersistentIdentifier</key><string>Flags</string><key>MailboxUidType</key><string>108</string></dict>' \
'<dict><key>IsPrefferedSelection</key><string>0</string><key>MailboxUidIsContainer</key><string>1</string><key>MailboxUidName</key><string>Junk</string><key>MailboxUidPersistentIdentifier</key><string>Junk</string><key>MailboxUidType</key><string>105</string></dict>'

# Expand conversations for all mailboxes except inbox
defaults write 'com.apple.mail' InboxViewerAttributes -dict-add DisplayInThreadedMode -string YES
defaults write 'com.apple.mail' ArchiveViewerAttributes -dict-add DisplayInThreadedMode -string NO
defaults write 'com.apple.mail' DraftsViewerAttributes -dict-add DisplayInThreadedMode -string NO
defaults write 'com.apple.mail' SentMessagesViewerAttributes -dict-add DisplayInThreadedMode -string NO
defaults write 'com.apple.mail' TrashViewerAttributes -dict-add DisplayInThreadedMode -string NO

# Show the mailbox list if its hidden
if defaults read 'com.apple.mail' "NSSplitView Subview Frames Main Window" | sed -n '2p' | grep --silent "YES, NO"
then
	osascript -e 'tell application "Mail" to tell first message viewer to set mailbox list visible to true' 2>/dev/null
fi

# try sending later automatically if server isn't available
defaults write 'com.apple.mail' SuppressDeliveryFailure -bool true
# automatically add invitation to calendar
defaults write 'com.apple.mail' CalendarInviteRuleEnabled -bool true
# show contact photo
defaults write 'com.apple.mail' EnableContactPhotos -bool true

# make orange the default flag
defaults write 'com.apple.mail' FlagColorToDisplay -int 1
