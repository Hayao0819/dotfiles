#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do
    sleep 0.5
done

polybar top &

