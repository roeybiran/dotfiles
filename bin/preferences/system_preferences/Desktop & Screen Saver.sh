#!/bin/bash

# Set desktop to dynamic
osascript -e 'tell application "System Events" to set picture of current desktop to "/System/Library/CoreServices/DefaultDesktop.heic"' 2>/dev/null
