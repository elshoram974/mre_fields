#!/bin/sh
# Rebuilds doc/images/*.gif from the example app.
#
# Needs Flutter, Node 22+, Python 3 with Pillow, and Google Chrome.
# Run from the package root:  sh tool/demo/make_gifs.sh
set -e

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
PORT=8765
export FRAMES_DIR="${FRAMES_DIR:-/tmp/mre_fields_frames}"

(cd example && flutter build web --release)
(cd example/build/web && python3 -m http.server "$PORT" >/dev/null 2>&1 &) 
"$CHROME" --headless=new --no-sandbox --remote-debugging-port=9333 \
  --use-angle=swiftshader --enable-unsafe-swiftshader \
  --user-data-dir="$FRAMES_DIR/profile" about:blank >/dev/null 2>&1 &
sleep 4

node tool/demo/record.mjs text "http://localhost:$PORT/?demo=text"
node tool/demo/record.mjs paste "http://localhost:$PORT/?demo=paste"
python3 tool/demo/build_gifs.py

pkill -f "http.server $PORT" || true
pkill -f "remote-debugging-port=9333" || true
