#!/bin/bash
#amixer set Master 10-
#xset r rate 250 4

# sed 's/-c 0/-c \$DEVID/g'

DEVID=1

exec >/dev/null
exec 2>/dev/null

getpavol()
{
    pactl list sinks | grep "Volume: 0:" | awk '{print $3}' | tr -d %
}

#pulseaudio-ctl down
#pulseaudio-ctl down
amixer -c $DEVID set PCM 100%
amixer -c $DEVID set Headphone 100%
amixer -c $DEVID set Speaker 100%
amixer -c $DEVID set "Bass Speaker" 100%
amixer -c $DEVID set Headphone unmute
amixer -c $DEVID set Speaker unmute
amixer -c $DEVID set "Bass Speaker" unmute
#VOL="$(pulseaudio-ctl get)"
VOL="$(awk -F"[][]" '/dB/ { print $2 }' <(amixer -c $DEVID sget Master) | sed 's/.$//')"
echo "$VOL" >> /tmp/vol.txt

#if [ "$VOL" -ge 100 ]; then
#    VOL="$(getpavol)"
#fi

if [ "$VOL" -ge "105" ]; then
    pactl set-sink-volume 0 $(( $VOL - 10 ))%
else
    amixer -c $DEVID set Master 10-
fi

if [ -z "$NOFEEDBACK" ]; then
    a beep
fi