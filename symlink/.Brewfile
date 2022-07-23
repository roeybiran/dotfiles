### taps ###

HOMEBREW_BUNDLE_NO_LOCK=true
cask_args no_upgrade: true

tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/core"

### brew ###

brew "mas"
brew "trash"
brew "node"
brew "z"
brew "fd"
brew "jq"
brew "fzf"
brew "gh"
brew "icdiff"
brew "ripgrep"
brew "tldr"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "shellcheck"
brew "swiftformat" if system "/bin/test -d /Applications/Xcode.app"
brew "swiftlint" if system "/bin/test -d /Applications/Xcode.app"
brew "blueutil"

# fonts dependency
brew "subversion"

### cask ###

cask "dropbox"
cask "1password"
cask "karabiner-elements"
cask "hammerspoon"
cask "launchbar"
cask "contexts"
cask "raycast"
cask "iterm2"
cask "istat-menus"
cask "betterzip"
cask "dash"
cask "font-input"

cask "syntax-highlight", cask_args: ["no-quarantine"]
cask "qlmarkdown"
cask "qlvideo"

### mas ###

mas "Vimari", id: 1480933944
mas "Select Like A Boss For Safari", id: 1437310115
mas "Wipr", id: 1320666476
mas "Hush", id: 1544743900
mas "Shareful", id: 1522267256
mas "CommentHere", id: 1406737173
mas "Milonchik", id: 1534607376
