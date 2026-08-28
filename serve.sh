#!/bin/bash
# Build the frontend and run the Noble OS backend (WEBrick + SQLite).
# Usage: ./serve.sh [port]     (default 8712)
set -e
cd "$(dirname "$0")"

PORT="${1:-8712}"

./build.sh

if [ ! -f data/noble.db ]; then
  echo "First run — seeding demo landlord…"
  ruby backend/seed.rb
fi

SCHEME="http"
if [ "${NOBLE_TLS:-0}" = "1" ]; then SCHEME="https"; fi

echo
echo "  Noble PropTech is live at  ${SCHEME}://${HOST:-127.0.0.1}:${PORT}"
echo "  Demo account:              demo@noble.co.uk  /  noble-demo"
echo "  (or create your own account from the Log In modal)"
echo
echo "  Press Ctrl-C to stop."
echo
ruby backend/server.rb "${PORT}"
