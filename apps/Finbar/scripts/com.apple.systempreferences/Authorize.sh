#!/bin/sh
osascript <<'EOF'
tell application "System Settings" to authorize current pane
EOF
