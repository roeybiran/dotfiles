#!/usr/bin/env bash

checkfile () {
	f="${1}"
	if [ -e "${f}" ]; then
		green "${f} exists"
		return 0
	else
		red "${f} does not exist"
		return 1
	fi
}
