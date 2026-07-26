#!/bin/sh

pane_path=$1
[ -z "$pane_path" ] && exit 0

cd "$pane_path" 2>/dev/null || exit 0

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
  branch=$(git rev-parse --short HEAD 2>/dev/null) ||
  exit 0

if git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  printf '#[fg=brightblack]%s#[default] #[fg=green]✓#[default]' "$branch"
else
  printf '#[fg=brightblack]%s#[default] #[fg=yellow]●#[default]' "$branch"
fi
