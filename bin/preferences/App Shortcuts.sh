#!/bin/bash

# @ = command, $ = shift, ~ = alt and ^ = ctrl
# http://hints.macworld.com/article.php?story=20131123074223584

defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Bigger" '@$.'
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Smaller" '@$,'
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Zoom In" '@='
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Zoom Out" '@-'
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "New Slide" '@n'
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Next Slide" -string '@]'
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Previous Slide" -string '@['
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Group" '@g'
defaults write 'com.apple.iWork.Keynote' NSUserKeyEquivalents -dict-add "Ungroup"  '@$g'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "First Slide" '~\U2191'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Last Slide" '~\U2193'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Next Slide" '\U2193'
# defaults write com.apple.iWork.Keynote NSUserKeyEquivalents -dict-add "Previous Slide" '\U2191'

defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Bigger" '@$.'
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Smaller" '@$,'
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Zoom In" '@='
defaults write com.apple.iWork.Pages NSUserKeyEquivalents -dict-add "Zoom Out" '@-'

defaults write com.apple.iCal NSUserKeyEquivalents -dict-add "Go to Date..." -string '@$g'

defaults write "com.apple.Dictionary" NSUserKeyEquivalents -dict-add "Select Next Dictionary" '@~\U2192'
defaults write "com.apple.Dictionary" NSUserKeyEquivalents -dict-add "Select Previous Dictionary" '@~\U2190'

defaults write com.apple.Photos NSUserKeyEquivalents -dict-add "Show Edit Tools" '@e'

defaults write com.apple.ActivityMonitor NSUserKeyEquivalents -dict-add "Filter Processes" '@f'

defaults write "com.bohemiancoding.sketch3" NSUserKeyEquivalents -dict-add "Bigger" '@$.'
defaults write "com.bohemiancoding.sketch3" NSUserKeyEquivalents -dict-add "Smaller" '@$,'

defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "Hide Sidebar" '@~s'
defaults write com.apple.Safari NSUserKeyEquivalents -dict-add "Show Sidebar" '@~s'

# defaults write 'com.apple.mail' NSUserKeyEquivalents -dict-add "Find..." '@~f'
# defaults write 'com.apple.mail' NSUserKeyEquivalents -dict-add "Mailbox Search" '@f'

defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Hide Sidebar" '@1'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Thumbnails" '@2'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Table of Contents" '@3'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Highlights and Notes" '@4'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Contact Sheet" '@6'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Bookmarks" '@5'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Continuous Scroll" '^1'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Single Page" '^2'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Slideshow" '@~y'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Two Pages" '^3'
defaults write 'com.apple.Preview' 'NSUserKeyEquivalents' -dict-add "Go to Page..." '@$G'

defaults write com.apple.Console NSUserKeyEquivalents -dict-add "Find..." '@~f'
defaults write com.apple.Console NSUserKeyEquivalents -dict-add "Search" '@f'

defaults write "com.apple.FontBook" NSUserKeyEquivalents -dict-add "Font Search..." '@f'
defaults write "com.apple.FontBook" NSUserKeyEquivalents -dict-add "Find..." '~@f'

# defaults write "com.apple.finder" NSUserKeyEquivalents -dict-add "Open in New Tab" '@$\U2193'
# defaults write "com.apple.finder" NSUserKeyEquivalents -dict-add "Show Original" '@$\U2191'
# explicitly setting the DEFAULT shortcuts for the following 2 commands somehow prevents from ⇧⌘→/⇧⌘← to serve too as the respective hotkeys for next/previous tab
defaults write "com.apple.finder" NSUserKeyEquivalents -dict-add "Show Next Tab" '^\U21e5'
defaults write "com.apple.finder" NSUserKeyEquivalents -dict-add "Show Previous Tab" '^$\U21e5'

defaults write com.apple.AddressBook NSUserKeyEquivalents -dict-add "Edit Card" '@e'
defaults write com.apple.AddressBook NSUserKeyEquivalents -dict-add "Show Groups" '@~s'
defaults write com.apple.AddressBook NSUserKeyEquivalents -dict-add "Hide Groups" '@~s'

defaults write "com.apple.Notes" NSUserKeyEquivalents -dict-add Bigger '@$.'
defaults write "com.apple.Notes" NSUserKeyEquivalents -dict-add Smaller '@$,'
defaults write "com.apple.Notes" NSUserKeyEquivalents -dict-add 'Zoom In' '@='
defaults write "com.apple.Notes" NSUserKeyEquivalents -dict-add 'Zoom Out' '@-'
defaults write "com.apple.Notes" NSUserKeyEquivalents -dict-add 'Strikethrough' '@^s'

defaults write 'com.kapeli.dashdoc' NSUserKeyEquivalents -dict-add "Show Bookmarks..." '@~b'
