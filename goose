#!/bin/bash
cd $HOME/dump$HOME/notes2018/programs/dosbox
# -fullscreen
# dosbox -conf "configs/keen.conf" -c "mount c $HOME/dump$HOME/notes2018/programs/dosbox/c" -c C: -c "cd \KEENDREAMS" -c "mixer MASTER 20:20" -c "KDREAMS.EXE /JERK" -c "exit"
dosbox -conf "configs/keen.conf" -c "mount c $HOME/dump$HOME/notes2018/programs/dosbox/c" -c C: -c "cd \GOOSE" -c "mixer MASTER 20:20" -c "GOOSE.EXE" -c "exit"