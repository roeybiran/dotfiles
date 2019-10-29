#!/usr/bin/env bash

# change from alerts to banners -- add 56
# remove from lockscreen -- add 4096
ncPrefsPlist="${HOME}/Library/Preferences/com.apple.ncprefs.plist"
cachePlist="${DOTFILES_PREFS}"

/usr/libexec/PlistBuddy -c "Add :notificationsInitialFlags dict" "${cachePlist}" &>/dev/null

bundleIDCount="$(defaults read "${ncPrefsPlist}" apps | grep -c "bundle-id")"

for ((i = 0; i < "${bundleIDCount}"; i++)); do

  bundleid="$(/usr/libexec/PlistBuddy -c "Print apps:$i:bundle-id" "${ncPrefsPlist}")"
  flagsChangeValue=0

  case "${bundleid}" in
    *"apple.appstore"*|*"apple.TelephonyUtilities"*|*"apple.notificationcenter"*|*"_SYSTEM_CENTER_"*|*"_WEB_CENTER_"*)
      continue
    ;;
    "com.dropbox.alternatenotificationservice"|"com.google.Chrome.framework.AlertNotificationService"|"com.agilebits.onepassword7"|"com.getdropbox.dropbox")
    ((flagsChangeValue=flagsChangeValue+56))
    ;;
  esac

  ((flagsChangeValue=flagsChangeValue+4096))

  initialFlags="$(/usr/libexec/PlistBuddy -c "Print notificationsInitialFlags:\"${bundleid}\"" "${cachePlist}" 2>/dev/null)"
  if [[ -z "${initialFlags}" ]]; then
    initialFlags="$(/usr/libexec/PlistBuddy -c "Print apps:$i:flags" "${ncPrefsPlist}")"
  fi

  targetFlags=$((initialFlags+flagsChangeValue))

  /usr/libexec/PlistBuddy -c "Add :notificationsInitialFlags:\"${bundleid}\" integer \"${initialFlags}\"" "${cachePlist}" &>/dev/null
  /usr/libexec/PlistBuddy -c "Set :apps:$i:flags $targetFlags" "${ncPrefsPlist}"

done

# prolong banner presence
defaults write com.apple.notificationcenterui bannerTime -int 10
# accept repeated calls while in do not disturb
defaults write "com.apple.messages.facetime" FaceTimeTwoTimeCallthroughEnabled -bool true
# possibly replace in catalina with this?
defaults write "com.apple.messageshelper.FavoritesController" FaceTimeTwoTimeCallthroughEnabled -bool true
