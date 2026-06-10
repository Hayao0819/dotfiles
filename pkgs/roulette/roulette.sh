#!/usr/bin/env bash
set -e

[[ $(( RANDOM % 6 )) == 0 ]] && sudo shutdown now || echo '*Click* ... Lucky... '
