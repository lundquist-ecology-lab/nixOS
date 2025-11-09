#!/bin/bash
# Save as ~/.config/waybar/scripts/audio-monitor.sh

# Wait for changes to audio devices
pactl subscribe | grep --line-buffered "change" | while read -r line; do
    if [[ "$line" == *"sink"* ]]; then
        # Send SIGUSR2 signal to waybar to force a refresh
        killall -SIGUSR2 waybar
    fi
done
