#!/bin/bash

plist="${HOME}/Library/Preferences/com.stclairsoft.DefaultFolderX5.plist"

# default to the document's folder in save dialogs
defaults write "${plist}" defaultToDocumentFolder -bool true
# use a minimal bezel
defaults write "${plist}" toolbarStyle -int 4
# hide menu bar icon and surpress subsequent warning
defaults write "${plist}" showStatusItem -bool false
defaults write "${plist}" suppressQuitWarnings -bool true
# List folders before files
defaults write "${plist}" menusSortFoldersFirst -bool true
# Disable Finder-click
defaults write "${plist}" finderClick -bool false
# Don't show extra info below Open dialogs
defaults write "${plist}" toolbarShowAttributesOnOpen -bool false
# Don't show extra info below Save dialogs
defaults write "${plist}" toolbarShowAttributesOnSave -bool false
# don't enable favorites shortcuts
defaults write "${plist}" hotkeysOutsideFileDialogs -bool false
# Open folders in Finder's frontmost window
defaults write "${plist}" openInFrontFinderWindow -bool true
# Automatically update
defaults write "${plist}" SUEnableAutomaticChecks -bool true
defaults write "${plist}" SUAutomaticallyUpdate -bool true
# shortcuts
plb "${plist}" ":keyBindings" "array"
plb "${plist}" ":keyBindings:0" "dict"
plb "${plist}" ":keyBindings:0:key" "dict"
plb "${plist}" ":keyBindings:0:name" "string" "Copy Folder Path to Clipboard"
plb "${plist}" ":keyBindings:0:context" "integer" 1
plb "${plist}" ":keyBindings:0:action" "string" "copyPathOfFolder:"
plb "${plist}" ":keyBindings:1" "dict"
plb "${plist}" ":keyBindings:1:key" "dict"
plb "${plist}" ":keyBindings:1:name" "string" "Copy Folder Name to Clipboard"
plb "${plist}" ":keyBindings:1:context" "integer" 1
plb "${plist}" ":keyBindings:1:action" "string" "copyNameOfFolder:"
plb "${plist}" ":keyBindings:2" "dict"
plb "${plist}" ":keyBindings:2:key" "dict"
plb "${plist}" ":keyBindings:2:name" "string" "Duplicate"
plb "${plist}" ":keyBindings:2:context" "integer" 1
plb "${plist}" ":keyBindings:2:action" "string" "duplicateSelection:"
plb "${plist}" ":keyBindings:3" "dict"
plb "${plist}" ":keyBindings:3:key" "dict"
plb "${plist}" ":keyBindings:3:name" "string" "Make Alias"
plb "${plist}" ":keyBindings:3:context" "integer" 1
plb "${plist}" ":keyBindings:3:action" "string" "aliasSelection:"
plb "${plist}" ":keyBindings:4" "dict"
plb "${plist}" ":keyBindings:4:key" "dict"
plb "${plist}" ":keyBindings:4:name" "string" "Copy Selected Path to Clipboard"
plb "${plist}" ":keyBindings:4:context" "integer" 1
plb "${plist}" ":keyBindings:4:action" "string" "copyPathOfSelection:"
plb "${plist}" ":keyBindings:5" "dict"
plb "${plist}" ":keyBindings:5:key" "dict"
plb "${plist}" ":keyBindings:5:name" "string" "Copy Selected Name to Clipboard"
plb "${plist}" ":keyBindings:5:context" "integer" 1
plb "${plist}" ":keyBindings:5:action" "string" "copyNameOfSelection:"
plb "${plist}" ":keyBindings:6" "dict"
plb "${plist}" ":keyBindings:6:key" "dict"
plb "${plist}" ":keyBindings:6:name" "string" "Compress"
plb "${plist}" ":keyBindings:6:context" "integer" 1
plb "${plist}" ":keyBindings:6:action" "string" "zipSelection:"
plb "${plist}" ":keyBindings:7" "dict"
plb "${plist}" ":keyBindings:7:key" "dict"
plb "${plist}" ":keyBindings:7:name" "string" "Uncompress"
plb "${plist}" ":keyBindings:7:context" "integer" 1
plb "${plist}" ":keyBindings:7:action" "string" "unzipSelection:"
plb "${plist}" ":keyBindings:8" "dict"
plb "${plist}" ":keyBindings:8:key" "dict"
plb "${plist}" ":keyBindings:8:name" "string" "Quicklook"
plb "${plist}" ":keyBindings:8:context" "integer" 1
plb "${plist}" ":keyBindings:8:action" "string" "quicklookSelection:"
plb "${plist}" ":keyBindings:9" "dict"
plb "${plist}" ":keyBindings:9:key" "dict"
plb "${plist}" ":keyBindings:9:name" "string" "Preferences"
plb "${plist}" ":keyBindings:9:context" "integer" 1
plb "${plist}" ":keyBindings:9:action" "string" "showPreferences:"
plb "${plist}" ":keyBindings:10" "dict"
plb "${plist}" ":keyBindings:10:key" "dict"
plb "${plist}" ":keyBindings:10:name" "string" "Add to Favorites"
plb "${plist}" ":keyBindings:10:context" "integer" 1
plb "${plist}" ":keyBindings:10:action" "string" "addToFavorites:"
plb "${plist}" ":keyBindings:11" "dict"
plb "${plist}" ":keyBindings:11:key" "dict"
plb "${plist}" ":keyBindings:11:name" "string" "Remove From Favorites"
plb "${plist}" ":keyBindings:11:context" "integer" 1
plb "${plist}" ":keyBindings:11:action" "string" "removeFromFavorites:"
plb "${plist}" ":keyBindings:12" "dict"
plb "${plist}" ":keyBindings:12:key" "dict"
plb "${plist}" ":keyBindings:12:name" "string" "Go to Application Folder"
plb "${plist}" ":keyBindings:12:context" "integer" 1
plb "${plist}" ":keyBindings:12:action" "string" "switchToApplicationFolder:"
plb "${plist}" ":keyBindings:13" "dict"
plb "${plist}" ":keyBindings:13:key" "dict"
plb "${plist}" ":keyBindings:13:name" "string" "Set Default Folder for Application"
plb "${plist}" ":keyBindings:13:context" "integer" 1
plb "${plist}" ":keyBindings:13:action" "string" "setDefaultFolderForApp:"
plb "${plist}" ":keyBindings:14" "dict"
plb "${plist}" ":keyBindings:14:key" "dict"
plb "${plist}" ":keyBindings:14:name" "string" "Set Default Folder for Application & File Type"
plb "${plist}" ":keyBindings:14:context" "integer" 1
plb "${plist}" ":keyBindings:14:action" "string" "setDefaultFolderForAppAndType:"
plb "${plist}" ":keyBindings:15" "dict"
plb "${plist}" ":keyBindings:15:key" "dict"
plb "${plist}" ":keyBindings:15:name" "string" "Set Default Folder for File Type"
plb "${plist}" ":keyBindings:15:context" "integer" 1
plb "${plist}" ":keyBindings:15:action" "string" "setDefaultFolderForType:"
plb "${plist}" ":keyBindings:16" "dict"
plb "${plist}" ":keyBindings:16:key" "dict"
plb "${plist}" ":keyBindings:16:name" "string" "Show Utility Menu"
plb "${plist}" ":keyBindings:16:context" "integer" 1
plb "${plist}" ":keyBindings:16:action" "string" "showUtilityMenu:"
plb "${plist}" ":keyBindings:17" "dict"
plb "${plist}" ":keyBindings:17:key" "dict"
plb "${plist}" ":keyBindings:17:name" "string" "Show Computer Menu"
plb "${plist}" ":keyBindings:17:context" "integer" 1
plb "${plist}" ":keyBindings:17:action" "string" "showComputerMenu:"
plb "${plist}" ":keyBindings:18" "dict"
plb "${plist}" ":keyBindings:18:key" "dict"
plb "${plist}" ":keyBindings:18:name" "string" "Show Favorites Menu"
plb "${plist}" ":keyBindings:18:context" "integer" 1
plb "${plist}" ":keyBindings:18:action" "string" "showFavoritesMenu:"
plb "${plist}" ":keyBindings:19" "dict"
plb "${plist}" ":keyBindings:19:key" "dict"
plb "${plist}" ":keyBindings:19:name" "string" "Show Recent Folder Menu"
plb "${plist}" ":keyBindings:19:context" "integer" 1
plb "${plist}" ":keyBindings:19:action" "string" "showRecentFolderMenu:"
plb "${plist}" ":keyBindings:20" "dict"
plb "${plist}" ":keyBindings:20:key" "dict"
plb "${plist}" ":keyBindings:20:name" "string" "Show Recent File Menu"
plb "${plist}" ":keyBindings:20:context" "integer" 1
plb "${plist}" ":keyBindings:20:action" "string" "showRecentFileMenu:"
plb "${plist}" ":keyBindings:21" "dict"
plb "${plist}" ":keyBindings:21:key" "dict"
plb "${plist}" ":keyBindings:21:name" "string" "Show Finder Window Menu"
plb "${plist}" ":keyBindings:21:context" "integer" 1
plb "${plist}" ":keyBindings:21:action" "string" "showFinderWindowMenu:"
plb "${plist}" ":keyBindings:22" "dict"
plb "${plist}" ":keyBindings:22:key" "dict"
plb "${plist}" ":keyBindings:22:name" "string" "Show / Hide Toolbar"
plb "${plist}" ":keyBindings:22:context" "integer" 1
plb "${plist}" ":keyBindings:22:action" "string" "toggleToolbar:"
plb "${plist}" ":keyBindings:23" "dict"
plb "${plist}" ":keyBindings:23:key" "dict"
plb "${plist}" ":keyBindings:23:name" "string" "Enter Tags"
plb "${plist}" ":keyBindings:23:context" "integer" 1
plb "${plist}" ":keyBindings:23:action" "string" "selectTagField:"
plb "${plist}" ":keyBindings:24" "dict"
plb "${plist}" ":keyBindings:24:key" "dict"
plb "${plist}" ":keyBindings:24:name" "string" "Enter Comments"
plb "${plist}" ":keyBindings:24:context" "integer" 1
plb "${plist}" ":keyBindings:24:action" "string" "selectCommentField:"
plb "${plist}" ":keyBindings:25" "dict"
plb "${plist}" ":keyBindings:25:key" "dict"
plb "${plist}" ":keyBindings:25:name" "string" "Add to Favorites"
plb "${plist}" ":keyBindings:25:context" "integer" 2
plb "${plist}" ":keyBindings:25:action" "string" "addToFavoritesInFinder:"
plb "${plist}" ":keyBindings:26" "dict"
plb "${plist}" ":keyBindings:26:key" "dict"
plb "${plist}" ":keyBindings:26:name" "string" "Remove From Favorites"
plb "${plist}" ":keyBindings:26:context" "integer" 2
plb "${plist}" ":keyBindings:26:action" "string" "removeFromFavoritesInFinder:"
plb "${plist}" ":keyBindings:27" "dict"
plb "${plist}" ":keyBindings:27:key" "dict"
plb "${plist}" ":keyBindings:27:name" "string" "Show / Hide Finder Drawer"
plb "${plist}" ":keyBindings:27:context" "integer" 2
plb "${plist}" ":keyBindings:27:action" "string" "toggleFinderBezel:"
plb "${plist}" ":keyBindings:28" "dict"
plb "${plist}" ":keyBindings:28:key" "dict"
plb "${plist}" ":keyBindings:28:name" "string" "Switch to Previous Folder Set"
plb "${plist}" ":keyBindings:28:context" "integer" 5
plb "${plist}" ":keyBindings:28:action" "string" "switchToPreviousFolderSet:"
plb "${plist}" ":keyBindings:29" "dict"
plb "${plist}" ":keyBindings:29:key" "dict"
plb "${plist}" ":keyBindings:29:name" "string" "Switch to Next Folder Set"
plb "${plist}" ":keyBindings:29:context" "integer" 5
plb "${plist}" ":keyBindings:29:action" "string" "switchToNextFolderSet:"
plb "${plist}" ":keyBindings:30" "dict"
plb "${plist}" ":keyBindings:30:key" "dict"
plb "${plist}" ":keyBindings:30:name" "string" "Show Menu"
plb "${plist}" ":keyBindings:30:context" "integer" 4
plb "${plist}" ":keyBindings:30:action" "string" "showMenuSystemWide:"
plb "${plist}" ":keyBindings:31" "dict"
plb "${plist}" ":keyBindings:31:key" "dict"
plb "${plist}" ":keyBindings:31:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:31:key:characters" "string"
plb "${plist}" ":keyBindings:31:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:31:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:31:name" "string" "File Dialog Menu Commands"
plb "${plist}" ":keyBindings:31:context" "integer" 1
plb "${plist}" ":keyBindings:31:action" "string" "groupName:"
plb "${plist}" ":keyBindings:32" "dict"
plb "${plist}" ":keyBindings:32:key" "dict"
plb "${plist}" ":keyBindings:32:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:32:key:characters" "string"
plb "${plist}" ":keyBindings:32:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:32:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:32:name" "string" "File Dialog Menu Commands"
plb "${plist}" ":keyBindings:32:context" "integer" 1
plb "${plist}" ":keyBindings:32:action" "string" "groupName:"
plb "${plist}" ":keyBindings:33" "dict"
plb "${plist}" ":keyBindings:33:key" "dict"
plb "${plist}" ":keyBindings:33:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:33:key:characters" "string"
plb "${plist}" ":keyBindings:33:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:33:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:33:name" "string" "File Dialog Menu Commands"
plb "${plist}" ":keyBindings:33:context" "integer" 1
plb "${plist}" ":keyBindings:33:action" "string" "groupName:"
plb "${plist}" ":keyBindings:34" "dict"
plb "${plist}" ":keyBindings:34:key" "dict"
plb "${plist}" ":keyBindings:34:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:34:key:characters" "string"
plb "${plist}" ":keyBindings:34:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:34:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:34:name" "string" "File Dialog Menu Commands"
plb "${plist}" ":keyBindings:34:context" "integer" 1
plb "${plist}" ":keyBindings:34:action" "string" "groupName:"
plb "${plist}" ":keyBindings:35" "dict"
plb "${plist}" ":keyBindings:35:key" "dict"
plb "${plist}" ":keyBindings:35:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:35:key:characters" "string"
plb "${plist}" ":keyBindings:35:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:35:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:35:name" "string" "File Dialog Menu Commands"
plb "${plist}" ":keyBindings:35:context" "integer" 1
plb "${plist}" ":keyBindings:35:action" "string" "groupName:"
plb "${plist}" ":keyBindings:36" "dict"
plb "${plist}" ":keyBindings:36:key" "dict"
plb "${plist}" ":keyBindings:36:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:36:key:characters" "string"
plb "${plist}" ":keyBindings:36:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:36:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:36:name" "string" "Open in Finder"
plb "${plist}" ":keyBindings:36:context" "integer" 1
plb "${plist}" ":keyBindings:36:action" "string" "finderOpenFolder:"
plb "${plist}" ":keyBindings:37" "dict"
plb "${plist}" ":keyBindings:37:key" "dict"
plb "${plist}" ":keyBindings:37:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:37:key:characters" "string"
plb "${plist}" ":keyBindings:37:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:37:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:37:name" "string" "New Folder"
plb "${plist}" ":keyBindings:37:context" "integer" 1
plb "${plist}" ":keyBindings:37:action" "string" "createNewFolder:"
plb "${plist}" ":keyBindings:38" "dict"
plb "${plist}" ":keyBindings:38:key" "dict"
plb "${plist}" ":keyBindings:38:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:38:key:characters" "string"
plb "${plist}" ":keyBindings:38:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:38:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:38:name" "string" "Rename"
plb "${plist}" ":keyBindings:38:context" "integer" 1
plb "${plist}" ":keyBindings:38:action" "string" "renameSelection:"
plb "${plist}" ":keyBindings:39" "dict"
plb "${plist}" ":keyBindings:39:key" "dict"
plb "${plist}" ":keyBindings:39:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:39:key:characters" "string"
plb "${plist}" ":keyBindings:39:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:39:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:39:name" "string" "Copy"
plb "${plist}" ":keyBindings:39:context" "integer" 1
plb "${plist}" ":keyBindings:39:action" "string" "copySelection:"
plb "${plist}" ":keyBindings:40" "dict"
plb "${plist}" ":keyBindings:40:key" "dict"
plb "${plist}" ":keyBindings:40:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:40:key:characters" "string"
plb "${plist}" ":keyBindings:40:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:40:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:40:name" "string" "Move"
plb "${plist}" ":keyBindings:40:context" "integer" 1
plb "${plist}" ":keyBindings:40:action" "string" "moveSelection:"
plb "${plist}" ":keyBindings:41" "dict"
plb "${plist}" ":keyBindings:41:key" "dict"
plb "${plist}" ":keyBindings:41:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:41:key:characters" "string"
plb "${plist}" ":keyBindings:41:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:41:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:41:name" "string" "Get Info"
plb "${plist}" ":keyBindings:41:context" "integer" 1
plb "${plist}" ":keyBindings:41:action" "string" "getInfoOnSelection:"
plb "${plist}" ":keyBindings:42" "dict"
plb "${plist}" ":keyBindings:42:key" "dict"
plb "${plist}" ":keyBindings:42:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:42:key:characters" "string"
plb "${plist}" ":keyBindings:42:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:42:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:42:name" "string" "Show in Finder"
plb "${plist}" ":keyBindings:42:context" "integer" 1
plb "${plist}" ":keyBindings:42:action" "string" "revealSelection:"
plb "${plist}" ":keyBindings:43" "dict"
plb "${plist}" ":keyBindings:43:key" "dict"
plb "${plist}" ":keyBindings:43:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:43:key:characters" "string"
plb "${plist}" ":keyBindings:43:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:43:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:43:name" "string" "Move to Trash"
plb "${plist}" ":keyBindings:43:context" "integer" 1
plb "${plist}" ":keyBindings:43:action" "string" "trashSelection:"
plb "${plist}" ":keyBindings:44" "dict"
plb "${plist}" ":keyBindings:44:key" "dict"
plb "${plist}" ":keyBindings:44:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:44:key:characters" "string"
plb "${plist}" ":keyBindings:44:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:44:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:44:name" "string" "Desktop"
plb "${plist}" ":keyBindings:44:context" "integer" 1
plb "${plist}" ":keyBindings:44:action" "string" "goToDesktop:"
plb "${plist}" ":keyBindings:45" "dict"
plb "${plist}" ":keyBindings:45:key" "dict"
plb "${plist}" ":keyBindings:45:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:45:key:characters" "string"
plb "${plist}" ":keyBindings:45:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:45:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:45:name" "string" "Home"
plb "${plist}" ":keyBindings:45:context" "integer" 1
plb "${plist}" ":keyBindings:45:action" "string" "goToHome:"
plb "${plist}" ":keyBindings:46" "dict"
plb "${plist}" ":keyBindings:46:key" "dict"
plb "${plist}" ":keyBindings:46:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:46:key:characters" "string"
plb "${plist}" ":keyBindings:46:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:46:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:46:name" "string" "iCloud"
plb "${plist}" ":keyBindings:46:context" "integer" 1
plb "${plist}" ":keyBindings:46:action" "string" "goToICloud:"
plb "${plist}" ":keyBindings:47" "dict"
plb "${plist}" ":keyBindings:47:key" "dict"
plb "${plist}" ":keyBindings:47:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:47:key:characters" "string"
plb "${plist}" ":keyBindings:47:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:47:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:47:name" "string" "Go to Default Folder"
plb "${plist}" ":keyBindings:47:context" "integer" 1
plb "${plist}" ":keyBindings:47:action" "string" "switchToDefaultFolder:"
plb "${plist}" ":keyBindings:48" "dict"
plb "${plist}" ":keyBindings:48:key" "dict"
plb "${plist}" ":keyBindings:48:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:48:key:characters" "string"
plb "${plist}" ":keyBindings:48:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:48:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:48:name" "string" "Previous Recent Folder"
plb "${plist}" ":keyBindings:48:context" "integer" 1
plb "${plist}" ":keyBindings:48:action" "string" "goToPreviousRecentFolder:"
plb "${plist}" ":keyBindings:49" "dict"
plb "${plist}" ":keyBindings:49:key" "dict"
plb "${plist}" ":keyBindings:49:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:49:key:characters" "string"
plb "${plist}" ":keyBindings:49:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:49:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:49:name" "string" "Next Recent Folder"
plb "${plist}" ":keyBindings:49:context" "integer" 1
plb "${plist}" ":keyBindings:49:action" "string" "goToNextRecentFolder:"
plb "${plist}" ":keyBindings:50" "dict"
plb "${plist}" ":keyBindings:50:key" "dict"
plb "${plist}" ":keyBindings:50:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:50:key:characters" "string"
plb "${plist}" ":keyBindings:50:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:50:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:50:name" "string" "Previous Finder Window"
plb "${plist}" ":keyBindings:50:context" "integer" 1
plb "${plist}" ":keyBindings:50:action" "string" "goToPreviousFinderWindow:"
plb "${plist}" ":keyBindings:51" "dict"
plb "${plist}" ":keyBindings:51:key" "dict"
plb "${plist}" ":keyBindings:51:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:51:key:characters" "string"
plb "${plist}" ":keyBindings:51:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:51:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:51:name" "string" "Next Finder Window"
plb "${plist}" ":keyBindings:51:context" "integer" 1
plb "${plist}" ":keyBindings:51:action" "string" "goToNextFinderWindow:"
plb "${plist}" ":keyBindings:52" "dict"
plb "${plist}" ":keyBindings:52:key" "dict"
plb "${plist}" ":keyBindings:52:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:52:key:characters" "string"
plb "${plist}" ":keyBindings:52:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:52:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:52:name" "string" "Previous Recent Folder"
plb "${plist}" ":keyBindings:52:context" "integer" 2
plb "${plist}" ":keyBindings:52:action" "string" "goToPreviousRecentFolderInFinder:"
plb "${plist}" ":keyBindings:53" "dict"
plb "${plist}" ":keyBindings:53:key" "dict"
plb "${plist}" ":keyBindings:53:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:53:key:characters" "string"
plb "${plist}" ":keyBindings:53:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:53:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:53:name" "string" "Next Recent Folder"
plb "${plist}" ":keyBindings:53:context" "integer" 2
plb "${plist}" ":keyBindings:53:action" "string" "goToNextRecentFolderInFinder:"
plb "${plist}" ":keyBindings:54" "dict"
plb "${plist}" ":keyBindings:54:key" "dict"
plb "${plist}" ":keyBindings:54:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:54:key:characters" "string"
plb "${plist}" ":keyBindings:54:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:54:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:54:name" "string" "Previous Finder Window"
plb "${plist}" ":keyBindings:54:context" "integer" 2
plb "${plist}" ":keyBindings:54:action" "string" "goToPreviousFinderWindowInFinder:"
plb "${plist}" ":keyBindings:55" "dict"
plb "${plist}" ":keyBindings:55:key" "dict"
plb "${plist}" ":keyBindings:55:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:55:key:characters" "string"
plb "${plist}" ":keyBindings:55:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:55:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:55:name" "string" "Next Finder Window"
plb "${plist}" ":keyBindings:55:context" "integer" 2
plb "${plist}" ":keyBindings:55:action" "string" "goToNextFinderWindowInFinder:"
plb "${plist}" ":keyBindings:56" "dict"
plb "${plist}" ":keyBindings:56:key" "dict"
plb "${plist}" ":keyBindings:56:key:charactersIgnoringModifiers" "string"
plb "${plist}" ":keyBindings:56:key:characters" "string"
plb "${plist}" ":keyBindings:56:key:keyCode" "string" "-1"
plb "${plist}" ":keyBindings:56:key:modifierFlags" "integer" 0
plb "${plist}" ":keyBindings:56:name" "string" "Show Menu"
plb "${plist}" ":keyBindings:56:context" "integer" 2
plb "${plist}" ":keyBindings:56:action" "string" "showMenu:"
