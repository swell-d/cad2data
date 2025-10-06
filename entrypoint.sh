#!/usr/bin/env bash
set -euo pipefail
IN_FILE="$1"
OUT_FILE="$2"
if [[ "${DEBUG:-0}" == "1" ]]; then export WINEDEBUG=+seh,+err; fi
Xvfb :0 -screen 0 1024x768x16 &
XVFB_PID=$!
trap 'kill "$XVFB_PID" 2>/dev/null || true; wait "$XVFB_PID" 2>/dev/null || true' EXIT INT TERM
export DISPLAY=:0
wineboot -u
wineserver -w
wine /cad2data/DDC_CONVERTER_Revit2IFC/RVT2IFCconverter.exe "$IN_FILE" "$OUT_FILE"
