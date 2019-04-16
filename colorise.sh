#!/bin/bash
export TTY

# hls uses a sed pattern
#Important

hls -i -b red -f black "definition is void" | \
hls -i -b red -f white important | \
hls -i -b blue -f white Flutes | \
hls -i -b dgrey -f white drum | \
hls -i -b camogreen -f white guitar | \
hls -i -b green -f white Trombone | \
hls -i -b purple -f white Tuba | \
hls -i -b red -f white Clarinets | \
hls -i -b purple -f white savetonight | \
hls -i -b green -f white "Mariah Carey" | \
hls -i -b red -f white christmas | \
hls -i -b yellow -f green "Big Mountain" | \
hls -i -b purple -f blue "drive" | \
hls -i -b orange -f yellow "higher" | \
hls -i -b blue -f white "Aqua" | \
hls -i -b pink -f white "barbie" | \
hls -i -b pink -f white "girl" | \
cat