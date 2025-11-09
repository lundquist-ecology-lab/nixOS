#!/bin/bash

# Get current brightness from the monitor
ddcutil --display 1 getvcp 10 2>/dev/null | grep -oP 'current value =\s+\K\d+' || echo "70"
