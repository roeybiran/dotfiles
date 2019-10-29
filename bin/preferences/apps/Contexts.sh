#!/bin/bash

# Keyboard Layout [ABC]
defaults write 'com.contextsformac.Contexts' CTPreferenceInputSourceIdToUse -string "com.apple.keylayout.ABC"

# Show Sidebar on: (·) No display
defaults write 'com.contextsformac.Contexts' CTPreferenceSidebarDisplayMode -string CTDisplayModeNone

# [ ] Auto adjust windows widths so they are not overlapped by Siderbar
defaults write 'com.contextsformac.Contexts' CTPreferenceWorkspaceConstrainWindowFrames -bool false

# [ ] Moving the cursor over Panel changes the selected item
defaults write 'com.contextsformac.Contexts' CTPreferencePanelChangeSelectionOnScrollEnabled -bool false

# [ ] Scrolling when Panel is visible changes the selected item
defaults write 'com.contextsformac.Contexts' CTPreferencePanelUpdatesSelectionOnMouseMove -bool false

# Disable Search
defaults write 'com.contextsformac.Contexts' CTKeyboardEventCommandModeActive -bool false
defaults write 'com.contextsformac.Contexts' CTPreferenceSearchShortcutModal -data "62706c6973743030d40102030405060809582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0a10755246e756c6c5f100f4e534b657965644172636869766572d10a0b54726f6f74800008111a232d3237393f5154590000000000000101000000000000000c0000000000000000000000000000005b"

# Fast Search with: [ ] Fn-<characters>
defaults write 'com.contextsformac.Contexts' CTPreferenceSearchShortcutFunctionKeyEnabled -bool false

# Command-Tab
    # Activate switcher with ⌘TAB
    # Move up list with ⇧⌘TAB
    # Show windows from all spaces
    # show windows of all apps
    # show minimized windows at the bottom
    # show hidden windows at the bottom
defaults write 'com.contextsformac.Contexts' CTPreferenceSwitchers -data '62706c6973743030d4010203040506393a582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0ac07080e1e1f252c2f3031323655246e756c6cd2090a0b0d5a4e532e6f626a656374735624636c617373a10c8002800bd80a0f101112131415161718191a171c1d5f10176d696e696d697a656457696e646f7773446973706c617957656e61626c65645f101a77696e646f776c65737350726f636573736573446973706c61795c6e65787453686f72746375745f101468696464656e57696e646f7773446973706c61795c7370616365734f7074696f6e5f101070726576696f757353686f7274637574800a800980038008800480098007800609d3200a21222324574b6579436f64655d4d6f646966696572466c616773103080051200100000d2262728295a24636c6173736e616d655824636c61737365735a435453686f7274637574a3282a2b5b4d415353686f7274637574584e534f626a656374d3200a2122232e800512001200005f101143545370616365734f7074696f6e416c6c5f101343544974656d446973706c61794e6f726d616c5f101c43544974656d446973706c6179496e536570617261746547726f7570d2262733345a43545377697463686572a2352b5a43545377697463686572d226273738574e534172726179a2372b5f100f4e534b657965644172636869766572d13b3c54726f6f74800100080011001a0023002d003200370044004a004f005a006100630065006700780092009a00b700c400db00e800fb00fd00ff01010103010501070109010b010c0113011b0129012b012d013201370142014b0156015a0166016f01760178017d019101a701c601cb01d601d901e401e901f101f402060209020e0000000000000201000000000000003d00000000000000000000000000000210'
# [✓] Typing characters starts Fast Search when Panel is visible
defaults write 'com.contextsformac.Contexts' CTPreferenceRecentItemsSwitcherSearchEnabled -bool true
# don't show search hints, numbers
defaults write 'com.contextsformac.Contexts' CTPreferencePanelRecentItemsSwitcherKeyType -string 'CTItemKeyTypeNone'

# text size: largest
defaults write 'com.contextsformac.Contexts'  CTPreferenceAppearanceContentSizeCategory -int 4

# panel width: narrowest
defaults write 'com.contextsformac.Contexts' CTPreferencePanelWidth -int 0

