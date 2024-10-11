#!/usr/bin/env bash

if [ -z "$1" ]; then
	figlet -f slant "No args?"
	exit 1
fi

# Search for the argument
figlet -f slant $1

# Here goes best one
xdg-open "https://youtu.be/mco3UX9SqDA"
