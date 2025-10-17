#!/usr/bin/env bash
set -euo pipefail
if [[ "${DEBUG:-0}" == "1" ]]; then export WINEDEBUG=+seh,+err; fi

JOB_ID="$(cat /proc/sys/kernel/random/uuid)"
export WINEPREFIX="/tmp/${JOB_ID}"
echo "WINEPREFIX=$WINEPREFIX"
mkdir -p "$WINEPREFIX"
echo "WINEPREFIX created"
rsync -a --delete "${BASE_WINEPREFIX}/" "$WINEPREFIX"

wineboot -u
trap 'wineserver -k || true; rm -rf "$WINEPREFIX"' EXIT INT TERM
xvfb-run -a -s "-screen 0 1024x768x16 -nolisten tcp" wine /cad2data/DDC_CONVERTER_Revit2IFC/DDC_REVIT2IFC_CONVERTER/RVT2IFCconverter.exe "$1" "$2"
wineserver -w
