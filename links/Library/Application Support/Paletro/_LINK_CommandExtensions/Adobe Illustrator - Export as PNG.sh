#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"

# resolve $SOURCE until the file is no longer a symlink
while [[ -L "${SOURCE}" ]]; do
	DIR="$(cd -P "$(dirname "${SOURCE}")" >/dev/null 2>&1 && pwd)"
	SOURCE="$(readlink "${SOURCE}")"
	# if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	[[ "${SOURCE}" != /* ]] && SOURCE="${DIR}/${SOURCE}"
done

DIR="$(dirname "${SOURCE}")"

osascript "${DIR}/Adobe Illustrator - Export as.scpt" png
