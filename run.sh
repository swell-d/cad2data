#!/usr/bin/env bash
set -euo pipefail
JOB_ID="$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)"
BASE_PREFIX="${BASE_WINEPREFIX:-/opt/wineprefix-template}"
export WINEARCH=win64
if [[ "${DEBUG:-0}" == "1" ]]; then export WINEDEBUG=+seh,+file,+err; else export WINEDEBUG=-all; fi
export WINEPREFIX="/tmp/wineprefix-${JOB_ID}"
mkdir -p "$WINEPREFIX"
if [[ -d "$BASE_PREFIX" && -f "$BASE_PREFIX/system.reg" ]]; then rsync -a --delete "$BASE_PREFIX"/ "$WINEPREFIX"/; fi
if [[ ! -e "${1:-}" ]]; then echo "input missing: $1" >&2; exit 66; fi
if [[ -z "${2:-}" ]]; then echo "output missing: $2" >&2; exit 66; fi
if [[ ! -r "$1" ]]; then echo "input not readable: $1" >&2; exit 66; fi
OUTDIR="$(dirname -- "$2")"
mkdir -p "$OUTDIR" "$XDG_RUNTIME_DIR"
if [[ ! -w "$OUTDIR" ]]; then echo "output dir not writable: $OUTDIR" >&2; exit 73; fi
IN_WIN="$(winepath -w "$1")"
OUT_WIN="$(winepath -w "$2")"
wineboot -u
trap 'wineserver -k || true; rm -rf "$WINEPREFIX"' EXIT INT TERM
xvfb-run -a -s "-screen 0 1024x768x16 -nolisten tcp" wine /cad2data/DDC_CONVERTER_Revit2IFC/DDC_REVIT2IFC_CONVERTER/RVT2IFCconverter.exe "$IN_WIN" "$OUT_WIN"
wineserver -w
