#!/usr/bin/env bash

plb () {
	local domain="${1}"
	local key="${2}"
	local type="${3}"
	local value="${4}"
	# check if entry exists
	if /usr/libexec/PlistBuddy -c "Print ${key}" "${domain}" &>/dev/null; then
		# if so, use the 'set' command
		if [[ $# -eq 3 ]]; then
		# if 3 args, skip to avoid the 'cannot perfrom 'set' on containers error'
			return 0
		else
			/usr/libexec/PlistBuddy -c "Set ${key} ${value}" "${domain}"
		fi
	else
		# if entry doesnt exist, use the 'add' command
		if [[ $# -eq 3 ]]; then
		# if 3 args, it's a container
			/usr/libexec/PlistBuddy -c "Add ${key} ${type}" "${domain}"
		else
			/usr/libexec/PlistBuddy -c "Add ${key} ${type} ${value}" "${domain}"
		fi
	fi
}
