#!/bin/bash

#
# This script is meant to be run either from inside the install script or standalone if you wanna remove RRW. Either way, needs to be run as root
#

# Color codes
normal=$(tput sgr0)
red=$(tput setaf 196)
yellow=$(tput setaf 226)
green=$(tput setaf 46)

if [[ ! "$EUID" -eq 0 ]];then
	printf "${red}[ERROR]${normal} This script must be run as root.\n"
	exit 1
fi

printf "${yellow}[RRW-Uninstall]${normal} Reverting changes/removing RRW.\n"

# Remove exec files from directory
printf "${yellow}[RRW-Uninstall]${normal} Removing executables...\n"
if ! rm $1/rrw 2>&1 || ! rm $1/rrw-jsongen 2>&1; then
	printf "${red}[ABORTING] ERRORS FOUND DURING REMOVAL.\n"
	exit 1
fi
printf "${green}[RRW-Uninstall]${normal} Executables removed successfully.\n"

confirm=""
# Remove config folder and its contents
printf "${yellow}[RRW-Uninstall]${normal} Removing config folder...\n"
printf "${yellow}[WARNING]${normal} MAKE SURE THAT THE DIRECTORY ABOUT TO BE REMOVED IS THE APPROPRIATE ONE.\n"
read -p "Is $2/.config/rrw the correct path? (N/y): " confirm
if [[ "$confirm" == "y" ]]; then
	rm -r $2/.config/rrw
	printf "${green}[RRW-Uninstall]${normal} Config directory successfully removed.\n"
else
	printf "${yellow}[RRW-Uninstall]${normal} Aborting removal of config dir.\n"
fi

printf "${green}RRW has been successfully uninstalled.\n"
