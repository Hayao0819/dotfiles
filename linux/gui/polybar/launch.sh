#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do
    sleep 0.5
done

for bar in "left" "right"; do
    polybar -r "$bar" &
done

