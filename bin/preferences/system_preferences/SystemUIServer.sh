#!/bin/bash

# [✓] Show battery status in menu bar
defaults write com.apple.systemuiserver menuExtras -array \
"/System/Library/CoreServices/Menu Extras/AirPort.menu" \
"/System/Library/CoreServices/Menu Extras/TextInput.menu" \
"/System/Library/CoreServices/Menu Extras/Volume.menu" \
"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
"/System/Library/CoreServices/Menu Extras/Battery.menu" \
"/System/Library/CoreServices/Menu Extras/Clock.menu"
# [✓] Show date and time in menu bar
defaults write "com.apple.menuextra.battery" "ShowPercent" -string "YES"
defaults write "com.apple.menuextra.clock" "DateFormat" -string "EEE d MMM  H:mm"
defaults write "com.apple.menuextra.clock" "FlashDateSeparators" -bool false
defaults write "com.apple.menuextra.clock" "IsAnalog" -bool false

# visibility of os icons
# [✓] Show Bluetooth in menu bar
defaults write "com.apple.systemuiserver" "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
# [✓] Show volume in menu bar
defaults write "com.apple.systemuiserver" "NSStatusItem Visible com.apple.menuextra.volume" -bool true
defaults write "com.apple.systemuiserver" "NSStatusItem Visible Siri" -bool false
defaults write "com.apple.Siri" "StatusMenuVisible" -bool false
defaults write "com.apple.airplay" "showInMenuBarIfPresent" -bool false
# order of visible icons
defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.textinput" -float "2.80859"
defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.clock" -float "89.75781"
defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.battery" -float "192"
# defaults write "com.flexibits.fantastical2.mac" "NSStatusItem Preferred Position Fantastical" -float "134.9766"
defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.airport" -float "240"
defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.bluetooth" -float "236.6562"
defaults write "com.apple.systemuiserver" "NSStatusItem Preferred Position com.apple.menuextra.volume" -float "258.7188"
defaults write "com.getdropbox.dropbox" "NSStatusItem Preferred Position Item-0" -float "315.8047"
defaults write "com.apple.Spotlight" "NSStatusItem Preferred Position Item-0" -float "391"
defaults write "com.toggl.toggldesktop.TogglDesktop" "NSStatusItem Preferred Position Item-0" -float "420"

# defaults -currentHost write com.apple.systemuiserver dontAutoLoad -array \
# "/System/Library/CoreServices/Menu Extras/Clock.menu" \
# "/System/Library/CoreServices/Menu Extras/Battery.menu"
