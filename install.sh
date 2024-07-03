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

root_flag=1
user_dir=""

if [ "$EUID" -ne 0 ]; then
	printf "${yellow}[WARNING]${normal} You are NOT running this script as root. The default location for RRW to be installed requires root privileges. Rerun this script as root or change the install location to a folder in your PATH that's under your home directory.\n"
	root_flag=0
fi

# If the script is being run as root, fetch the user's home dir
if [[ root_flag -eq 1 ]]; then
	user_dir=$(getent passwd $SUDO_USER | cut -d: -f6)
fi

printf "${green}[RRW]${normal} Installing rrw.sh under %s\n" "$script_install_dir"
if ! cp rrw.sh $script_install_dir/rrw 2>&1; then
	error_mngr
	exit 1
fi

printf "${green}[RRW]${normal} Installing rrw-jsongen.sh under %s\n" "$script_install_dir"
if ! cp rrw-jsongen.sh $script_install_dir/rrw-jsongen 2>&1; then
	error_mngr
	exit 1
fi

# Make RRW's config directory under ~/.config/
if [[ root_flag -eq 0 ]]; then
	printf "${green}[RRW]${normal} Creating config dir @ %s/.config/\n" "$HOME"
	if ! mkdir $HOME/.config/rrw 2>&1; then
		error_mngr
		exit 1
	fi
else
	printf "${green}[RRW]${normal} Creating config dir @ %s/.config/\n" "$user_dir"
	if ! mkdir $user_dir/.config/rrw 2>&1; then
		error_mngr
		exit 1
	fi
fi

# Place configuration file under RRW's config directory
printf "${green}[RRW]${normal} Installing configuration file under config dir.\n"
if [[ root_flag -eq 0 ]]; then
	if ! cp resources/rrw.conf.example $HOME/.config/rrw/rrw.conf 2>&1; then
		error_mngr
		exit 1
	fi
else
	if ! cp resources/rrw.conf.example $user_dir/.config/rrw/rrw.conf 2>&1; then
		error_mngr
		exit 1
	fi
fi

# Change ownership of home installed files to user
chown -R $SUDO_USER:$SUDO_USER $user_dir/.config/rrw

printf "${green}[RRW]${normal} RRW has been successfully installed.\n"
echo 'Run "rrw-jsongen" to generate the JSON necessary for RRW to work.'
printf "\trrw-jsongen -h, --help for further instructions.\n"
echo
echo 'If you want to make RRW a background process, follow the instructions inside rrw.service.example'
