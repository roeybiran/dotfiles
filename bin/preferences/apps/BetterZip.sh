#!/bin/bash

plist="${HOME}/Library/Preferences/com.macitbetter.betterzip.plist"

# Extraction presets
plb "${plist}" "MIBExtractPresets" "array"
plb "${plist}" "MIBExtractPresets:0" "dict"
plb "${plist}" "MIBExtractPresets:0:closeWindow" "bool" "true"
plb "${plist}" "MIBExtractPresets:0:favorite" "bool" "false"
plb "${plist}" "MIBExtractPresets:0:reveal" "bool" "true"
plb "${plist}" "MIBExtractPresets:0:folder" "string" 1
plb "${plist}" "MIBExtractPresets:0:imageTint" "data" "040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a656374008584016301840466666666008322bf173f83926f0d3d0186"
plb "${plist}" "MIBExtractPresets:0:isService" "bool" "true"
plb "${plist}" "MIBExtractPresets:0:isToolbar" "bool" "true"
plb "${plist}" "MIBExtractPresets:0:moveArchiveTo" "string" 1
plb "${plist}" "MIBExtractPresets:0:name" "string" "Extract"
plb "${plist}" "MIBExtractPresets:0:openExtracted" "bool" "false"
plb "${plist}" "MIBExtractPresets:0:overwriteWithoutWarning" "bool" "false"
plb "${plist}" "MIBExtractPresets:0:resolutionFiles" "bool" "false"
plb "${plist}" "MIBExtractPresets:0:resolutionFolders" "bool" "false"
plb "${plist}" "MIBExtractPresets:0:shortName" "string" "Ex&Trash"
plb "${plist}" "MIBExtractPresets:0:tag" "integer" 9

# Save presets
plb "${plist}" "MIBSavePresets" "array"
plb "${plist}" "MIBSavePresets:0" "dict"
plb "${plist}" "MIBSavePresets:0:additionalParams" "string" ""
plb "${plist}" "MIBSavePresets:0:cleanPattern" "string" "*/.svn;*/CVS;*/.git"
plb "${plist}" "MIBSavePresets:0:closeWindow" "bool" "true"
plb "${plist}" "MIBSavePresets:0:compression" "integer" 2
plb "${plist}" "MIBSavePresets:0:encryption" "bool" "false"
plb "${plist}" "MIBSavePresets:0:favorite" "bool" "false"
plb "${plist}" "MIBSavePresets:0:folder" "string" 1
plb "${plist}" "MIBSavePresets:0:format" "bool" "false"
plb "${plist}" "MIBSavePresets:0:imageTint" "data" "040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a656374008584016301840466666666008322bf173f83926f0d3d0186"
plb "${plist}" "MIBSavePresets:0:isService" "bool" "true"
plb "${plist}" "MIBSavePresets:0:isToolbar" "bool" "true"
plb "${plist}" "MIBSavePresets:0:name" "string" "Zip & Clean"
plb "${plist}" "MIBSavePresets:0:shortName" "string" "Zip/Clean"
plb "${plist}" "MIBSavePresets:0:tag" "integer" 15

# [ ] Tell macOS to open archives in BetterZip
# [ ] Add a BetterZip button to Finder's toolbar
# [ ] Add services... to the macOS services menu
defaults write "${plist}" MIBFirstStart -int 100
defaults write "${plist}" MIBMoreOptions -bool false

# [✓] Quit after the last window...
defaults write "${plist}" MIBShouldTerminateAfterLastWindowClosed2 -bool true

# [✓] Opening an archive from the Finder immediately extracts it
defaults write "${plist}" MIBDirectExtractByDefault -bool true

# Update automatically
defaults write "${plist}" SUAutomaticallyUpdate -bool true
defaults write "${plist}" SUEnableAutomaticChecks -bool true
defaults write "${plist}" SUHasLaunchedBefore -bool true

# Quick Look
# Dont exapnd packages
defaults write "com.macitbetter.betterzip.quicklookgenerator-config" showPackageContents -bool false
# Dont show hidden files
defaults write "com.macitbetter.betterzip.quicklookgenerator-config" showHiddenFiles -bool false
