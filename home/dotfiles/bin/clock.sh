#!/usr/bin/env bash

COLOR="\e[38;2;140;151;125m"
RESET="\e[0m"

# Hide cursor while the clock runs
tput civis

# Draws the figlet clock centered in the terminal
function draw_clock() {
    local new_width new_height
    new_width=$(tput cols)
    new_height=$(tput lines)

    if [[ "$new_width" -ne "${width:-0}" || "$new_height" -ne "${height:-0}" ]]; then
        width=$new_width
        height=$new_height
        tput clear
    fi

    local top_offset
    top_offset=$(( (height - $(echo "$time_str" | wc -l)) / 2 ))
    tput cup "$top_offset" 0

    while IFS= read -r line; do
        printf "%b%*s%b\n" "$COLOR" $(((width + ${#line}) / 2)) "$line" "$RESET"
    done <<<"$time_str"
}

cleanup() {
    tput cnorm
    exit
}
trap cleanup EXIT
trap draw_clock SIGWINCH

width=$(tput cols)
height=$(tput lines)

while true; do
    time_str=$(date +"%I : %M %p" | figlet)
    draw_clock
    sleep 1
done
