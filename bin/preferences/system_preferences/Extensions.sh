#!/bin/bash

# enable finder extensions
defaults write pbs FinderActive -dict \
"APPEXTENSION-com.apple.finder.CreatePDFQuickAction" -bool true \
"APPEXTENSION-com.apple.finder.MarkupQuickAction" -bool true \
"APPEXTENSION-com.apple.finder.RotateQuickAction" -bool true \
"APPEXTENSION-com.apple.finder.TrimQuickAction" -bool true
