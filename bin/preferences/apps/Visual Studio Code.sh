#!/bin/bash

CODE=/usr/local/bin/code

SETTINGS_SYNC_EXTENSION_ID="Shan.code-settings-sync"

if ! "${CODE}" --list-extensions | grep "${SETTINGS_SYNC_EXTENSION_ID}" 1>/dev/null; then
	"${CODE}" --install-extension "${SETTINGS_SYNC_EXTENSION_ID}"
fi

defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
