#!/bin/bash

my_brew="$(cat "${BREWFILE}")"
my_cask="$(cat "${CASKFILE}")"
my_mas="$(awk '{ print $1 }' <"${MASFILE}")"
my_npm="$(cat "${NPMFILE}")"
my_pip="$(cat "${PIPFILE}")"
my_luarocks="$(cat "${LUAROCKSFILE}")"

brew_current() {
	brew leaves
}
cask_current() {
	brew cask list
}
mas_current() {
	mas list | awk '{ print $1 }'
}
npm_current() {
	npm list -g --depth=0 | awk "NR>1" | sed 's/├── //' | sed 's/└── //' | sed 's/@.*//' | sed -E 's/^npm$//'
}
pip_current() {
	pip3 list --not-required | awk "NR>2" | awk '{ print $1 }' | sed -E 's/^setuptools$//' | sed -E 's/^pip$//' | sed -E 's/^wheel$//'
}
luarocks_current() {
	luarocks list --porcelain | awk '{ print $1 }'
}

compare() {
	list1="${1}"
	list2="${2}"
	msg="${3}"

	while IFS=$'\n' read -r list1item; do
		if ! grep --silent "${list1item}" <<<"${list2}"; then

			# make mas id human-readable
			if grep -E --silent "^\d+$" <<<"${list1item}" && [[ "${msg}" == *flagged* ]]; then
				list1item="$(mas info "${list1item}" | head -n 1)"
			fi
			eval "${msg}" "${list1item}"
		fi
	done <<<"${list1}"
}

elevate() {
	osascript -e 'tell application "System Preferences" to quit'
	sudo -v
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
}

if [[ "${2}" == cleanup ]]; then
	modes=("install" "uninstall")
	elevate
elif [[ "${2}" == status ]]; then
	modes=("to_install" "to_uninstall")
else
	modes=("install" "to_uninstall")
	elevate
fi

### brew ###
if ! command -v brew &>/dev/null; then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# set -x

for mode in "${modes[@]}"; do
	if [[ "${mode}" == install ]]; then
		BREWCOMMAND="brew install"
		BREWCASKCOMMAND="brew cask install"
		MASCOMMAND="mas install"
		NPMCOMMAND="npm install -g"
		PIP3COMMAND="pip3 install --user"
		LUAROCKSCOMMAND="luarocks install"
		compare "${my_brew}" "$(brew_current)" "${BREWCOMMAND}"
		compare "${my_cask}" "$(cask_current)" "${BREWCASKCOMMAND}"
		compare "${my_mas}" "$(mas_current)" "${MASCOMMAND}"
		compare "${my_npm}" "$(npm_current)" "${NPMCOMMAND}"
		compare "${my_pip}" "$(pip_current)" "${PIP3COMMAND}"
		compare "${my_luarocks}" "$(luarocks_current)" "${LUAROCKSCOMMAND}"
	elif [[ "${mode}" == to_install ]]; then
		BREWCOMMAND='green "flagged for installation:"'
		BREWCASKCOMMAND='green "flagged for installation:"'
		MASCOMMAND='green "flagged for installation:"'
		NPMCOMMAND='green "flagged for installation:"'
		PIP3COMMAND='green "flagged for installation:"'
		LUAROCKSCOMMAND='green "flagged for installation:"'
		compare "${my_brew}" "$(brew_current)" "${BREWCOMMAND}"
		compare "${my_cask}" "$(cask_current)" "${BREWCASKCOMMAND}"
		compare "${my_mas}" "$(mas_current)" "${MASCOMMAND}"
		compare "${my_npm}" "$(npm_current)" "${NPMCOMMAND}"
		compare "${my_pip}" "$(pip_current)" "${PIP3COMMAND}"
		compare "${my_luarocks}" "$(luarocks_current)" "${LUAROCKSCOMMAND}"
	elif [[ "${mode}" == uninstall ]]; then
		BREWCOMMAND="brew uninstall"
		BREWCASKCOMMAND="brew cask uninstall"
		MASCOMMAND="mas uninstall"
		NPMCOMMAND="npm uninstall -g"
		PIP3COMMAND="pip3 uninstall -y"
		LUAROCKSCOMMAND="luarocks remove"
		compare "$(brew_current)" "${my_brew}" "${BREWCOMMAND}"
		compare "$(cask_current)" "${my_cask}" "${BREWCASKCOMMAND}"
		compare "$(mas_current)" "${my_mas}" "${MASCOMMAND}"
		compare "$(npm_current)" "${my_npm}" "${NPMCOMMAND}"
		compare "$(pip_current)" "${my_pip}" "${PIP3COMMAND}"
		compare "$(luarocks_current)" "${my_luarocks}" "${LUAROCKSCOMMAND}"
	elif [[ "${mode}" == to_uninstall ]]; then
		BREWCOMMAND='red "flagged for deletion:"'
		BREWCASKCOMMAND='red "flagged for deletion:"'
		MASCOMMAND='red "flagged for deletion:"'
		NPMCOMMAND='red "flagged for deletion:"'
		PIP3COMMAND='red "flagged for deletion:"'
		LUAROCKSCOMMAND='red "flagged for deletion:"'
		compare "$(brew_current)" "${my_brew}" "${BREWCOMMAND}"
		compare "$(cask_current)" "${my_cask}" "${BREWCASKCOMMAND}"
		compare "$(mas_current)" "${my_mas}" "${MASCOMMAND}"
		compare "$(npm_current)" "${my_npm}" "${NPMCOMMAND}"
		compare "$(pip_current)" "${my_pip}" "${PIP3COMMAND}"
		compare "$(luarocks_current)" "${my_luarocks}" "${LUAROCKSCOMMAND}"
	fi
done


# oh-my-zsh
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi


# updates: runs every 3 days
now="$(date +%s)"
lastUpdateDate="$(/usr/libexec/PlistBuddy -c "Print :packageManagersLastUpdateDate" "${DOTFILES_PREFS}" 2>/dev/null)"
threeDaysInSeconds=259200
if [[ -z "${lastUpdateDate}" ]]; then
	lastUpdateDate=0
fi
timeElapsedSinceUpdate=$((now - lastUpdateDate))
if [[ "${timeElapsedSinceUpdate}" -gt "${threeDaysInSeconds}" ]]; then
	brew update
	brew upgrade
	brew cask upgrade
	npm update -g
	npm install -g npm
	mas upgrade
	brew doctor
	/usr/libexec/PlistBuddy -c "Delete :packageManagersLastUpdateDate" "${DOTFILES_PREFS}" &>/dev/null
	/usr/libexec/PlistBuddy -c "Add :packageManagersLastUpdateDate integer ${now}" "${DOTFILES_PREFS}" &>/dev/null
fi
