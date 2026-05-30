#!/usr/bin/env bash
# Regenerate the social-share card (img/og-card.jpg, 1200x630).
#
# Edit tools/og-card.html to change the text/layout, then run this script.
# The portrait (../img/portrait.jpg) is converted to grayscale by CSS in the
# template, so you don't need a separate gray image file.
#
# Requirements (install via Homebrew):
#   - Google Chrome   (renders the HTML, loads the IBM Plex Mono webfont)
#   - imagemagick      brew install imagemagick   (downscales 2x -> 1200x630)
#
# After running, redeploy the site and re-scrape the URL in the Facebook
# Sharing Debugger to refresh cached previews:
#   https://developers.facebook.com/tools/debug/
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HTML="$ROOT/tools/og-card.html"
OUT="$ROOT/img/og-card.jpg"
TMP="$(mktemp -t ogcard).png"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || CHROME="$(command -v google-chrome || command -v chromium || true)"
[ -n "$CHROME" ] || { echo "Google Chrome not found" >&2; exit 1; }

# Render at 2x for crisp text, then downscale to the exact OG dimensions.
"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1200,630 \
  --virtual-time-budget=4000 \
  --screenshot="$TMP" "file://$HTML"

magick "$TMP" -resize 1200x630 -quality 90 "$OUT"
rm -f "$TMP"

echo "Wrote $OUT"
