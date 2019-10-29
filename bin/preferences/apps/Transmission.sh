#!/bin/bash

defaults write "org.m0k.transmission" WarningDonate -bool false
defaults write "org.m0k.transmission" WarningLegal -bool false
# default dl location: ~/Downloads
defaults write "org.m0k.transmission" DownloadLocationConstant -bool false
