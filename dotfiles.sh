#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"

while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

NAME="$(basename "${SOURCE}")"
DIR="$(dirname "${SOURCE}")"
BIN="${DIR}/bin"
LIBDIR="${DIR}/lib/"

TERMID="$(osascript -e 'tell application "System Events" to return bundle identifier of application process 1 whose frontmost of it = true')" && export TERMID

export DOTFILES_PREFS="${HOME}/Library/Preferences/com.roeybiran.dotfiles.plist"
export SERVICESFILE="${LIBDIR}/services.plist"
export PREFS_DIR="${BIN}/preferences"
export APPS_DIR="${PREFS_DIR}/apps"
export PANES_DIR="${PREFS_DIR}/system_preferences/"

export BREWFILE="${LIBDIR}/brew.conf"
export CASKFILE="${LIBDIR}/cask.conf"
export LUAROCKSFILE="${LIBDIR}/luarocks.conf"
export MASFILE="${LIBDIR}/mas.conf"
export NPMFILE="${LIBDIR}/npm.conf"
export PIPFILE="${LIBDIR}/pip.conf"

for f in "${LIBDIR}/"*".sh"
do
	# shellcheck source=/dev/null
	source "${f}"
done

export -f checkfile
export -f align_window
export -f plb
export -f red
export -f magenta
export -f green

# add dotfiles.sh to PATH
if [[ ! -e /usr/local/bin/dotfiles ]]; then
	ln -s "${SOURCE}" /usr/local/bin/dotfiles
fi

### runtime ###

menu=()

for file in "${BIN}/"*; do
	if [[ -f "${file}" ]]; then
		file="$(basename "${file}")"
		if [[ "${file}" == *-* ]]; then
			file="${file:2}"
		fi
		menu+=("${file%.*}")
	fi
done

if [[ "${1}" == "standard" ]]; then
	for file in "${BIN}/"*; do
		if [[ -f "${file}" ]] && [[ "${file}" == *-* ]]; then
			"${file}"
		fi
	done
elif [[ "${1}" == "app" ]]; then
  "${BIN}/app.sh" "${@}"
else
	if printf "%s\n" "${menu[*]}" | grep --silent "${1}"
	then
		for file in "${BIN}/"*; do
			if [[ -f "${file}" ]] && [[ "${file}" == *"${1}"* ]]
			then
				"${file}" "${@}"
				exit 0
			fi
		done
	else
		printf "%s\n" "USAGE:"
		printf "\t%s\n" "${NAME} <command> [options]"
		printf "%s\n" "COMMAND:"
		for s in "${menu[@]}"; do
			printf "\t%s\n" "${s}"
		done
	fi
fi
