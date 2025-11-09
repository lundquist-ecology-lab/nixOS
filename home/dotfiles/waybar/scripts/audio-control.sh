#!/bin/bash
# Save as ~/.config/waybar/scripts/audio-control.sh

# Function to handle volume changes
change_volume() {
    pactl set-sink-volume @DEFAULT_SINK@ "$1"
}

# Function to toggle mute
toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

# Function to get volume status
get_volume_status() {
    # Get volume and format for waybar
    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1)
    
    # Check if muted
    mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    
    # Get sink info for tooltip
    sink_name=$(pactl info | grep "Default Sink:" | awk '{print $3}')
    sink_desc=$(pactl list sinks | grep -A 1 "Name: $sink_name" | grep "Description" | sed 's/.*Description: //')
    
    if [ "$mute_status" = "yes" ]; then
        echo "{\"text\": \"󰝟 Muted\", \"class\": \"muted\", \"tooltip\": \"$sink_desc - Muted\"}"
    else
        echo "{\"text\": \" $volume\", \"tooltip\": \"$sink_desc - $volume\"}"
    fi
}

# Handle arguments
case "$1" in
    "up")
        change_volume "+5%"
        ;;
    "down")
        change_volume "-5%"
        ;;
    "mute")
        toggle_mute
        ;;
    "status")
        get_volume_status
        ;;
    *)
        # Monitor mode - continuously watch for changes
        get_volume_status
        pactl subscribe | grep --line-buffered "change" | while read -r line; do
            if [[ "$line" == *"sink"* ]]; then
                get_volume_status
            fi
        done
        ;;
esac
