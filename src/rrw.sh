#!/bin/bash

# Function to check for each game inside the game list
game_check() {
	for game in ${game_list[@]}
	do
		if pgrep -f "$game" &> /dev/null 2>&1; then
			detected=$game
			proc_flag=1
			break
		fi
	done
}

# Function to change the screen's refresh rate
rr_change() {
	systemctl --user show-environment
	if [[ "$session_type" == "wayland" ]]; then
		if [[ "$desktop_environment" == "KDE" ]]; then
			kscreen-doctor output.$screen_output_name.mode.$screen_resolution@$1
		elif echo "$desktop_environment" | grep "GNOME" &>/dev/null; then
			gnome-randr modify $screen_output_name --mode $screen_resolution@$1
		else
			wlr-randr --output $screen_output_name --mode $screen_resolution@$1
		fi
	else
		display=$(systemctl --user show-environment | grep DISPLAY | cut -d '=' -f 2)
		xauth=$(systemctl --user show-environment | grep XAUTHORITY | cut -d '=' -f 2)
		export DISPLAY=$display
		export XAUTHORITY=$xauth
		xrandr --output $screen_output_name --mode $screen_resolution --rate $1
	fi
}

# Make sure there's no parameters
if [[ ! -z "$@"  ]]; then
	echo "Unknown parameter(s), please run RRW with no parameters."
	exit 1
fi

# RRW default config dir
rrw_dir=$HOME/.config/rrw

# RRW default games.json location
rrw_json=$HOME/.config/rrw/games.json

# Check games.json existence. If it exists, check that it is not empty
if [ ! -f "$rrw_json" ]; then
	echo '"games.json" not found. Generate it using the "rrw-jsongen" utility.'
	exit 1
elif [[ -z $(grep '[^[:space:]]' $rrw_json) ]]; then
	echo '"games.json" is empty. Generate a valid file with the "rrw-jsongen" utility.'
	exit 1
fi

detected=""

proc_flag=0

# Gather system data
session_type=$(echo $XDG_SESSION_TYPE)
desktop_environment=$(echo $XDG_CURRENT_DESKTOP)

echo $XDG_SESSION_TYPE
echo $XDG_CURRENT_DESKTOP

screen_output_name=$(grep "screen_output_name" $rrw_dir/rrw.conf | awk '{print $3}')
screen_resolution=$(grep "screen_resolution" $rrw_dir/rrw.conf | awk '{print $3}')
screen_refresh_rate=$(grep "screen_refresh_rate" $rrw_dir/rrw.conf | awk '{print $3}')

# Gather games from games.json
mapfile game_list < <(jq '.games[].name' $rrw_json | tr -d '"')

# Main loop
while true
do
	echo "[RRW] Looking for games"
		
	while [ $proc_flag -eq 0 ]
	do
		game_check
		sleep 2
	done

	echo "[RRW] Game $detected detected"

	rr_change 60

	echo "[RRW] Refresh rate changed"

	while pgrep -f "$detected" &>/dev/null 2>&1
	do
		sleep 2
	done

	echo "[RRW] Game $detected closed, reverting refresh rate"
	
	rr_change $screen_refresh_rate
	
	proc_flag=0
done
