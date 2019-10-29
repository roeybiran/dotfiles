#!/bin/bash

if [[ -z "${2}" ]]
then
	exit 0
fi

# configure a specific app
match=$(find "$(dirname "${BASH_SOURCE[0]}")" -type f -iname "*${2}*")

count=$(echo "${match}" | wc -l | grep -E -o '\d')

if [[ "${count}" -gt 1 ]]
then
	printf "%s\n%s" "More than 1 match:" "${match}"
	exit 0
fi

echo "==> Configuring" "$(basename "${match}")"
"${match}" "${@}"
