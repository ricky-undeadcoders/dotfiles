#!/bin/bash
pagesize=$(vm_stat | head -1 | grep -o '[0-9]*')
free=$(vm_stat | awk '/Pages free/ {print $NF+0}')
total_bytes=$(sysctl -n hw.memsize)
total_pages=$((total_bytes / pagesize))
used_pages=$((total_pages - free))
used_gb=$(echo "$used_pages * $pagesize / 1024 / 1024 / 1024" | bc -l)
total_gb=$(echo "$total_bytes / 1024 / 1024 / 1024" | bc -l)
printf "%.1f/%.0fG" "$used_gb" "$total_gb"
