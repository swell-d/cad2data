#!/usr/bin/env bash
set -euo pipefail
JOB_ID="$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)"
BASE_PREFIX="${BASE_WINEPREFIX:-/opt/wineprefix-template}"
export WINEARCH=win64
if [[ "${DEBUG:-0}" == "1" ]]; then export WINEDEBUG=+seh,+err; else export WINEDEBUG=-all; fi
export WINEPREFIX="/tmp/wineprefix-${JOB_ID}"
export XDG_RUNTIME_DIR="/tmp/xdg"
mkdir -p "$WINEPREFIX" "$XDG_RUNTIME_DIR"
if [[ -d "$BASE_PREFIX" && -f "$BASE_PREFIX/system.reg" ]]; then rsync -a --delete "$BASE_PREFIX"/ "$WINEPREFIX"/; fi
wineboot -u
trap 'wineserver -k || true; rm -rf "$WINEPREFIX"' EXIT INT TERM
xvfb-run -a -s "-screen 0 1024x768x16 -nolisten tcp" wine /cad2data/DDC_CONVERTER_Revit2IFC/DDC_REVIT2IFC_CONVERTER/RVT2IFCconverter.exe "$1" "$2"
wineserver -w
