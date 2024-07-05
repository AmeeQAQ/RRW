#!/bin/bash

# Color codes
normal=$(tput sgr0)
red=$(tput setaf 196)
yellow=$(tput setaf 226)
green=$(tput setaf 46)

session_type=$(echo $XDG_SESSION_TYPE)
desktop_env=$(echo $XDG_CURRENT_DESKTOP)

check_dependencies() {
	if ! jq --help &>/dev/null 2>&1; then
		printf "${red}[RRW-Installer]${normal} please install jq with your package manager before proceeding.\n"
		exit 1
	else
		printf "${green}[RRW-Installer] jq verified.${normal}\n"
	fi
	if [[ "$session_type" == "wayland" ]]; then
		if [[ "$desktop_env" == "KDE" ]]; then
			if ! kscreen-doctor --help &>/dev/null 2>&1; then
				printf "${red}[RRW-Installer]${normal} please install kscreen-doctor with your package manager before proceeding.\n"
				exit 1
			else
				printf "${green}[RRW-Installer] kscreen-doctor verified.${normal}\n"
			fi
		elif echo "$desktop_env" | grep 'GNOME' &>/dev/null 2>&1; then
			if ! gnome-randr --help &>/dev/null 2>&1; then
				printf "${red}[RRW-Installer]${normal} please install gnome-randr from https://github.com/maxwellainatchi/gnome-randr-rust, or the AUR if you use an Arch-based distro, before proceeding.\n"
				exit 1
			else
				printf "${green}[RRW-Installer] gnome-randr verified.${normal}\n"
			fi
		elif ! wlr-randr --help &>/dev/null 2>&1; then
			printf "${red}[RRW-Installer]${normal} please install wlr-randr with your package manager before proceeding.\n"
		else
			printf "${green}[RRW-Installer] wlr-randr verified.${normal}\n"
		fi
	elif ! xrandr --help &>/dev/null 2>&1; then
		printf "${red}[RRW-Installer]${normal} please install xrandr with your package manager before proceeding.\n"
	else
		printf "${green}[RRW-Installer] xrandr verified.${normal}\n"
	fi
}

check_dependencies
sudo bash installers/sudo_install.sh
