#!/bin/bash

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
#
defaults write "com.apple.print.PrinterProxy" "IK_CreateSingleDocument" -bool true
#
defaults write "com.apple.print.PrinterProxy" "IK_FileFormatTagColor" -int 6
#
defaults write "com.apple.print.PrinterProxy" "IK_scannerDisplayMode" -int 1
#
defaults write "com.apple.print.PrinterProxy" "IK_ScanBitDepth" -int 8
#
defaults write "com.apple.print.PrinterProxy" "IK_ScanResolution" -int 300
#
defaults write "com.apple.print.PrinterProxy" "IK_ScannerDocumentType" -int 1
#
defaults write "com.apple.print.PrinterProxy" "IK_Scanner_downloadURL" -string "${HOME}/Desktop"
#
defaults write "com.apple.print.PrinterProxy" "IK_Scanner_preferPostPostProcessApp" -bool false
#
defaults write "com.apple.print.PrinterProxy" "IK_Scanner_selectedPathType" -int 2
#
defaults write "com.apple.print.PrinterProxy" "IK_Scanner_selectedTag" -int 1001
# Automatically quit printer app once the print jobs complete
defaults write "com.apple.print.PrintingPrefs" "Quit When Finished" -bool true
