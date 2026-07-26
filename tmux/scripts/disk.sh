#!/bin/sh

pct=$(df -P | awk '
  $1 ~ /^\/dev\// && $6 !~ /^\/boot/ {
    sub("%", "", $5)
    if ($5+0 > max) max = $5+0
  }
  END { print max+0 }
')

if [ "$pct" -ge 80 ]; then
  color="#[fg=red]"
elif [ "$pct" -ge 50 ]; then
  color="#[fg=yellow]"
else
  color="#[fg=green]"
fi

printf 'DISK %s%d%%#[default]' "$color" "$pct"
