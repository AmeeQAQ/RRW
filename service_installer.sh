#!/bin/bash

#
# This script is used as an automatic way to install the RRW service unit provided in /resources under systemd
#

# Color codes
normal=$(tput sgr0)
red=$(tput setaf 196)
yellow=$(tput setaf 226)
green=$(tput setaf 46)

error_msg() {
	printf "${red}[RRW-Service-Installer]${normal} Errors encountered during installation. Aborting...\n"
}

if [[ "$EUID" -eq 0 ]]; then
	printf "${yellow}[RRW-Service-Installer]${normal} This script must not be run as root. Aborting...\n"
	exit 1
fi

printf "${green}[RRW-Service-Installer]${normal} Proceeding with service unit installation.\n"
if ! cp resources/rrw.service.example $HOME/.config/systemd/user/rrw.service 2>&1; then
	error_msg
	exit 1
fi

printf "${green}[RRW-Service-Installer]${normal} Enabling RRW service.\n"
if ! systemctl enable --user rrw.service 2>&1; then
	error_msg
	exit 1
fi

printf "${green}[RRW-Service-Installer]${normal} RRW Service unit successfully installed. You can run it with:\n"
printf "\t\t\t\tsystemctl start --user rrw.service\n"
printf "${green}[RRW-Service-Installer]${normal}And check its status with:\n"
printf "\t\t\t\tsystemctl status --user rrw.service\n"
