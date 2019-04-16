#!/bin/bash
#amixer set Master 10+
#xset r rate 250 4

DEVID=1

exec >/dev/null
exec 2>/dev/null

getpavol()
{
    pactl list sinks | grep "Volume: 0:" | awk '{print $3}' | tr -d %
}

#sound="/home/shane/ws/age-of-kings/downloads/zelda/OOT_Get_Heart.wav"
sound="/home/shane/ws/ocarina-of-time-oot/sfx/OOT_Get_Rupee.wav"

#pulseaudio-ctl up
#pulseaudio-ctl up
amixer -c $DEVID set PCM 255
amixer -c $DEVID set Headphone 127
amixer -c $DEVID set Speaker 127
amixer -c $DEVID set "Bass Speaker" 127
amixer -c $DEVID set Headphone unmute
amixer -c $DEVID set Speaker unmute
amixer -c $DEVID set "Bass Speaker" unmute
#VOL="$(pulseaudio-ctl get)"
VOL="$(awk -F"[][]" '/dB/ { print $2 }' <(amixer -c $DEVID sget Master) | sed 's/.$//')"

if [ "$VOL" -ge 100 ]; then
    VOL="$(getpavol)"
fi

if [ "$VOL" -ge "100" ] && [ "$VOL" -lt "200" ]; then
    pactl set-sink-volume 0 $(( $VOL + 10 ))%
else
    amixer -c $DEVID set Master 10+
fi

if [ "$VOL" -ge "200" ]; then
    pactl set-sink-volume 0 200%
fi

if [ -z "$NOFEEDBACK" ]; then
    vlc --gain 0.1 --intf dummy --play-and-exit  "$sound"
fi

#if [ "$VOL" -gt "100" ]; then
    #play --rate 30k -v 0.02 "/home/shane/computer/beeps/button-7.wav"
    #play -v 0.05 "/home/shane/computer/beeps/button-7.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/computer/beeps/button-7.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/ws/age-of-kings/downloads/zelda/OOT_Get_Rupee.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/ws/age-of-kings/downloads/mario/smw_1-up.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/ws/age-of-kings/downloads/mario/f8b973_Super_Mario_Bros_Coin_Sound_Effect.mp3"
    #vlc --gain 0.1 --intf dummy --play-and-exit  "$sound"
#else

    #play -v 0.05 "/home/shane/computer/beeps/button-7.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/computer/beeps/button-7.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/ws/age-of-kings/downloads/zelda/OOT_Get_Rupee.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/ws/age-of-kings/downloads/mario/smw_1-up.wav"
    #vlc --gain 0.2 --intf dummy --play-and-exit  "/home/shane/ws/age-of-kings/downloads/mario/f8b973_Super_Mario_Bros_Coin_Sound_Effect.mp3"
#    vlc --gain 0.1 --intf dummy --play-and-exit  "$sound"
#fi

#play -v 0.5 "/home/shane/dj$(( ( RANDOM % 5 )  + 1 )).wav"

## 25% faster.
#(
#sleep 5
#xset r rate 187 6
#) &