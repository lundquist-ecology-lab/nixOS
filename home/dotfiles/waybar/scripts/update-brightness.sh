#!/bin/bash

# Path to the main brightness script
BRIGHTNESS_SCRIPT="$HOME/.config/waybar/scripts/brightness.sh"

# Make sure the script exists and is executable
if [ ! -x "$BRIGHTNESS_SCRIPT" ]; then
    echo "Error: $BRIGHTNESS_SCRIPT not found or not executable"
    exit 1
fi

# Process the command
case $1 in
    up)
        # Get current brightness
        current=$($BRIGHTNESS_SCRIPT)
        
        # Increase by 5
        new=$((current + 5))
        if [ $new -gt 100 ]; then
            new=100
        fi
        
        # Set new brightness
        ddcutil --display 1 setvcp 10 $new >/dev/null 2>&1
        ;;
    down)
        # Get current brightness
        current=$($BRIGHTNESS_SCRIPT)
        
        # Decrease by 5
        new=$((current - 5))
        if [ $new -lt 0 ]; then
            new=0
        fi
        
        # Set new brightness
        ddcutil --display 1 setvcp 10 $new >/dev/null 2>&1
        ;;
    set)
        # Set specific brightness
        ddcutil --display 1 setvcp 10 $2 >/dev/null 2>&1
        ;;
    *)
        echo "Usage: $0 {up|down|set VALUE}"
        exit 1
        ;;
esac

# Notify Waybar to update (optionally)
pkill -RTMIN+8 waybar

# Always exit cleanly
exit 0
