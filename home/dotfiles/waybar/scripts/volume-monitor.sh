#!/bin/bash
# Save as ~/.config/waybar/scripts/volume-monitor.sh

# Function to get info from the default sink
get_volume_info() {
    sink_info=$(pactl get-sink-volume @DEFAULT_SINK@)
    mute_info=$(pactl get-sink-mute @DEFAULT_SINK@)
    sink_name=$(pactl info | grep "Default Sink:" | awk '{print $3}')
    sink_desc=$(pactl list sinks | grep -A 1 "Name: $sink_name" | grep "Description" | sed 's/.*Description: //')
    
    # Extract volume percentage
    volume=$(echo "$sink_info" | grep -o '[0-9]*%' | head -1)
    
    # Check if muted
    if [[ "$mute_info" == *"yes"* ]]; then
        muted=true
    else
        muted=false
    fi
    
    # Format for waybar
    if [ "$muted" = true ]; then
        echo "{\"text\": \"󰝟 Muted\", \"alt\": \"muted\", \"tooltip\": \"$sink_desc - Muted\", \"class\": \"muted\"}"
    else
        echo "{\"text\": \" $volume\", \"alt\": \"$volume\", \"tooltip\": \"$sink_desc - $volume\", \"class\": \"\"}"
    fi
}

# Output volume info once
get_volume_info

# Watch for changes to audio devices or volume
pactl subscribe | grep --line-buffered "change" | while read -r line; do
    if [[ "$line" == *"sink"* ]]; then
        get_volume_info
    fi
done
