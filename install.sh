#!/bin/bash

command -v brew 1>/dev/null 2>&1 || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew bundle install --global
