#!/bin/bash
used=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
cores=$(sysctl -n hw.ncpu)
total=$((cores * 100))
printf "%s/%s%%" "$used" "$total"
