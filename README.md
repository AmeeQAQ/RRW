<div align="center">
<h1>Refresh Rate Watcher</h1>
<h3>A Linux script that monitors a set of user-defined games and automatically adjusts the screen's refresh rate if one of them is launched</h3>
</div>

<br>

Some games have their FPS capped to a certain value, usually 60, due to technical limitations in the physics engine. Running these games with a screen that outputs more than 60 Hz can be an awful experience, where those 60 FPS can feel like 40 or even 30 due to them being lower than your native refresh rate. This script aims to automate the process of changing it to smoothen the overall gaming experience.

## ...why?
Elden Ring's DLC Shadow of the Erdtree launched very recently and it's been a while since I last played ER. After booting it and solving the DLC problem in the most Linux way (creating an empty file inside ER's directory), the game felt very sluggish and definitely not smooth. That's when I remembered almost all FromSoft games are FPS locked due to their engine's physics, and I'm playing on a 75 Hz monitor. Tried setting up some launch options for the game to execute xrandr and change the monitor's refresh rate at launch and exit, but for some reason it wouldn't start. So, since I'm in summer break from university, I decided to build something of my own.

## Dependencies
For this tool to work, you will need to have `xrandr` (for X11 sessions) and the command-line tool `jq`, which is the JSON parser used by the script.

For Wayland sessions, see [Wayland support](#wayland-support)

## Setup
So far, this piece of software has been tested only in my machine running Arch Linux 6.9.7.

This repository contains two main scripts: `rrw.sh` and `rrw-jsongen.sh`.
- `rrw.sh` is the tool itself.
- `rrw-jsongen.sh` is the JSON generator utility for RRW that it will parse to extract process names and, in the future, custom refresh rates for each title, with the default being 60.

To download this tool, simply clone this repository in your directory of choice via:
```
$ git clone https://github.com/AmeeQAQ/RRW.git
```

Once cloned, cd into said directory and execute, with `sudo`, the script called `install.sh`:
```
$ sudo bash install.sh
```

This script will install anything that RRW needs to work. By default, it copies `rrw.sh` and `rrw-jsongen.sh` into `/usr/local/bin/`. You can modify this location if needed (for example `~/bin/`), but I recommend that one because it's the standard for custom scripts and executables. Besides that, it also creates a new folder in `~/.config/` called `rrw`, where config files such as `games.json` and `rrw.conf` will be stored.
- `games.json` is the JSON file generated by `rrw-jsongen`. After installation, you will be asked to run this utility and add all the games you need to keep track of.
- `rrw.conf` contains necessary information about your system. It is VERY important to modify this file and write the values you need for your own personal case. In particular, you need to know which one is your main display (or the one you use for games), resolution and the refresh rate you usually use it with. Those parameters go into the three variables stored in this config file. If you skip this step, the script won't work.
All of this info is easily accessible using `xrandr --prop`.

Once the installation is done, you'll need to run `rrw-jsongen`, where you'll need to pass the process' names of the games you want to keep track of as parameters of this command. An example of usage would be this one:
```
$ rrw-jsongen foo bar eldenring
```

That example would output the following JSON:
```json
{"games":[{"name":"foo"},{"name":"bar"},{"name":"eldenring"}]}
```

Once this is done, you can run RRW by simply running `rrw`:
```
$ rrw
```

### Convert RRW into a service unit
Systemd allows the definition of user units to transform scripts, programs or simple commands into background services. This is a very interesting feature for this tool, and for that purpose, in `/resources` there's an example of a functional RRW user unit. If this sounds like something you want, the script `service_installer.sh` will install and enable that unit. It must be run as a normal user:
```
$ bash service_installer.sh
```

Needless to say, you are free to add and remove anything you want or need to better suit your own needs. This is a script I did to fix my own problem and I'm sharing it because I think it could be useful to others, be it as it is or as your own modified version. This is open and free software.

## Wayland support
Depending on the desktop enviroment you are using, the wayland compositor might be one or the other. While in X11 `xrandr` works for any DE, in Wayland this is different, and every DE or WM has its own compositor or uses [wlroots](https://gitlab.freedesktop.org/wlroots/wlroots). I expect wlroots to be the most used library, which allows for `wlr-randr` to be the main dependency/tool for most environments, while having the possibility of accomodating the script for other specific tools provided by the DEs, like `kscreen-doctor`, or community-driven ones like `gnome-randr-rust`.

Nevertheless, as more DEs start adopting Wayland as their main display server, or offer some solid support for it, I'll be filling up this list with the added dependencies for Wayland sessions:
- KDE: `kscreen-doctor`
- Gnome: [gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)
- wlroots compositors (Hyprland, sway,...): [wlr-randr](https://sr.ht/~emersion/wlr-randr/)

## Known limitations/future upgrades
This package is functional but still early in development. Thus, compatibility errors and unexpected bugs may come up the more the package is used. For now, some of its limitations are:
- ~No Wayland support (script uses xrandr for screen mngmnt).~ See [Wayland support](#wayland-support)
- ~Refresh rate only gets lowered to 60.~ Most monitors can't go lower than 60 Hz, and if they can, it probably doesn't matter for games that are locked at 30 FPS, which would be the other use case for this script.
- Untested with multiple displays.

All of them will, hopefully, be addressed in the near future.

Some planned upgrades are:
- [ ] Online/offline game database to map game name to process name (would be used by games.json).
