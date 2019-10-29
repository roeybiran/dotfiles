#!/bin/bash

plist="${HOME}/Library/Preferences/com.apple.finder.plist"

# Finder Preferences (⌘+,)
# Show these items on the desktop
# [ ] Hard Disks
defaults write "${plist}" "ShowHardDrivesOnDesktop" -bool false
# [ ] External disks
defaults write "${plist}" "ShowExternalHardDrivesOnDesktop" -bool false
# [ ] CDs, DVDs, and iPods
defaults write "${plist}" "ShowRemovableMediaOnDesktop" -bool false
# New Finder windows show: [Desktop]
defaults write "${plist}" "NewWindowTarget" -string PfDe
defaults write "${plist}" "NewWindowTargetPath" -string "file://${HOME}/Desktop/"
# [✓] Show all filename extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool true
# [ ] Show warning before changing an extension
defaults write "${plist}" "FXEnableExtensionChangeWarning" -bool false
# [ ] Show warning before removing from iCloud Drive
defaults write "${plist}" "FXEnableRemoveFromICloudDriveWarning" -bool false
# remove old trash items
defaults write "${plist}" "FXRemoveOldTrashItems" -bool true
# [✓] Keep folders on top: In windows when sorting by name
defaults write "${plist}" "_FXSortFoldersFirst" -bool true
# also on desktop
defaults write "${plist}" "_FXSortFoldersFirstOnDesktop" -bool true
# When performing a search: [Search the Current Folder]
defaults write "${plist}" "FXDefaultSearchScope" -string SCcf

# Menu Bar > View > Show Path Bar [✓]
defaults write "${plist}" "ShowPathbar" -bool true
# Menu Bar > View > Show Status Bar [✓]
defaults write "${plist}" "ShowStatusBar" -bool true
# Menu Bar > View > Show Preview
defaults write "${plist}" "ShowPreviewPane" -bool true

# Always ‘Show More‘ in the preview pane
defaults write "${plist}" "PreviewPaneInfoExpanded" -bool true
# Show the ~/Library folder
sudo xattr -d "com.apple.FinderInfo" ~/Library 2>/dev/null
sudo chflags nohidden ~/Library
# Show the /Volumes folder
sudo chflags nohidden /Volumes
# Remove Remote Disc
sudo defaults write "/Library/Preferences/com.apple.NetworkBrowser" "EnableODiskBrowsing" -bool false

# View Settings (Mojave+)
# Finder
	# global views
	# Columns
		# sort options
			# name: dnam
			# kind: kipl
			# date last opened: ludt
			# date added: pAdd
			# date modified: modd
			# date created: ascd
			# size: logs
			# tags: ftat
	# per-container views
		# computer
			# icons
			# list
			# gallery
		# desktop
			# icons
		# icloud
			# icons
			# list
			# gallery
		# search
			# icons
			# list
			# gallery
		# recents
			# icons
			# list
			# gallery
		# standard
			# icons
			# list
			# gallery
		# trash
			# icons
			# list
			# gallery

# create the initial dictionaries
for container in \
	":ComputerViewSettings" \
	":DesktopViewSettings" \
	":ICloudViewSettings" \
	":SearchRecentsViewSettings" \
	":SearchViewSettings" \
	":StandardViewSettings" \
	":TrashViewSettings" \
; do
	plb "${plist}" "${container}" "dict"
done


# icons view settings
for container in \
	":ComputerViewSettings" \
	":DesktopViewSettings" \
	":ICloudViewSettings" \
	":SearchRecentsViewSettings" \
	":SearchViewSettings" \
	":StandardViewSettings" \
	":TrashViewSettings" \
; do
plb "${plist}" "${container}:IconViewSettings" "dict"
plb "${plist}" "${container}:IconViewSettings:arrangeBy" "string" "kind"
plb "${plist}" "${container}:IconViewSettings:backgroundColorBlue" "real" "1.000000"
plb "${plist}" "${container}:IconViewSettings:backgroundColorGreen" "real" "1.000000"
plb "${plist}" "${container}:IconViewSettings:backgroundColorRed" "real" "1.000000"
plb "${plist}" "${container}:IconViewSettings:backgroundType" "integer" "0"
plb "${plist}" "${container}:IconViewSettings:gridOffsetX" "real" "0.000000"
plb "${plist}" "${container}:IconViewSettings:gridOffsetY" "real" "0.000000"
plb "${plist}" "${container}:IconViewSettings:gridSpacing" "real" "54.000000"
plb "${plist}" "${container}:IconViewSettings:iconSize" "real" "64.0000000"
plb "${plist}" "${container}:IconViewSettings:labelOnBottom" "bool" "true"
plb "${plist}" "${container}:IconViewSettings:showIconPreview" "bool" "true"
plb "${plist}" "${container}:IconViewSettings:showItemInfo" "bool" "false"
plb "${plist}" "${container}:IconViewSettings:textSize" "real" "12.0000000"
plb "${plist}" "${container}:IconViewSettings:viewOptionsVersion" "integer" "1"
done

# list view ('ExtendedListViewSettingsV2' + 'ListViewSettings') settings
# gallery view settings
# 'WindowState' settings
for container in \
	":ComputerViewSettings" \
	":ICloudViewSettings" \
	":SearchRecentsViewSettings" \
	":SearchViewSettings" \
	":StandardViewSettings" \
	":TrashViewSettings" \
; do

plb "${plist}" "${container}:ExtendedListViewSettingsV2" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:calculateAllSizes" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns" "array"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:0" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:0:ascending" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:0:identifier" "string" "name"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:0:visible" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:0:width" "integer" "292"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:1" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:1:ascending" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:1:identifier" "string" "ubiquity"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:1:visible" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:1:width" "integer" "35"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:2" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:2:ascending" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:2:identifier" "string" "dateModified"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:2:visible" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:2:width" "integer" "181"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:3" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:3:ascending" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:3:identifier" "string" "dateCreated"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:3:visible" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:3:width" "integer" "181"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:4" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:4:ascending" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:4:identifier" "string" "size"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:4:visible" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:4:width" "integer" "97"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:5" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:5:ascending" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:5:identifier" "string" "kind"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:5:visible" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:5:width" "integer" "115"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:6" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:6:ascending" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:6:identifier" "string" "label"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:6:visible" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:6:width" "integer" "100"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:7" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:7:ascending" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:7:identifier" "string" "version"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:7:visible" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:7:width" "integer" "75"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:8" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:8:ascending" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:8:identifier" "string" "comments"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:8:visible" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:8:width" "integer" "300"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:9" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:9:ascending" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:9:identifier" "string" "dateAdded"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:9:visible" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:9:width" "integer" "181"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:10" "dict"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:10:ascending" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:10:identifier" "string" "dateLastOpened"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:10:visible" "bool" "false"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:columns:10:width" "integer" "200"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:iconSize" "real" "16.000000"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:showIconPreview" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:sortColumn" "string" "kind"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:textSize" "real" "12.000000"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:useRelativeDates" "bool" "true"
plb "${plist}" "${container}:ExtendedListViewSettingsV2:viewOptionsVersion" "integer" "1"
plb "${plist}" "${container}:GalleryViewSettings" "dict"
plb "${plist}" "${container}:GalleryViewSettings:arrangeBy" "integer" "6"
plb "${plist}" "${container}:GalleryViewSettings:iconSize" "real" "48.000000"
plb "${plist}" "${container}:GalleryViewSettings:showIconPreview" "bool" "true"
plb "${plist}" "${container}:GalleryViewSettings:viewOptionsVersion" "integer" "1"
plb "${plist}" "${container}:ListViewSettings" "dict"
plb "${plist}" "${container}:ListViewSettings:calculateAllSizes" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:comments" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:comments:index" "integer" "7"
plb "${plist}" "${container}:ListViewSettings:columns:comments:width" "integer" "300"
plb "${plist}" "${container}:ListViewSettings:columns:comments:ascending" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:comments:visible" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:dateCreated" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:dateCreated:index" "integer" "2"
plb "${plist}" "${container}:ListViewSettings:columns:dateCreated:width" "integer" "181"
plb "${plist}" "${container}:ListViewSettings:columns:dateCreated:ascending" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:dateCreated:visible" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:dateLastOpened" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:dateLastOpened:index" "integer" "8"
plb "${plist}" "${container}:ListViewSettings:columns:dateLastOpened:width" "integer" "200"
plb "${plist}" "${container}:ListViewSettings:columns:dateLastOpened:ascending" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:dateLastOpened:visible" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:dateModified" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:dateModified:index" "integer" "1"
plb "${plist}" "${container}:ListViewSettings:columns:dateModified:width" "integer" "181"
plb "${plist}" "${container}:ListViewSettings:columns:dateModified:ascending" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:dateModified:visible" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:kind" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:kind:index" "integer" "4"
plb "${plist}" "${container}:ListViewSettings:columns:kind:width" "integer" "115"
plb "${plist}" "${container}:ListViewSettings:columns:kind:ascending" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:kind:visible" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:label" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:label:index" "integer" "5"
plb "${plist}" "${container}:ListViewSettings:columns:label:width" "integer" "100"
plb "${plist}" "${container}:ListViewSettings:columns:label:ascending" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:label:visible" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:name" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:name:index" "integer" "0"
plb "${plist}" "${container}:ListViewSettings:columns:name:width" "integer" "292"
plb "${plist}" "${container}:ListViewSettings:columns:name:ascending" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:name:visible" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:size" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:size:index" "integer" "3"
plb "${plist}" "${container}:ListViewSettings:columns:size:width" "integer" "97"
plb "${plist}" "${container}:ListViewSettings:columns:size:ascending" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:columns:size:visible" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:version" "dict"
plb "${plist}" "${container}:ListViewSettings:columns:version:index" "integer" "6"
plb "${plist}" "${container}:ListViewSettings:columns:version:width" "integer" "75"
plb "${plist}" "${container}:ListViewSettings:columns:version:ascending" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:columns:version:visible" "bool" "false"
plb "${plist}" "${container}:ListViewSettings:iconSize" "real" "16.000000"
plb "${plist}" "${container}:ListViewSettings:showIconPreview" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:sortColumn" "string" "kind"
plb "${plist}" "${container}:ListViewSettings:textSize" "real" "12.000000"
plb "${plist}" "${container}:ListViewSettings:useRelativeDates" "bool" "true"
plb "${plist}" "${container}:ListViewSettings:viewOptionsVersion" "integer" "1"
plb "${plist}" "${container}:WindowState" "dict"
plb "${plist}" "${container}:WindowState:ContainerShowSidebar" "bool" "true"
plb "${plist}" "${container}:WindowState:ShowPathbar" "bool" "true"
plb "${plist}" "${container}:WindowState:ShowSidebar" "bool" "true"
plb "${plist}" "${container}:WindowState:ShowStatusBar" "bool" "true"
plb "${plist}" "${container}:WindowState:ShowTabView" "bool" "true"
plb "${plist}" "${container}:WindowState:ShowToolbar" "bool" "true"
plb "${plist}" "${container}:WindowState:WindowBounds" "string"

done

# Search + Trash: arrange by date added in all views
for container in \
	":SearchViewSettings" \
	":TrashViewSettings" \
; do
	plb "${plist}" "${container}:GalleryViewSettings:arrangeBy" "integer" "4"
	plb "${plist}" "${container}:ExtendedListViewSettingsV2:sortColumn" "string" "dateAdded"
	plb "${plist}" "${container}:IconViewSettings:arrangeBy" "string" "dateAdded"
done

# All containers: Columns View + Gallery View
plb "${plist}" ":StandardViewOptions" "dict"
plb "${plist}" ":StandardViewOptions:ColumnViewOptions" "dict"
plb "${plist}" ":StandardViewOptions:ColumnViewOptions:ArrangeBy" "string" "kipl"
plb "${plist}" ":StandardViewOptions:ColumnViewOptions:SharedArrangeBy" "string" "kipl"
plb "${plist}" ":StandardViewOptions:GalleryViewOptions" "dict"
plb "${plist}" ":StandardViewOptions:GalleryViewOptions:ShowTitles" "bool" "true"
plb "${plist}" ":StandardViewOptions:GalleryViewOptions:ShowPreviewPane" "bool" "true"

# specific containers
# must be run after the main prefs have been set

# iCloud
# Show the ‘iCloud Status‘ column
plb "${plist}" ":ICloudViewSettings:ExtendedListViewSettingsV2:columns:1:visible" "bool" "true"

# Recents
# restore the Date Last Opened column
plb "${plist}" ":SearchRecentsViewSettings:ExtendedListViewSettingsV2:columns:10:visible" "bool" "true"
# change sort order back to Date Last Opened, in all views
plb "${plist}" ":SearchRecentsViewSettings:ExtendedListViewSettingsV2:sortColumn" "string" "dateLastOpened"
plb "${plist}" ":SearchRecentsViewSettings:ListViewSettings:sortColumn" "string" "dateLastOpened"
plb "${plist}" ":SearchRecentsViewSettings:GalleryViewSettings:arrangeBy" "integer" "3"
plb "${plist}" ":SearchRecentsViewSettings:IconViewSettings:arrangeBy" "string" "dateLastOpened"

# Sort by Kind in all Finder windows by default
defaults write "${plist}" "FXArrangeGroupViewBy" -string "Kind"

# Group by ‘None‘, so folder disclosure arrows are visible
defaults write "${plist}" "FXPreferredGroupBy" -string "None"

# Use list view in all Finder windows by default
defaults write "${plist}" "FXPreferredViewStyle" -string "Nlsv"

# Use List View in Search
defaults write "${plist}" "FXPreferredSearchViewStyle" -string "Nlsv"
defaults write "${plist}" "FXPreferredSearchViewStyleVersion" -string "%00%00%00%01"

# Recents
# Use List View
defaults write "${plist}" "SearchRecentsSavedViewStyle" -string "Nlsv"
defaults write "${plist}" "SearchRecentsSavedViewStyleVersion" -string "%00%00%00%01"
# Sort by Date Last Opened
defaults write "${plist}" "RecentsArrangeGroupViewBy" -string "Date Last Opened"

#************************************************#
# FinderKit - Open/Save Dialogs                  #
#************************************************#

# Show the Sidebar
defaults write "${plist}" "FK_AppCentricShowSidebar" -bool true

# Group by ‘None‘, so folder disclosure arrows are visible
defaults write "${plist}" "FK_ArrangeBy" -string None
defaults write "${plist}" "FK_RecentsArrangeBy" -string None
defaults write "${plist}" "FK_SearchArrangeBy" -string None

# Column View for file open dialogs
defaults write NSGlobalDomain NSNavPanelFileLastListModeForOpenModeKey -int 1
defaults write NSGlobalDomain NSNavPanelFileListModeForOpenMode2 -int 1
defaults write NSGlobalDomain NavPanelFileListModeForOpenMode -int 1

# Column View for file save dialogs
defaults write NSGlobalDomain NSNavPanelFileLastListModeForSaveModeKey -int 1
defaults write NSGlobalDomain NSNavPanelFileListModeForSaveMode2 -int 1
defaults write NSGlobalDomain NavPanelFileListModeForSaveMode -int 1

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# FK_StandardViewOptions2 (AKA Column View)
plb "${plist}" ":FK_StandardViewOptions2" "dict"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions" "dict"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:ArrangeBy" "string" "pAdd"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:ColumnShowFolderArrow" "bool" "true"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:ColumnShowIcons" "bool" "true"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:ColumnWidth" "integer" "205"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:FontSize" "integer" "10"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:PreviewDisclosureState" "bool" "true"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:SharedArrangeBy" "string" "pAdd"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:ShowIconThumbnails" "bool" "true"
plb "${plist}" ":FK_StandardViewOptions2:ColumnViewOptions:ShowPreview" "bool" "true"

# global views
	# columns
# per-container views
	# Default
		# icons
		# list
	# iCloud
		# icons
		# list
	# Recents
		# icons
		# list
	# Search
		# icons
		# list
# sorting options
	# columns
		# kind: kipl
		# date last opened: ludt
		# date added: pAdd
		# date modified: modd
		# date created: ascd
		# size: logs
		# tags: ftat
	# icons
		# Date Modified ('Date' in the gui)
		# Name
		# Tags

# FinderKit list view settings
for container in \
	":FK_DefaultListViewSettingsV2" \
	":FK_iCloudListViewSettingsV2" \
	":FK_RecentsListViewSettingsV2" \
	":FK_SearchListViewSettingsV2" \
; do
plb "${plist}" "${container}" "dict"
plb "${plist}" "${container}:columns" "array"
plb "${plist}" "${container}:columns:0" "dict"
plb "${plist}" "${container}:columns:0:ascending" "bool" "true"
plb "${plist}" "${container}:columns:0:identifier" "string" "name"
plb "${plist}" "${container}:columns:0:visible" "bool" "true"
plb "${plist}" "${container}:columns:0:width" "integer" "406"
plb "${plist}" "${container}:columns:1" "dict"
plb "${plist}" "${container}:columns:1:ascending" "bool" "false"
plb "${plist}" "${container}:columns:1:identifier" "string" "ubiquity"
plb "${plist}" "${container}:columns:1:visible" "bool" "false"
plb "${plist}" "${container}:columns:1:width" "integer" "35"
plb "${plist}" "${container}:columns:2" "dict"
plb "${plist}" "${container}:columns:2:ascending" "bool" "false"
plb "${plist}" "${container}:columns:2:identifier" "string" "dateModified"
plb "${plist}" "${container}:columns:2:visible" "bool" "true"
plb "${plist}" "${container}:columns:2:width" "integer" "181"
plb "${plist}" "${container}:columns:3" "dict"
plb "${plist}" "${container}:columns:3:ascending" "bool" "false"
plb "${plist}" "${container}:columns:3:identifier" "string" "dateCreated"
plb "${plist}" "${container}:columns:3:visible" "bool" "false"
plb "${plist}" "${container}:columns:3:width" "integer" "181"
plb "${plist}" "${container}:columns:4" "dict"
plb "${plist}" "${container}:columns:4:ascending" "bool" "false"
plb "${plist}" "${container}:columns:4:identifier" "string" "size"
plb "${plist}" "${container}:columns:4:visible" "bool" "true"
plb "${plist}" "${container}:columns:4:width" "integer" "97"
plb "${plist}" "${container}:columns:5" "dict"
plb "${plist}" "${container}:columns:5:ascending" "bool" "true"
plb "${plist}" "${container}:columns:5:identifier" "string" "kind"
plb "${plist}" "${container}:columns:5:visible" "bool" "true"
plb "${plist}" "${container}:columns:5:width" "integer" "115"
plb "${plist}" "${container}:columns:6" "dict"
plb "${plist}" "${container}:columns:6:ascending" "bool" "true"
plb "${plist}" "${container}:columns:6:identifier" "string" "label"
plb "${plist}" "${container}:columns:6:visible" "bool" "false"
plb "${plist}" "${container}:columns:6:width" "integer" "100"
plb "${plist}" "${container}:columns:7" "dict"
plb "${plist}" "${container}:columns:7:ascending" "bool" "true"
plb "${plist}" "${container}:columns:7:identifier" "string" "version"
plb "${plist}" "${container}:columns:7:visible" "bool" "false"
plb "${plist}" "${container}:columns:7:width" "integer" "75"
plb "${plist}" "${container}:columns:8" "dict"
plb "${plist}" "${container}:columns:8:ascending" "bool" "true"
plb "${plist}" "${container}:columns:8:identifier" "string" "comments"
plb "${plist}" "${container}:columns:8:visible" "bool" "false"
plb "${plist}" "${container}:columns:8:width" "integer" "300"
plb "${plist}" "${container}:columns:9" "dict"
plb "${plist}" "${container}:columns:9:ascending" "bool" "false"
plb "${plist}" "${container}:columns:9:identifier" "string" "dateLastOpened"
plb "${plist}" "${container}:columns:9:visible" "bool" "false"
plb "${plist}" "${container}:columns:9:width" "integer" "200"
plb "${plist}" "${container}:columns:10" "dict"
plb "${plist}" "${container}:columns:10:ascending" "bool" "false"
plb "${plist}" "${container}:columns:10:identifier" "string" "dateAdded"
plb "${plist}" "${container}:columns:10:visible" "bool" "false"
plb "${plist}" "${container}:columns:10:width" "integer" "181"
plb "${plist}" "${container}:calculateAllSizes" "bool" "true"
plb "${plist}" "${container}:iconSize" "real" "16.000000"
plb "${plist}" "${container}:showIconPreview" "bool" "true"
plb "${plist}" "${container}:sortColumn" "string" "dateModified"
plb "${plist}" "${container}:textSize" "real" "12.000000"
plb "${plist}" "${container}:useRelativeDates" "bool" "true"
plb "${plist}" "${container}:viewOptionsVersion" "integer" "1"

done

# FinderKit icon view settings
for container in \
	":FK_DefaultIconViewSettings" \
	":FK_SearchIconViewSettings" \
	":FK_RecentsIconViewSettings" \
	":FK_iCloudIconViewSettings" \
; do
	plb "${plist}" "${container}" "dict"
	plb "${plist}" "${container}:arrangeBy" "string" "dateModified"
	plb "${plist}" "${container}:backgroundColorBlue" "real" "1.000000"
	plb "${plist}" "${container}:backgroundColorGreen" "real" "1.000000"
	plb "${plist}" "${container}:backgroundColorRed" "real" "1.000000"
	plb "${plist}" "${container}:backgroundType" "integer" "0"
	plb "${plist}" "${container}:gridOffsetX" "real" "0.000000"
	plb "${plist}" "${container}:gridOffsetY" "real" "0.000000"
	plb "${plist}" "${container}:gridSpacing" "real" "54.000000"
	plb "${plist}" "${container}:iconSize" "real" "64.000000"
	plb "${plist}" "${container}:labelOnBottom" "bool" "true"
	plb "${plist}" "${container}:showIconPreview" "bool" "true"
	plb "${plist}" "${container}:showItemInfo" "bool" "false"
	plb "${plist}" "${container}:textSize" "real" "12.000000"
	plb "${plist}" "${container}:viewOptionsVersion" "integer" "1"
done

# SEEMS TO HAVE NO EFFECT?
# plist="${HOME}/Library/Preferences/com.apple.finder.plist"
# plb "${plist}" "StandardViewSettings:SettingsType" "string" "StandardViewSettings"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:calculateAllSizes" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns" "array"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:0" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:0:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:0:identifier" "string" "name"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:0:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:0:width" "integer" "300"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:1" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:1:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:1:identifier" "string" "dateModified"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:1:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:1:width" "integer" "181"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:2" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:2:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:2:identifier" "string" "dateCreated"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:2:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:2:width" "integer" "181"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:3" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:3:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:3:identifier" "string" "size"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:3:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:3:width" "integer" "97"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:4" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:4:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:4:identifier" "string" "kind"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:4:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:4:width" "integer" "115"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:5" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:5:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:5:identifier" "string" "label"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:5:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:5:width" "integer" "100"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:6" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:6:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:6:identifier" "string" "version"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:6:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:6:width" "integer" "75"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:7" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:7:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:7:identifier" "string" "comments"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:7:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:7:width" "integer" "300"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:8" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:8:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:8:identifier" "string" "dateLastOpened"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:8:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:columns:8:width" "integer" "200"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:iconSize" "real" "16.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:showIconPreview" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:sortColumn" "string" "name"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:textSize" "real" "12.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:useRelativeDates" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ExtendedListViewSettingsV2:viewOptionsVersion" "integer" "1"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:arrangeBy" "string" "none"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:backgroundColorBlue" "real" "1.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:backgroundColorGreen" "real" "1.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:backgroundColorRed" "real" "1.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:backgroundType" "integer" "0"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:gridOffsetX" "real" "0.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:gridOffsetY" "real" "0.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:gridSpacing" "real" "54.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:iconSize" "real" "64.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:labelOnBottom" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:showIconPreview" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:showItemInfo" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:textSize" "real" "12.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":IconViewSettings:viewOptionsVersion" "integer" "1"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:calculateAllSizes" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:comments" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:comments:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:comments:index" "integer" "7"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:comments:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:comments:width" "integer" "300"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateCreated" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateCreated:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateCreated:index" "integer" "2"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateCreated:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateCreated:width" "integer" "181"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateLastOpened" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateLastOpened:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateLastOpened:index" "integer" "8"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateLastOpened:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateLastOpened:width" "integer" "200"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateModified" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateModified:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateModified:index" "integer" "1"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateModified:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:dateModified:width" "integer" "181"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:kind" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:kind:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:kind:index" "integer" "4"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:kind:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:kind:width" "integer" "115"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:label" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:label:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:label:index" "integer" "5"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:label:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:label:width" "integer" "100"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:name" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:name:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:name:index" "integer" "0"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:name:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:name:width" "integer" "300"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:size" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:size:ascending" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:size:index" "integer" "3"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:size:visible" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:size:width" "integer" "97"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:version" "dict"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:version:ascending" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:version:index" "integer" "6"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:version:visible" "bool" "false"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:columns:version:width" "integer" "75"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:iconSize" "real" "16.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:showIconPreview" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:sortColumn" "string" "name"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:textSize" "real" "12.000000"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:useRelativeDates" "bool" "true"
# plb "${plist}" "\"FK_StandardViewSettings\":ListViewSettings:viewOptionsVersion" "integer" "1"
# plb "${plist}" "\"FK_StandardViewSettings\":SettingsType" "string" "\"FK_StandardViewSettings\""
