#!/bin/bash

backup_dotfiles() {
 rsync -avz "$HOME/dotfiles" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/"
}

