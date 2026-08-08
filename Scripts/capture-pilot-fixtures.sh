#!/usr/bin/env bash

set -euo pipefail

readonly reserve_kib=$((30 * 1024 * 1024))
readonly estimate_kib=$((256 * 1024))
readonly swiftui_bundle_id="org.thliu21.uistatecompiler.swiftuifixture"
readonly uikit_bundle_id="org.thliu21.uistatecompiler.uikitfixture"
readonly screens=(home detail form modal long_list)
readonly locales=(en zh-Hans en zh-Hans en)
readonly appearance_records=(light light dark dark light)

usage() {
  printf '%s\n' \
    "Usage: $0 --udid <simulator-udid> --derived-data <path> --output <path>" \
    "" \
    "Captures five matched SwiftUI/UIKit fixture screenshots." \
    "The command requires an explicit UDID and never performs a global shutdown."
}

udid=""
derived_data=""
output_root=""

while (($# > 0)); do
  case "$1" in
    --udid)
      (($# >= 2)) || { usage >&2; exit 2; }
      udid="${2:-}"
      shift 2
      ;;
    --derived-data)
      (($# >= 2)) || { usage >&2; exit 2; }
      derived_data="${2:-}"
      shift 2
      ;;
    --output)
      (($# >= 2)) || { usage >&2; exit 2; }
      output_root="${2:-}"
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

if [[ -z "$udid" || -z "$derived_data" || -z "$output_root" ]]; then
  usage >&2
  exit 2
fi

readonly products="$derived_data/Build/Products/Debug-iphonesimulator"
readonly swiftui_app="$products/SwiftUIFixture.app"
readonly uikit_app="$products/UIKitFixture.app"

for app in "$swiftui_app" "$uikit_app"; do
  if [[ ! -d "$app" ]]; then
    printf 'Missing built application: %s\n' "$app" >&2
    exit 1
  fi
done

for framework in swiftui uikit; do
  for screen in "${screens[@]}"; do
    if [[ -e "$output_root/$framework/$screen.png" ]]; then
      printf 'Refusing to overwrite existing capture: %s\n' \
        "$output_root/$framework/$screen.png" >&2
      exit 1
    fi
  done
done
if [[ -e "$output_root/captures.tsv" || -e "$output_root/environment.txt" ]]; then
  printf 'Refusing to overwrite existing capture metadata in %s\n' "$output_root" >&2
  exit 1
fi

mkdir -p "$output_root/swiftui" "$output_root/uikit"

available_kib=$(df -Pk "$output_root" | awk 'NR == 2 { print $4 }')
if [[ ! "$available_kib" =~ ^[0-9]+$ ]]; then
  printf 'Could not determine available storage for %s\n' "$output_root" >&2
  exit 1
fi
if ((available_kib < reserve_kib + estimate_kib)); then
  printf 'Capacity gate failed: %s KiB available; %s KiB required.\n' \
    "$available_kib" "$((reserve_kib + estimate_kib))" >&2
  exit 1
fi

device_line=$(xcrun simctl list devices | grep -F "$udid" || true)
if [[ -z "$device_line" ]]; then
  printf 'Simulator UDID was not found: %s\n' "$udid" >&2
  exit 1
fi

did_boot_simulator=0
restore_simulator_state() {
  if ((did_boot_simulator == 1)); then
    xcrun simctl shutdown "$udid" 2>/dev/null || true
  fi
}
trap restore_simulator_state EXIT

if [[ "$device_line" != *"(Booted)"* ]]; then
  xcrun simctl boot "$udid"
  did_boot_simulator=1
fi
xcrun simctl bootstatus "$udid" -b
xcrun simctl install "$udid" "$swiftui_app"
xcrun simctl install "$udid" "$uikit_app"

{
  printf 'captured_at=%s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  printf 'udid=%s\n' "$udid"
  xcodebuild -version
  swift --version
  xcrun simctl list devices | grep -F "$udid"
  df -Pk "$output_root"
} >"$output_root/environment.txt"

printf 'framework\tscreen\tbundle_id\tprocess_id\tlocale\tappearance\tcaptured_at\tscreenshot\n' \
  >"$output_root/captures.tsv"

capture_app() {
  local framework="$1"
  local bundle_id="$2"

  for index in "${!screens[@]}"; do
    local screen="${screens[$index]}"
    local locale="${locales[$index]}"
    local appearance_record="${appearance_records[$index]}"
    local screenshot="$output_root/$framework/$screen.png"
    local process_id=""
    local captured=0

    for attempt in 1 2 3; do
      local launch_output
      launch_output=$(
        xcrun simctl launch --terminate-running-process "$udid" "$bundle_id" \
          -AppleLanguages "($locale)" \
          -AppleLocale "$locale" \
          --fixture-appearance "$appearance_record" \
          --fixture-screen "$screen"
      )
      process_id="${launch_output##*: }"
      if [[ ! "$process_id" =~ ^[0-9]+$ ]]; then
        sleep 1
        continue
      fi

      sleep 2
      if xcrun simctl io "$udid" screenshot "$screenshot" >/dev/null; then
        captured=1
        break
      fi
      sleep 1
    done

    if ((captured != 1)); then
      printf 'Capture failed after three attempts: %s %s\n' "$framework" "$screen" >&2
      exit 1
    fi

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$framework" \
      "$screen" \
      "$bundle_id" \
      "$process_id" \
      "$locale" \
      "$appearance_record" \
      "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      "$screenshot" \
      >>"$output_root/captures.tsv"
  done
}

capture_app swiftui "$swiftui_bundle_id"
capture_app uikit "$uikit_bundle_id"

printf 'Captured %s paired fixture states in %s\n' "${#screens[@]}" "$output_root"
