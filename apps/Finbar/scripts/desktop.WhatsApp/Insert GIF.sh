#!/bin/sh
osascript <<'EOF'
tell application "Hammerspoon" to execute lua code "
spoon.AppScripts.allScripts['desktop.WhatsApp'].insertGif()
"
EOF
