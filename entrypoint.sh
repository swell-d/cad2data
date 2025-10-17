#!/bin/sh
set -e

echo "Starting..."
mkdir -p "$WINEPREFIX"
mkdir -p "$XDG_RUNTIME_DIR"
xvfb-run -a -s "-screen 0 1024x768x16 -nolisten tcp" wineboot -u && wineserver -w
echo "Wine loaded. Starting gunicorn..."
exec micromamba run -n myenv gunicorn --workers=1 --bind 0.0.0.0:5001 server:app
