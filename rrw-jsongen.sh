#!/bin/bash

help() {
	# Display help menu
	echo "Script to generate the JSON file necessary for RRW"
	echo
	echo "Usage: rrw-jsongen games..."
	echo 'Where "games" is a variable required argument in which you should write the process name'
	echo 'Example: rrw-jsongen eldenring nioh dota2 hl2 ...'
	echo "Always check for the process' name with ps/(h)top/etc..."
	exit 0
}

if [ -z "$@" ]; then
	echo "No games provided, please rerun this command with -h, --help".
	exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	help
fi

rrw_dir=$HOME/.config/rrw/

touch $rrw_dir/games.json

rrw_json=$rrw_dir/games.json

printf '{"games":[' > $rrw_json

for game in "$@" 
do
	printf '{"name":\"%s\"},' "$game"  >> $rrw_json
done

sed -i '$ s/.$//' $rrw_json &>/dev/null

printf ']}\n' >> $rrw_json

