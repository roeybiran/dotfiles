#!/bin/bash

function betas() {
  for arg in "${@}"; do
    for f in ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/"$arg".app; do
      open "$f"
      break
    done
  done
}