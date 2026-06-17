#!/usr/bin/env bash
# MTSE workspace setup
# Clones (or pulls) the four sub-repositories that make up the MTSE platform.
#
# Usage:
#   1. Clone the root repo once:  git clone https://github.com/Ramkrishna2558/mtse.git
#   2. cd into it and run:         ./setup.sh
#
# Re-running is safe: existing repos are updated with `git pull`, missing ones are cloned.

set -euo pipefail

# format: "url|path|branch"
repos=(
  "https://github.com/Ramkrishna2558/mtse-backend.git|mtse-backend/beplayground|feature/config-driven-demo"
  "https://github.com/Ramkrishna2558/mtse-frontend-admin.git|mtse-frontend-admin|feature/mvp"
  "https://github.com/Ramkrishna2558/mtse-frontend-store.git|mtse-frontend-store|feature-footer-redesign"
  "https://github.com/Ramkrishna2558/mtse-shared.git|mtse-shared|feature/mvc"
)

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for entry in "${repos[@]}"; do
  IFS='|' read -r url path branch <<< "$entry"
  target="$root/$path"

  if [ -d "$target/.git" ]; then
    echo "==> Updating $path ($branch)"
    git -C "$target" fetch origin
    git -C "$target" checkout "$branch"
    git -C "$target" pull origin "$branch"
  else
    echo "==> Cloning $url -> $path ($branch)"
    mkdir -p "$(dirname "$target")"
    git clone --branch "$branch" "$url" "$target"
  fi
done

echo ""
echo "All repositories are in place."
echo "Next: run 'npm run install:all' to install dependencies, then 'npm start'."
