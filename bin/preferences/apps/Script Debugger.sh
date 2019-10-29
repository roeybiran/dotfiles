#!/bin/bash

plist="${HOME}/Library/Preferences/com.latenightsw.ScriptDebugger7.plist"

# remember open scripts
defaults write "com.latenightsw.ScriptDebugger7" "PrefStartupRememberOpenScripts" -bool true

# For New Documents: (·) Use template: AppleScript
defaults write "com.latenightsw.ScriptDebugger7" "PrefDefaultTemplate" -string "/Applications/Script Debugger.app/Contents/Library/Templates/AppleScript/AppleScript/AppleScript.sdtemplate"
defaults write "com.latenightsw.ScriptDebugger7" "PrefUseDefaultTemplate" -bool true

# Text Substituions: [ ] Enabled
defaults write "com.latenightsw.ScriptDebugger7" "PrefEditorDoTextSubstitution" -bool false

# Dont bring to foreground when script ends
defaults write "com.latenightsw.ScriptDebugger7" "PrefActivateOnScriptEnd" -bool false

# Dont bring to foreground when script pauses
defaults write "com.latenightsw.ScriptDebugger7" "PrefActivateOnScriptPause" -bool false

# Enable automatic updates
defaults write "com.latenightsw.ScriptDebugger7" "SUAutomaticallyUpdate" -bool true
defaults write "com.latenightsw.ScriptDebugger7" "SUHasLaunchedBefore" -bool true

/usr/libexec/PlistBuddy -c "Delete LNSUserDefaultsKeyEquivs" "${plist}" 2>/dev/null
/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doComment\::key string "/"' "${plist}"
/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doComment\::mask integer 1048576' "${plist}"
/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doUncomment\::key string "/"' "${plist}"
/usr/libexec/PlistBuddy -c 'Add LNSUserDefaultsKeyEquivs:doUncomment\::mask integer 1572864' "${plist}"
/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoNextTab\::key string \"\\t\"" "${plist}"
/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoNextTab\::mask integer 262144" "${plist}"
/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoPrevTab\::key string \"\\t\"" "${plist}"
/usr/libexec/PlistBuddy -c "Add LNSUserDefaultsKeyEquivs:gotoPrevTab\::mask integer 393216" "${plist}"
