#!/bin/bash

backup_dotfiles() {
	rsync -avz --delete "$HOME/.dotfiles" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/stuff/backups"
}
