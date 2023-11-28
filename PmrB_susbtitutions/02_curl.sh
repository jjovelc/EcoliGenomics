#!/usr/bin/bash

awk '{for (i=2; i<=NF; i++) printf $i " "; print ""}' curl_commands.txt | while read -r CMD; do eval "$CMD"; done
