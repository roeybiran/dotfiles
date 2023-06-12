#!/bin/sh

if [ ! -f ~/.ssh/config ]; then
  mkdir ~/.ssh
  touch ~/.ssh/config
fi

printf "%s\n" 'Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519' >~/.ssh/config
