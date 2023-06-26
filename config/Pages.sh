#!/bin/sh

# shortcuts
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add Bigger '@$.'
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add Smaller '@$,'
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Zoom In" @=
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Zoom Out" @-
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add Strikethrough @^s
