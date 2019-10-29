#!/bin/bash

# requires trash-cli, chalk-cli
# check if the file exists
# if a symlink && valid
	# leave alone && continue
# else
	# trash
# else if its dir doesnt exists
# create
# symlink

file="${BASH_SOURCE[0]}"
dir="$(cd "$(dirname "${file}")" >/dev/null 2>&1 && pwd)"
dir="$(dirname "${dir}")"
SYMLINKS_ROOT="${dir}/root"

if [[ ! -d "${SYMLINKS_ROOT}" ]]
then
	red "NOT FOUND: ${SYMLINKS_ROOT}" && exit 0
fi

output=$(/usr/bin/find "${SYMLINKS_ROOT}" \( -name '_link_*' \) -or \( '-name' '_sync_*' \))

while read -r find_result; do

	# for each find result, slice root dir from start to get the actual destination
	destination_dirname=$(dirname "${find_result:${#SYMLINKS_ROOT}}")
	# for each find result, slice 6 chars fron start of basename to get the actual destination name (#6 = the _(link|sync)_ prefix)
	destination_basename=$(basename "${find_result}"); destination_basename="${destination_basename:6}"
	# compose the actual path
	destination="${destination_dirname}/${destination_basename}"
	# shorten for display purposes
	destination_shortened="${destination/${HOME}/~}"

	if [[ "${find_result}" == *"/_link_"* ]]; then
		if test -e "${destination}"; then
			if test -L "${destination}"; then
				green "Valid @ ${destination_shortened}"
				continue
			fi
			red "Trashing ${destination_shortened}"
			/usr/local/bin/trash "${destination}"
		else
			if ! test -f "${destination_dirname}"; then
				mkdir -p "${destination_dirname}"
			fi
		fi
		green "Creating @ ${destination_shortened}"
		ln -sf "${find_result}" "${destination}"

	elif [[ "${find_result}" == *"/_sync_"* ]]; then
		green "Syncing to ${destination_shortened}"
		rsync -a "${find_result}" "${destination}"
	fi
done <<< "${output}"
