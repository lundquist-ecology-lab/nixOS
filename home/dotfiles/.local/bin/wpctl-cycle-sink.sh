#!/usr/bin/env bash
set -euo pipefail

# Allow cycling either sinks (outputs) or sources (inputs)
node_type="${1:-sink}"
case "$node_type" in
  sink|source) ;;
  *) echo "Usage: $(basename "$0") [sink|source]" >&2; exit 1 ;;
esac

if [[ "$node_type" == "sink" ]]; then
  list_cmd=(pactl list short sinks)
  default_cmd=(pactl get-default-sink)
  set_cmd=(pactl set-default-sink)
  move_list_cmd=(pactl list short sink-inputs)
  move_cmd=(pactl move-sink-input)
  notify_title="Audio Output"
  description_section="sinks"
else
  list_cmd=(pactl list short sources)
  default_cmd=(pactl get-default-source)
  set_cmd=(pactl set-default-source)
  move_list_cmd=(pactl list short source-outputs)
  move_cmd=(pactl move-source-output)
  notify_title="Audio Input"
  description_section="sources"
fi

# Get all available nodes of the requested type
mapfile -t nodes < <("${list_cmd[@]}" | awk '{print $2}')
(( ${#nodes[@]} > 0 )) || exit 0

# Determine current default node
current_node="$("${default_cmd[@]}")"
current_index=-1
for i in "${!nodes[@]}"; do
  if [[ "${nodes[$i]}" == "$current_node" ]]; then
    current_index=$i
    break
  fi
done
(( current_index >= 0 )) || current_index=0

# Cycle to the next node
next_index=$(( (current_index + 1) % ${#nodes[@]} ))
next_node="${nodes[$next_index]}"

# Apply the new default
"${set_cmd[@]}" "$next_node"

# Move any live streams to the new node (if any exist)
while read -r stream_id; do
  [[ -z "$stream_id" ]] && continue
  "${move_cmd[@]}" "$stream_id" "$next_node" 2>/dev/null || true
done < <("${move_list_cmd[@]}" | awk '{print $1}')

# Extract a friendly description for notifications
node_description=$(
  pactl list "$description_section" \
    | awk -v name="$next_node" '
        $1 == "Name:" && $2 == name { show=1 }
        show && /Description:/ {
          sub(/^[[:space:]]*Description:[[:space:]]*/, "", $0);
          print;
          exit
        }'
)

# Send notification (silently fail if notification daemon not available)
notify-send "$notify_title" "${node_description:-$next_node}" 2>/dev/null || true
