#!/bin/bash

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

screen_output_name=$(grep "screen_output_name" $rrw_dir/rrw.conf | awk '{print $3}')
screen_resolution=$(grep "screen_resolution" $rrw_dir/rrw.conf | awk '{print $3}')
screen_refresh_rate=$(grep "screen_refresh_rate" $rrw_dir/rrw.conf | awk '{print $3}')

mapfile game_list < <(jq '.games[].name' $rrw_json | tr -d '"')

while true
do
	echo "[RRW] Looking for games"
	for game in ${game_list[@]}
	do
		if pgrep "$game" &> /dev/null 2>&1; then
			detected=$game
			proc_flag=1
			break
		fi
	done

	while [ $proc_flag -eq 0 ]
	do
		for game in ${game_list[@]}
		do
			if pgrep "$game" &> /dev/null 2>&1; then
				detected=$game
				proc_flag=1
				break
			fi
		done
		sleep 1
	done

	echo "[RRW] Game $detected detected"

	xrandr --output $screen_output_name --mode $screen_resolution --rate 60

	echo "[RRW] Refresh rate changed"

	if ! pgrep "$detected" &> /dev/null 2>&1; then
		proc_flag=0
	fi

	while [ $proc_flag -eq 1 ]
	do
		if ! pgrep "$detected" &> /dev/null 2>&1; then
			proc_flag=0
		fi
		sleep 1
	done

	echo "[RRW] Game $detected closed, reverting refresh rate"

	xrandr --output $screen_output_name --mode $screen_resolution --rate $screen_refresh_rate
done
