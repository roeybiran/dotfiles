# dotfiles

Set up a new Mac quickly.

## Structure

This script consists of 3 “domains”, each with its own purpose — symlinking, installing packages and applying user preferences. Those are represented by 3 top-level scripts, respectively: `link.sh`, `install.sh` and `settings.sh`.

Upon first execution, the following execution order **must** be adhered to:

1. `link`
2. `install`
3. `settings`

Subsequent runs may follow any order. Each script is idempotent.

## How `link` works

TBD.

## Highlights

- All `brew` and `mas` packages managed by a `Brewfile`.
- Automated installations of `pdftk` and `SwiftDefaultApps`.
- Extensive customization of apps and defaults.
- Includes a script that greatly eases the process of granting apps “Full Disk Access” and “Accessibility” permissions.
- Automated login items management.
- Optimized .gitignore for macOS, Node.js and Xcode.

## Usage

```shell
dotfiles.sh

Usage:
	dotfiles <command> [options...]

Commands:
	link
	install
	settings
```

## Needs manual configuration

- System Preferences

  - Notifications preference pane
    - turn on do not disturb when the display is sleeping and/or screen is locked
  - Extensions preference pane
    - enable all extensions
  - Apple ID preference pane
    - Free Downloads: Never Require
    - Purchases: Require After 15 minutes

- Finder preferences

  - tick "Computer" + tick "Hard disks" in the sidebar

- Safari preferences

  - Websites > Downloads: allow all
  - Websites > Auto-Play: allow all
  - Extensions: enable all

- Dropbox

  - General > Open folders in: Finder
  - Backups > untick "Enable camera uploads for:"...
  - Backups > untick "Share screenshots using Dropbox"...

- Toggle

  - log in

- Messages

  - set up
