#!/usr/bin/env bash

export yellow=#b58900
export orange=#cb4b16
export red=#dc322f
export magenta=#d33682
export violet=#6c71c4
export blue=#268bd2
export cyan=#2aa198
export green=#859900

base03=#002b36
# dark > background
# light > ---

base02=#073642
# dark > background highlights
# light > ---

base01=#586e75
# dark > comments / secondary content
# light > optional emphasized content

base00=#657b83
# dark > ---
# light > body text / default code / primary content

base0=#839496
# dark > body text / default code / primary content
# light > ---

base1=#93a1a1
# dark > optional emphasized content
# light > comments / secondary content

base2=#eee8d5
# dark >  ---
# light > background highlights

base3=#fdf6e3
# dark > ---
# light > background

if [[ "$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
  background=$base03
  foreground=$base0
  highlights=$base02
else
  background=$base3
  foreground=$base00
  highlights=$base2
fi

tmux=/opt/homebrew/bin/tmux

sync_fmt="#[bg=$magenta#,bold#,fg=$background] SYNC #[noreverse]"
prefix_fmt="#[bg=$orange#,bold#,fg=$background] PREFIX #[noreverse]"
copy_fmt="#[bg=$green#,bold#,fg=$background] COPY #[noreverse]"
empty_fmt=""
sync="#{?synchronize-panes,$sync_fmt,$empty_fmt}"
copy="#{?pane_in_mode,$copy_fmt,$empty_fmt}"
prefix="#{?client_prefix,$prefix_fmt,$empty_fmt}"

"$tmux" set -g status-right " $prefix$copy$sync "

"$tmux" set -g pane-border-format " [#{pane_index}] #{pane_title} "
"$tmux" set -g pane-border-style "fg=$foreground"
"$tmux" set -g pane-active-border-style "fg=$red"

"$tmux" set -g status-style "bg=$highlights"

"$tmux" set -g window-status-style "fg=$foreground,bg=default"
"$tmux" set -g window-status-current-style "fg=$background,bg=$cyan,bold"

"$tmux" set -g window-status-format " #I:#W "
"$tmux" set -g window-status-current-format " #I:#W "

"$tmux" set -g message-style "fg=$background,bg=$blue"

"$tmux" set -g -w clock-mode-colour "$green"
"$tmux" set -g display-panes-colour "$foreground"
"$tmux" set -g display-panes-active-colour "$red" 
