#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do
    sleep 0.5
done

BARNAME="main"

for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    #echo "Starting top bar on monitor '$monitor'"
    #MONITOR="$monitor" polybar top &
    #echo "Starting bottom bar on monitor '$monitor'"
    MONITOR="$monitor" polybar "$BARNAME" &
done

