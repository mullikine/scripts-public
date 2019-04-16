#!/usr/bin/env bash

NOTMUX=y
NOEMACS=y
while [ $# -gt 0 ]; do opt="$1"; case "$opt" in
    -ntm) {
        NOTMUX=y
        shift
    }
    ;;

    -nem) {
        NOEMACS=y
        shift
    }
    ;;

    *) break;
esac; done

export DISPLAY=:0

cd "$HOME"

# This makes vim's text slightly closer to what it was at Crown.
# However, it also makes the colors flurorescent, which I don't like
# xgamma -gamma 1

hn="$(hostname)"

case "$hn" in
    instance-1|ip-*) {
        xpra start :0
    }
    ;;

    *)
esac

if test "$(hostname)" = "morgan"; then
    op performance
    sudo cpufreq-set -g performance `# agi linux-tools-4.13.0-37-generic`
fi

source ~/.shell_environment

# Enable job management
set -m

# feh --bg-max "$DUMP$HOME/notes2018/ws/codelingo/photos/24ce7df003c56c7dacd3da9ea862bbdf.png"
# feh --bg-fill /usr/share/backgrounds/warty-final-ubuntu.png
# feh --bg-fill "$HOME/dump$HOME/notes2018/ws/wallpapers/pink-stars-wallpaper.jpg"
# feh --bg-fill "$HOME/notes2018/ws/wallpapers/50720436_10156675871925211_2514930495448416256_o.jpg"
# feh --bg-fill "$DUMP$HOME/notes2018/ws/wallpapers/fantasia5.jpg"
# feh --bg-fill "$HOME/notes2018/ws/wallpapers/1485753648.atariboy_iheart_animaniacs_-_final.jpg"
# feh --bg-tile $HOME/notes2018/ws/wallpapers/0001438_rainbow-llama-cat-llama.jpeg
# feh --bg-fill "$HOME/dump$HOME/notes2018/ws/wallpapers/moon-nn-zoo.png"
feh --bg-max "$DUMP$HOME/notes2018/ws/deep-learning/infographics/deeplearning_overview_9_inverted.jpg"
# feh --bg-fill "$DUMP$HOME/notes2018/ws/wallpapers/lunareclipse_27Sep_beletsky.jpg"
# feh --bg-max "$DUMP$HOME/notes2018/ws/wallpapers/lunareclipse_27Sep_beletsky.jpg"
# feh --bg-max "$HOME/dump$HOME/notes2018/ws/math/math-inv.jpg"
# feh --bg-fill "$DUMP$HOME/notes2018/ws/wallpapers/lotr.jpg"
# feh --bg-fill "$HOME/dump$HOME/notes2018/ws/dreams/koru-moon.png"
# feh --bg-fill "$HOME/dump$HOME/notes2018/ws/wallpapers/ootocarina_1280.jpg"
# feh --bg-fill "$HOME/dump$HOME/notes2018/ws/photography/29136666_444121999380296_2479988797601742848_o.jpg"
# feh --bg-fill "$HOME/dump$HOME/notes2018/ws/wallpapers/TeQkmqV.png"
# feh --bg-max "$DUMP$HOME/notes2018/ws/wallpapers/classify-ai-algorithms-infographic-inv.jpg"

# feh --bg-fill $HOME/dump$HOME/notes2018/ws/wallpapers/ElEDt.jpg

xrdb -merge ~/.Xresources && xrdb -load ~/.Xresources

# If I am using plain sh then compton & will automatically disown at the
# end of the script. No need to set -m and place disown.

# Compton is too slow
# $HOME/scripts/compton & disown

setxkbmap -option altwin:swap_lalt_lwin

# this did the job
xmodmap "$HOME/source/git/config/Xmodmap"

# # But this made the left ctrl into an alt key
# # Which is needed for pentadactyl
# # C-A-b toggles the reading mode
# # But it also introduces Shift-CapsLock for capslock
# xmodmap "$HOME/.Xmodmap"

# DISCARD Using this, it's makes left ctrl the hyper key (which does not
# work in the terminal). It also make S-Caps lock into Capslock, as
# capslock is taken by control:
# xmodmap "$HOME/.Xmodmap"

# xmodmap -e "keycode 64 = Super_L NoSymbol Super_L"
# xmodmap -e "keycode 133 = Alt_L Meta_L Alt_L Meta_L"


xset r rate 200 5


{
    # [[http://shallowsky.com/blog/tags/trackpad/]]
    # Set mouse keys

    xmodmap -e "keysym Super_R = Pointer_Button1"
    #xmodmap -e "keysym Alt_R = Pointer_Button2" # Middle button (i should assign this)
    xmodmap -e "keysym Alt_R = Pointer_Button3"

    #xmodmap -e "keysym Pointer_Button2 = Pointer_Button3" # Change
    xkbset m;
    xkbset exp =mousekeys
}


# # Reload the hid_apple kernel module without rebooting
# sudo rmmod hid_apple && sudo modprobe hid_apple


# # Start emacs first so tmux will appear last
# # Only start if emacs is not running.
# if ! pgrep emacs; then
#     e x
#     ( xt tm ns overview $NOTES/scratch "e\ $NOTES/scratch/overview.org" ) & disown
# fi


(
cd $HOME/notes2018/ws/python/shanepy
make
) &>/dev/null

# vim +/", ((modm,               xK_u     ), spawn \"win xterm-tmux\")" "$HOME/.xmonad/xmonad.hs"
# vim +/"tm start" "$HOME/scripts/win"

# Don't start 2 org mode servers at the same time
# tm -d nw -d -n neuralnetworks "project neuralnetworks"

# ( xt tm ns overview $NOTES/scratch "ec\ $NOTES/scratch/overview.org" ) & disown


op clipboard-restart

case "$hn" in
    morgan) {
        fix-internet.sh & disown
    }
    ;;

    *)
esac

# It's getting called above when it does an xdotool K_u
# It's getting called somewhere else but I don't know where. I can use
# sphinx once it's set up.

# tm start # I can put this here but I cannot put new window creation into start


tmux new -d -c "$HOME" -s init zsh

# tmux new -d -c "$NOTES" -s localhost
# "CWD=$(aqf "$NOTES") zsh"

xdotool keydown Super_L && \
    ` # commented out: sleep 0.1 && xdotool key Return && ` \
    sleep 0.1 && xdotool key b && \
    sleep 0.1 && xdotool key b && \
    sleep 0.1 && xdotool keyup Super_L

# if pgrep xterm; then
#     # Fix xmobar
#     xdotool keydown Super_L && \
#         ` # commented out: sleep 0.1 && xdotool key Return && ` \
#         sleep 0.1 && xdotool key b && \
#         sleep 0.1 && xdotool key b && \
#         sleep 0.1 && xdotool keyup Super_L
# else
#     # This no longer runs tm start. Which means I manually must do tm
#     # start before this
# 
#     # This is what starts emacs. I don't want this to be the way.
#     # Instead, start manually
# 
#     # Fix xmobar and start an xterm
#     xdotool keydown Super_L && \
#         sleep 0.1 && xdotool key u && \
#         sleep 0.1 && xdotool key b && \
#         sleep 0.1 && xdotool key b && \
#         sleep 0.1 && xdotool keyup Super_L
# fi

# Can't do this because when I recopile xmonad it will not like it
# As it turns out, the first window actually remains if I manually run
# tm init from a tmux terminal
#FORCE=y tm init

if test "$(hostname)" = "morgan"; then
    (
        chrome "https://codelingo.slack.com/messages/GCMBY9E23/" &
        sleep 1
        chrome "https://github.com/codelingo/lingo/" &
        chrome "https://trello.com/b/4nxD8DHU/alpha-sprint" &
        wait
    ) &
fi

# What is this?
go docs

if test "$(hostname)" = "morgan"; then
    # GC instance-1 does not have 'service', let alone tor
    /usr/bin/service tor restart # starts on 9050 # Tor browser used to start on 9150
fi

( unbuffer watch killall epdfinfo ) &>/dev/null &

if ! test "$NOEMACS" = "y"; then
    notify-send "Starting emacs"
    unbuffer e -startall
fi

if ! test "$NOTMUX" = "y"; then
    notify-send "Starting tmux"
    # tclsh hangs terribly
    # ubd tm init
    tm init
fi

ce mount libertyprime-transcription
# ce mount multi-public
ce mount sea-cold
ce mount sea-near

# update things -- disabled temporarily
# $HOME/notes2018/update.sh

# this stops the kidle_inject process from spawning
# sudo rmmod intel_powerclamp
# DONE Make it permanent
# sudo bash -c "echo $(aqf "blacklist intel_powerclamp") > /etc/modprobe.d/disable-powerclamp.conf"

case "$hn" in
    morgan) {
        # Run this to give the correct permissions for the default ramdisk
        # Otherwise vim can't use the backupdir.
        # :se backup? backupdir? backupext?
        sudo chown -R shane:shane /dev/shm/var/tmp/shane
    }
    ;;

    *)
esac
