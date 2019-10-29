#!/bin/bash

GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
RED='\033[0;31m'

red () {
    echo -e "${RED}==>${RESET}" "${@}"
}

green () {
    echo -e "${GREEN}==>${RESET}" "${@}"
}

magenta () {
    echo -e "${MAGENTA}==>${RESET}" "${@}"
}
