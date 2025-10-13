#!/usr/bin/env bash
set -euo pipefail
IN_FILE="$1"
OUT_FILE="$2"
if [[ "${DEBUG:-0}" == "1" ]]; then export WINEDEBUG=+seh,+err; fi
wineboot -u
wineserver -w
xvfb-run -a -s "-screen 0 1024x768x16 -nolisten tcp" wine /cad2data/DDC_CONVERTER_Revit2IFC/RVT2IFCconverter.exe "$IN_FILE" "$OUT_FILE"
