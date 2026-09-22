#!/usr/bin/env bash
# Clone every ChessBoard repo listed in repos.txt next to this script.
# Idempotent: a repo that already exists is left untouched (no pull).
# A repo you cannot access (private) is reported and skipped.
# Usage: ./clone-all.sh [--ssh]
set -uo pipefail
cd "$(dirname "$0")"

base="https://github.com/artfern95"
[ "${1:-}" = "--ssh" ] && base="git@github.com:artfern95"

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  set -- $line
  [ $# -eq 0 ] && continue
  name="$1"; dir="${2:-$1}"
  if [ -d "$dir/.git" ]; then
    echo "skip  $dir (already cloned)"
  elif git clone --quiet "$base/$name.git" "$dir" 2>/dev/null; then
    echo "clone $name -> $dir"
  else
    echo "fail  $name (no access or does not exist), skipped"
  fi
done < repos.txt
