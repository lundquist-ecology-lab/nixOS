#!/bin/bash
# Save as ~/.config/hypr/scripts/screenlock.sh and make executable with chmod +x

# Lock screen
hyprlock &
HYPRLOCK_PID=$!

# Wait a second and turn off display
sleep 1
hyprctl dispatch dpms off

# Wait for hyprlock to exit (when successfully unlocked)
wait $HYPRLOCK_PID

# Make sure screen stays on after unlock
sleep 0.5
hyprctl dispatch dpms on
