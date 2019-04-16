#!/bin/bash
#Xephyr -ac -screen 1280x800x24 -br -reset :20 -host-cursor & disown
#export DISPLAY=:20
#xmodmap $HOME/computer/programs/xmodmap/ace
# xkbset m
# xmodmap -e "keycode 134 = Pointer_Button1"
# xmodmap -e "keycode 108 = Pointer_Button3"
CMD="export WINEPREFIX=$HOME/.local/share/wineprefixes/aohd32"
cd $HOME/.local/share/wineprefixes/aohd32/drive_c/Program\ Files/Steam/SteamApps/common/Age2HD
CMD="$CMD;cd $HOME/.local/share/wineprefixes/aohd32/drive_c/Program\ Files/Steam/SteamApps/common/Age2HD"
exec 2>/dev/null
sudo umount -l Logs
sudo umount /dev/ram9
rm -rf Logs
mkdir Logs
sudo mkfs -f -q /dev/ram9 8192
sudo mount /dev/ram9 Logs
sudo chmod 777 Logs
#xrandr --output LVDS1 --mode 1280x800 --pos 0x0 --output HDMI1 --mode 1920x1080 --pos 1480x0
#XCreateMouseVoid 1280 0 202 1080 r
#XCreateMouseVoid 1080 0 410 1080 r &
#wine explorer /desktop=AOHD,1920x1080 "Launcher.exe" $@ &
#wait
#killall XCreateMouseVoid # because it's desktop mode, we should do this

# -Msync -SystemMemory -nostartup

# 1x1
# xrandr --output LVDS1 --scale 1x1
#wine explorer /desktop=AOHD,1280x800 "Launcher.exe" $@ &
# CMD="$CMD;xrandr --output LVDS1 --scale 1x1"
#CMD="$CMD;xrandr --output LVDS1 --scale 1.5x1.5"
# FASTVALIDATE NOMODS OLDSCHOOL DLC1_HIDDEN BASEGAME_HIDDEN
# CMD="$CMD;wine explorer /desktop=AOHD,1280x800 \"Launcher.exe\" $@"
cd ~/.local/share/wineprefixes/aohd32/drive_c/Program\ Files/Steam

export WINEPREFIX=$HOME/.local/share/wineprefixes/aohd32
# CMD="wine explorer /desktop=AOHD,1280x800 \"Steam.exe\" $@"

# wine explorer

CMD="$CMD;wine explorer /desktop=AOHD,2560x1600 \"Launcher.exe\" $@"

# CMD="$CMD;wine explorer /desktop=AOHD,1280x800 \"/export/bulk/local-home/smulliga/downloads/SteamSetup.exe\" $@"
#CMD="$CMD;wine start showcursor.vbs"
#CMD="$CMD;wine explorer /desktop=AOHD,1920x1080 \"Launcher.exe\" $@"
#CMD="$CMD;wine explorer /desktop=AOHD,1920x1200 \"Launcher.exe\" $@"
#CMD="$CMD;winecfg"
#CMD="$CMD;wine explorer /desktop=AOHD,800x1280 \"Launcher.exe\" $@"
#eval "TMUX= tmux neww -n aohd -t localhost_computer_programs \"bash --init-file <(echo \\\"set -m;$CMD\\\")\""
eval "$CMD"
# winecfg

## 1.5x1.5
#xrandr --output LVDS1 --scale 1.5x1.5
#wine explorer /desktop=AOHD,1920x1200 "Launcher.exe" $@ &

## 1.5x1.5 split
#xrandr --output LVDS1 --scale 1.5x1.5
#wine explorer /desktop=AOHD,1916x596 "Launcher.exe" $@ &

## 2x2
#xrandr --output LVDS1 --scale 2x2
##wine explorer /desktop=AOHD,1280x800 "Launcher.exe" $@ &
#CMD="$CMD;xrandr --output LVDS1 --scale 2x2"
##CMD="$CMD;wine explorer /desktop=AOHD,1280x800 \"Launcher.exe\" $@"
#CMD="$CMD;wine explorer /desktop=AOHD,1600x2560 \"Launcher.exe\" $@"
##eval "TMUX= tmux neww -n aohd -t localhost_computer_programs \"bash --init-file <(echo \\\"set -m;$CMD\\\")\""
#eval "$CMD"

## very laggy
## use xwininfo|less to find window dimennsions
## 2x2 split - works
#xrandr --output LVDS1 --scale 2x2
#wine explorer /desktop=AOHD,2556x796 "Launcher.exe" $@ &

#xrandr --output LVDS1 --scale 2x2
#wine explorer /desktop=AOHD,2560x1600 "Launcher.exe" $@ &
#wine explorer /desktop=AOHD,3840x2160 "Launcher.exe" $@ &
#xrandr --output LVDS1 --scale 3x3
#wine explorer /desktop=AOHD,3840x2400 "Launcher.exe" $@ &
#xrandr --output LVDS1 --scale 4x4
#wine explorer /desktop=AOHD,5120x3200 "Launcher.exe" $@ &
#xrandr --output LVDS1 --scale 5x5
#wine explorer /desktop=AOHD,6400x4000 "Launcher.exe" $@ &

#/usr/local/bin/wine Launcher.exe -window "$@" & disown
#until xprop -id `xdotool getwindowfocus`|grep "WM_NAME(STRING) = \"Age of Empires II: HD Edition\""; do
#    sleep 0.5
#done
#W=$(xdpyinfo  | grep 'dimensions:'|cut -d ' ' -f 7|cut -d 'x' -f 1)
#H=$(xdpyinfo  | grep 'dimensions:'|cut -d ' ' -f 7|cut -d 'x' -f 2)
#xdotool windowmove `xdotool getwindowfocus` -5 -23
#xdotool windowsize `xdotool getwindowfocus` $(( $W + 10 )) $(( $H +28 ))

# sudo renice -11 -p `pgrep wine|cut -d ' ' -f 1|xargs`
# sudo renice -11 -p `pgrep Launcher|cut -d ' ' -f 1|xargs`

#xkbset -m
#xmodmap computer/programs/xmodmap/ace

#wait
#xrandr --output LVDS1 --scale 1x1

# clean up after aohd developers
rm *.STEAMSTART
rm *.mdmp
sudo umount /dev/ram9