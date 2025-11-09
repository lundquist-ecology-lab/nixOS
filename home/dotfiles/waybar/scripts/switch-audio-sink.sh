#!/bin/bash

# Get the current default sink
current_sink=$(pactl get-default-sink)

# Get list of all sinks
sinks=($(pactl list short sinks | awk '{print $2}'))

# Find current sink index
current_index=-1
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current_sink" ]]; then
        current_index=$i
        break
    fi
done

# Calculate next sink index (circular)
next_index=$(( (current_index + 1) % ${#sinks[@]} ))

# Set the next sink as default
pactl set-default-sink "${sinks[$next_index]}"

# Move all playing streams to the new sink
for app in $(pactl list short sink-inputs | cut -f1); do
    pactl move-sink-input "$app" "${sinks[$next_index]}"
done

# Optional: Show notification of the new sink
sink_name=$(pactl list sinks | grep -A 1 "Name: ${sinks[$next_index]}" | grep "Description" | sed 's/.*Description: //')
notify-send "Audio Output" "Switched to: $sink_name" -i audio-speakers

exit 0
