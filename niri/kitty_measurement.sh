#!/bin/bash
start=$(date +%s%3N)

echo $start

kitty --hold bash -c '
echo "Kitty visible at: $(date +%s%3N)"
read -n 1 -s -r -p "Press a key to close..."' &

# 1752435398748-1752435398988