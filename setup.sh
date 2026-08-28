#!/usr/bin/env bash
# One-time setup: vendors the Tailwind standalone binary, lucide, jsPDF, and
# the Inter / JetBrains Mono fonts. Re-run to refresh/repair.
#
# NOTE: the Tailwind binary below is for macOS ARM64 (Apple Silicon). On other
# machines pick the matching asset from the v3.4.17 release, e.g.
#   tailwindcss-macos-x64  |  tailwindcss-linux-x64  |  tailwindcss-windows-x64.exe
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p tools assets/fonts assets/js

if [ ! -x tools/tailwindcss ]; then
  echo "Downloading Tailwind CLI v3.4.17 (standalone, macOS ARM64)..."
  curl -sL https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-macos-arm64 -o tools/tailwindcss
  chmod +x tools/tailwindcss
fi

if [ ! -s assets/js/lucide.min.js ]; then
  echo "Downloading lucide 1.33.0..."
  curl -sL https://unpkg.com/lucide@1.33.0/dist/umd/lucide.min.js -o assets/js/lucide.min.js
fi

if [ ! -s assets/js/jspdf.umd.min.js ]; then
  echo "Downloading jsPDF 2.5.1..."
  curl -sL https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js -o assets/js/jspdf.umd.min.js
fi

if [ ! -s assets/fonts/fonts.css ]; then
  echo "Vendoring Inter + JetBrains Mono fonts..."
  perl tools/gen-fonts.pl
fi

echo "Setup complete — run ./build.sh"
