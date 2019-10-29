#!/bin/bash
# https://github.com/mosen/mysides

# Mojave
# Add $HOME to "Favorites"
/usr/local/bin/mysides add "${USER}" "file://${HOME}" &>/dev/null
/usr/local/bin/mysides remove "Creative Cloud Files" &>/dev/null
