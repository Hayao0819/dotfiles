#!/usr/bin/env bash

if [ -z "$1" ]; then
	figlet -f slant "No args?"
	exit 1
fi

# Search for the argument
figlet -f slant "$1"

if [[ "$(uname)" == "Linux" && -f /etc/nixos/configuration.nix ]]; then
  alias open="xdg-open"
fi

# Here goes best one
# xdg-open "https://youtu.be/mco3UX9SqDA"
open "https://youtu.be/51GIxXFKbzk"
