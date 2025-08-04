#!/bin/bash

LONG_CMD_THRESHOLD=5  # seconds

preexec() {
  CMD_START_TIME=$(date +%s)
}

precmd() {
  if [[ -n "$CMD_START_TIME" ]]; then
    local CMD_END_TIME=$(date +%s)
    local DURATION=$((CMD_END_TIME - CMD_START_TIME))
    if (( DURATION >= LONG_CMD_THRESHOLD )); then
      echo -ne "\a"
    fi
    unset CMD_START_TIME
  fi
}
