#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf '%s\n' \
    "Usage: $0 --compiler <path> --tree <json> --image-size <WxH> \\" \
    "  --viewport-size <WxH> --captured-at <ISO-8601> --screen-id <id> [options]" \
    "" \
    "Options:" \
    "  --tree-captured-at <ISO-8601>  Optional native-tree timestamp" \
    "  --orientation <value>           Defaults to unknown" \
    "" \
    "Writes one raw-versus-conservative JSON summary to stdout."
}

compiler=""
tree=""
image_size=""
viewport_size=""
captured_at=""
tree_captured_at=""
screen_id=""
orientation="unknown"

while (($# > 0)); do
  case "$1" in
    --compiler)
      (($# >= 2)) || { usage >&2; exit 2; }
      compiler="${2:-}"
      shift 2
      ;;
    --tree)
      (($# >= 2)) || { usage >&2; exit 2; }
      tree="${2:-}"
      shift 2
      ;;
    --image-size)
      (($# >= 2)) || { usage >&2; exit 2; }
      image_size="${2:-}"
      shift 2
      ;;
    --viewport-size)
      (($# >= 2)) || { usage >&2; exit 2; }
      viewport_size="${2:-}"
      shift 2
      ;;
    --captured-at)
      (($# >= 2)) || { usage >&2; exit 2; }
      captured_at="${2:-}"
      shift 2
      ;;
    --tree-captured-at)
      (($# >= 2)) || { usage >&2; exit 2; }
      tree_captured_at="${2:-}"
      shift 2
      ;;
    --screen-id)
      (($# >= 2)) || { usage >&2; exit 2; }
      screen_id="${2:-}"
      shift 2
      ;;
    --orientation)
      (($# >= 2)) || { usage >&2; exit 2; }
      orientation="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$compiler" || -z "$tree" || -z "$image_size" || -z "$viewport_size" \
  || -z "$captured_at" || -z "$screen_id" ]]; then
  usage >&2
  exit 2
fi
if [[ ! -x "$compiler" ]]; then
  printf 'Compiler is not executable: %s\n' "$compiler" >&2
  exit 1
fi
if [[ ! -f "$tree" ]]; then
  printf 'Tree input does not exist: %s\n' "$tree" >&2
  exit 1
fi

readonly script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly working_directory="$(mktemp -d "${TMPDIR:-/tmp}/ui-state-tree-cleaning.XXXXXX")"

cleanup() {
  rm -rf "$working_directory"
}
trap cleanup EXIT

common_arguments=(
  compile
  --tree "$tree"
  --tree-format xcuitest-json
  --image-size "$image_size"
  --viewport-size "$viewport_size"
  --captured-at "$captured_at"
  --screen-id "$screen_id"
  --orientation "$orientation"
)
if [[ -n "$tree_captured_at" ]]; then
  common_arguments+=(--tree-captured-at "$tree_captured_at")
fi

for mode in raw conservative; do
  "$compiler" "${common_arguments[@]}" \
    --tree-cleaning "$mode" \
    --format json \
    >"$working_directory/$mode.json" \
    2>"$working_directory/$mode.telemetry.json"
  "$compiler" "${common_arguments[@]}" \
    --tree-cleaning "$mode" \
    --format compact \
    >"$working_directory/$mode.compact" \
    2>"$working_directory/$mode.compact.telemetry.json"
done

python3 "$script_directory/summarize-tree-cleaning.py" \
  --tree "$tree" \
  --raw-json "$working_directory/raw.json" \
  --raw-compact "$working_directory/raw.compact" \
  --raw-telemetry "$working_directory/raw.telemetry.json" \
  --clean-json "$working_directory/conservative.json" \
  --clean-compact "$working_directory/conservative.compact" \
  --clean-telemetry "$working_directory/conservative.telemetry.json"
