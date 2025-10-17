#!/usr/bin/env bash
set -euo pipefail
if [[ "${DEBUG:-0}" == "1" ]]; then export WINEDEBUG=+seh,+err; fi
wineboot -u
wineserver -w
xvfb-run -a -s "-screen 0 1024x768x16 -nolisten tcp" wine /cad2data/DDC_CONVERTER_Revit2IFC/DDC_REVIT2IFC_CONVERTER/RVT2IFCconverter.exe "$1" "$2"
