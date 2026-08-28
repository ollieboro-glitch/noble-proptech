#!/usr/bin/env bash
# Builds the deployable dist/ folder from src/ + assets/.
#   ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

TOOL=tools/tailwindcss
if [ ! -x "$TOOL" ]; then
  echo "error: $TOOL not found — run ./setup.sh first" >&2
  exit 1
fi

rm -rf dist
mkdir -p dist/css dist/assets

# 1. Compile Tailwind (utilities + custom styles) from src/input.css
"$TOOL" -i src/input.css -o dist/css/tailwind.css --minify

# 2. Copy vendored assets
cp -R assets/fonts dist/assets/fonts
cp -R assets/js dist/assets/js

# 3. Emit dist/index.html with paths rebased from ../assets|../dist/css to the
#    flat dist/ layout. Set NOBLE_API_BASE for a separately hosted frontend;
#    same-origin API requests remain the default.
API_BASE="${NOBLE_API_BASE:-/api/v1}"
sed -e 's|\.\./dist/css/tailwind\.css|css/tailwind.css|g' \
    -e 's|\.\./assets/|assets/|g' \
    -e "s|__NOBLE_API_BASE__|${API_BASE}|g" \
    src/index.html > dist/index.html

echo "Build complete → dist/  ($(du -sh dist | cut -f1))"
