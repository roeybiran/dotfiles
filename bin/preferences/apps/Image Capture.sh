#!/bin/bash

# Prevent Image Capture from opening automatically when devices are plugged in *
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
