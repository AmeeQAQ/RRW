#!/bin/bash

# Color codes
normal=$(tput sgr0)
red=$(tput setaf 196)
yellow=$(tput setaf 226)
green=$(tput setaf 46)

# Install RRW and JSON generator
script_install_dir=/usr/local/bin

error_mngr() {
	printf "${red}[ERROR]${normal} Installation encountered errors during the process, please review terminal's output for further information.\n"
	echo 'Reverting changes...'
	bash uninstall.sh "$script_install_dir" "$user_dir"
	if [ "$?" -eq 1 ]; then
		echo 'Aborted.'
		exit 1
	else
		echo 'Changes reverted.'
		exit 0
	fi
}

if [ "$EUID" -ne 0 ]; then
	printf "${red}[ERROR]${normal} This script must be run as root due to it needing to install rrw.sh and rrw-jsongen.sh under /usr/local/bin/. You can modify this script to change this location at your own risk.\n"
	exit 1
fi

user_dir=$(getent passwd $SUDO_USER | cut -d: -f6)

printf "${green}[RRW-Installer]${normal} Installing rrw.sh under %s\n" "$script_install_dir"
if ! cp src/rrw.sh $script_install_dir/rrw 2>&1; then
	error_mngr
	exit 1
fi

printf "${green}[RRW-Installer]${normal} Installing rrw-jsongen.sh under %s\n" "$script_install_dir"
if ! cp src/rrw-jsongen.sh $script_install_dir/rrw-jsongen 2>&1; then
	error_mngr
	exit 1
fi

# Make RRW's config directory under ~/.config/
printf "${green}[RRW-Installer]${normal} Creating config dir @ %s/.config/\n" "$user_dir"
if ! mkdir $user_dir/.config/rrw 2>&1; then
	error_mngr
	exit 1
fi

pwd

# Place configuration file under RRW's config directory
printf "${green}[RRW-Installer]${normal} Installing configuration file under config dir.\n"
if ! cp resources/rrw.conf.example $user_dir/.config/rrw/rrw.conf 2>&1; then
	error_mngr
	exit 1
fi

# Change ownership of home installed files to user
chown -R $SUDO_USER:$SUDO_USER $user_dir/.config/rrw

printf "${green}[RRW-Installer]${normal} RRW has been successfully installed.\n"
echo 'Run "rrw-jsongen" to generate the JSON necessary for RRW to work.'
printf "\trrw-jsongen -h, --help for further instructions.\n"
echo
echo 'Remember to modify rrw.conf @ ~/.config/rrw/'
echo
echo 'If you want to make RRW a background process, follow the instructions inside rrw.service.example or run service_installer.sh'
