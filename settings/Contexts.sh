#!/bin/sh

# APPEARANCE
# match system
defaults write com.contextsformac.Contexts CTAppearanceTheme -string CTAppearanceNamedAuto
# text size: largest
defaults write com.contextsformac.Contexts CTPreferenceAppearanceContentSizeCategory -int 4

# GENERAL
# Keyboard Layout [ABC]
defaults write com.contextsformac.Contexts CTPreferenceInputSourceIdToUse -string com.apple.keylayout.ABC

# SIDEBAR
# Show Sidebar on: (·) No display
defaults write com.contextsformac.Contexts CTPreferenceSidebarDisplayMode -string CTDisplayModeNone
# [ ] Auto adjust windows widths so they are not overlapped by Siderbar
defaults write com.contextsformac.Contexts CTPreferenceWorkspaceConstrainWindowFrames -bool false

# PANEL
# panel width: narrowest
defaults write com.contextsformac.Contexts CTPreferencePanelWidth -int 0
# [ ] Moving the cursor over Panel changes the selected item
defaults write com.contextsformac.Contexts CTPreferencePanelChangeSelectionOnScrollEnabled -bool false
# [ ] Scrolling when Panel is visible changes the selected item
defaults write com.contextsformac.Contexts CTPreferencePanelUpdatesSelectionOnMouseMove -bool false

# SEARCH
# Search with: NONE
defaults write com.contextsformac.Contexts CTKeyboardEventCommandModeActive -bool false
defaults write com.contextsformac.Contexts CTPreferenceSearchShortcutModal -data 62706c6973743030d40102030405060809582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0a10755246e756c6c5f100f4e534b657965644172636869766572d10a0b54726f6f74800008111a232d3237393f5154590000000000000101000000000000000c0000000000000000000000000000005b
# Fast Search with: NONE
defaults write com.contextsformac.Contexts CTPreferenceSearchShortcutFunctionKeyEnabled -bool false
# don't allow mismathces
defaults write com.contextsformac.Contexts CTPreferenceSearchNumberOfMismatchesAllowed -int 0

# Command-Tab
# Activate switcher with ⌘TAB
# Move up list with ⇧⌘TAB
# Show windows from all spaces
# show windows of all apps
# show minimized windows at the bottom
# show hidden windows at the bottom
# Command-Backtick
# Activate switcher with ⌘`
# Move up list with ⇧⌘`
# Show windows from all spaces
# show windows of active app
defaults write com.contextsformac.Contexts CTPreferenceSwitchers -data 62706C6973743030D4010203040506070A582476657273696F6E592461726368697665725424746F7058246F626A6563747312000186A05F100F4E534B657965644172636869766572D1080954726F6F748001AF10170B0C1525262C33363738393D484A4D4E57585B5D67696C55246E756C6CD20D0E0F145A4E532E6F626A656374735624636C617373A4101112138002800B800F80138016D80E161718191A1B1C1D1E1F20211E23245F10176D696E696D697A656457696E646F7773446973706C617957656E61626C65645F101A77696E646F776C65737350726F636573736573446973706C61795C6E65787453686F72746375745F101468696464656E57696E646F7773446973706C61795C7370616365734F7074696F6E5F101070726576696F757353686F7274637574800A800980038008800480098007800609D3270E28292A2B574B6579436F64655D4D6F646966696572466C616773103080051200100000D22D2E2F305A24636C6173736E616D655824636C61737365735A435453686F7274637574A32F31325B4D415353686F7274637574584E534F626A656374D3270E28342A2B103280055F101143545370616365734F7074696F6E416C6C5F101343544974656D446973706C61794E6F726D616C5F101C43544974656D446973706C6179496E536570617261746547726F7570D22D2E3A3B5A43545377697463686572A23C325A43545377697463686572D93E0E171819161A1B1C3F1D1F20431E1E23475F10196E6F6E61637469766550726F636573736573446973706C6179800E800A80038008800C800980098007800DD3270E28342A2B8005D3270E28342A4C800512001200005F101343544974656D446973706C617948696464656ED80E161718191A1B1C1D1E5120531E2356800A800980108008801180098007801208D3270E28292A5A80051200080000D3270E28342A5A8005D93E0E171819161A1B1C3F1D51206220202366800E800A8010800880148008800880078015D3270E28342A5A8005D3270E28342A6B800512000A0000D22D2E6D6E574E534172726179A26D3200080011001A00240029003200370049004C00510053006D007300780083008A008F0091009300950097009900AA00C400CC00E900F6010D011A012D012F01310133013501370139013B013D013E0145014D015B015D015F016401690174017D0188018C019801A101A801AA01AC01C001D601F501FA02050208021302260242024402460248024A024C024E025002520254025B025D02640266026B02810292029402960298029A029C029E02A002A202A302AA02AC02B102B802BA02CD02CF02D102D302D502D702D902DB02DD02DF02E602E802EF02F102F602FB03030000000000000201000000000000006F00000000000000000000000000000306

# [✓] Typing characters starts Fast Search when Panel is visible
defaults write com.contextsformac.Contexts CTPreferenceRecentItemsSwitcherSearchEnabled -bool true
# don't show search hints, numbers
defaults write com.contextsformac.Contexts CTPreferencePanelRecentItemsSwitcherKeyType -string CTItemKeyTypeNone
