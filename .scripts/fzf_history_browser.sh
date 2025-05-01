#!/bin/bash

# https://github.com/junegunn/fzf/blob/d226d841a1f2b849b7e3efab2a44ecbb3e61a5a5/shell/key-bindings.zsh#L108
# https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
# https://github.com/junegunn/fzf/blob/4e3f9854e67f70f17eba8fd6c480cbe9ca1a6cee/shell/completion.zsh#L292

# location of my history file
export HISTFILE="$HOME/.history/.zsh_history"

# fzf-delete-history-widget() {
#     local selected num
#     setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
#     local selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
# FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --multi --bind 'enter:become(echo {+1})'" $(__fzfcmd)) )
#     local ret=$?
#     if [ -n "$selected[*]" ]; then
#       hist delete $selected[*]
#     fi
#     zle reset-prompt
#     return $ret
# }

# zle     -N            fzf-delete-history-widget
# bindkey -M emacs '^H' fzf-delete-history-widget
# bindkey -M vicmd '^H' fzf-delete-history-widget
# bindkey -M viins '^H' fzf-delete-history-widget
# export FZF_CTRL_R_OPTS="--bind=\"ctrl-d:execute-silent(awk '{print \$1}' {+f1..} | while read -r linenum; do sed -i "\${linenum}d" "$HISTFILE"; done),ctrl-d:+refresh-preview\" --header \"CTRL-D to remove command from history\""

# export FZF_CTRL_R_OPTS="$(
# 	cat <<'FZF_FTW'
# --bind "ctrl-d:execute(sed -i '' '$d' $HISTFILE)+reload:fc -pa $HISTFILE; fc -rl 1 |
# 	awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, \"\", cmd); if (!seen[cmd]++) print $0 }'"
# --bind "start:reload:fc -pa $HISTFILE; fc -rl 1 |
# 	awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, \"\", cmd); if (!seen[cmd]++) print $0 }'"
# --header 'enter select · ^d remove latest'
# --height 100%
# --preview-window "hidden:down:border-top:wrap:<70(hidden)"
# --preview "bat --plain --language sh <<<{2..}"
# --prompt " History > "
# --with-nth 2..
# FZF_FTW
# )"