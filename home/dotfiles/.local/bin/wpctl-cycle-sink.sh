#!/bin/bash

# Get all available sinks
mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')

# Get current default sink
current_sink=$(pactl get-default-sink)

# Find current index
current_index=-1
for i in "${!sinks[@]}"; do
  if [[ "${sinks[$i]}" == "$current_sink" ]]; then
    current_index=$i
    break
  fi
done

# If current sink not found, default to first
if [[ $current_index -lt 0 ]]; then
  current_index=0
fi

# Calculate next index (cycle through)
next_index=$(( (current_index + 1) % ${#sinks[@]} ))
next_sink="${sinks[$next_index]}"

# Set the new default sink
pactl set-default-sink "$next_sink"

# Move all existing sink inputs to the new sink
pactl list short sink-inputs | awk '{print $1}' | while read -r stream_id; do
  pactl move-sink-input "$stream_id" "$next_sink" 2>/dev/null
done

# Get a friendly name for notification
sink_description=$(pactl list sinks | grep -A 20 "Name: $next_sink" | grep "Description:" | cut -d: -f2- | xargs)

# Send notification (silently fail if notification daemon not available)
notify-send "Audio Output" "$sink_description" 2>/dev/null || true
