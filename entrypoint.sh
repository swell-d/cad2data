#!/bin/sh
set -e

echo "Starting..."
exec micromamba run -n myenv gunicorn --workers=1 --bind 0.0.0.0:5001 server:app
