#!/usr/bin/env python3

import argparse
import hashlib
import json
from pathlib import Path
import sys


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tree", type=Path, required=True)
    parser.add_argument("--raw-json", type=Path, required=True)
    parser.add_argument("--raw-compact", type=Path, required=True)
    parser.add_argument("--raw-telemetry", type=Path, required=True)
    parser.add_argument("--clean-json", type=Path, required=True)
    parser.add_argument("--clean-compact", type=Path, required=True)
    parser.add_argument("--clean-telemetry", type=Path, required=True)
    return parser.parse_args()


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def semantic_signatures(state: dict) -> set[str]:
    signatures = set()
    for element in state["elements"]:
        if (
            element["role"] == "unknown"
            and element.get("label") is None
            and element.get("value") is None
            and element.get("native_identifier") is None
        ):
            continue
        value = {
            "role": element["role"],
            "label": element.get("label"),
            "value": element.get("value"),
            "native_identifier": element.get("native_identifier"),
            "frames": element["frames"],
            "enabled": element.get("enabled"),
            "selected": element.get("selected"),
        }
        signatures.add(json.dumps(value, sort_keys=True, separators=(",", ":")))
    return signatures


def action_signatures(state: dict) -> set[str]:
    signatures = set()
    for element in state["elements"]:
        for action in element["actions"]:
            value = {
                "role": element["role"],
                "label": element.get("label"),
                "native_identifier": element.get("native_identifier"),
                "type": action["type"],
                "target": action.get("target"),
                "verification": action["verification"],
            }
            signatures.add(json.dumps(value, sort_keys=True, separators=(",", ":")))
    return signatures


def native_identifiers(state: dict) -> set[str]:
    return {
        element["native_identifier"]
        for element in state["elements"]
        if element.get("native_identifier") is not None
    }


def representation(path: Path, state: dict) -> dict:
    return {
        "bytes": path.stat().st_size,
        "element_count": len(state["elements"]),
        "action_count": sum(len(element["actions"]) for element in state["elements"]),
        "native_identifier_count": len(native_identifiers(state)),
        "semantic_signature_count": len(semantic_signatures(state)),
    }


def timings(telemetry: dict) -> dict:
    return {
        key: telemetry[key]
        for key in (
            "image_decode_ms",
            "xml_parse_ms",
            "xcuitest_json_parse_ms",
            "tree_cleaning_ms",
            "serialization_ms",
            "total_ms",
        )
    }


def main() -> int:
    arguments = parse_arguments()
    raw = load_json(arguments.raw_json)
    clean = load_json(arguments.clean_json)
    raw_telemetry = load_json(arguments.raw_telemetry)
    clean_telemetry = load_json(arguments.clean_telemetry)

    retention = {
        "action_signatures_equal": action_signatures(raw) == action_signatures(clean),
        "native_identifiers_equal": native_identifiers(raw) == native_identifiers(clean),
        "semantic_signature_sets_equal": semantic_signatures(raw)
        == semantic_signatures(clean),
    }
    summary = {
        "schema_version": "0.1.0",
        "screen_id": raw["screen"]["id"],
        "source_tree_sha256": hashlib.sha256(arguments.tree.read_bytes()).hexdigest(),
        "raw": {
            "canonical_json": representation(arguments.raw_json, raw),
            "compact_bytes": arguments.raw_compact.stat().st_size,
            "timings_ms": timings(raw_telemetry),
        },
        "conservative": {
            "canonical_json": representation(arguments.clean_json, clean),
            "compact_bytes": arguments.clean_compact.stat().st_size,
            "timings_ms": timings(clean_telemetry),
            "tree_cleaning": clean_telemetry["tree_cleaning"],
        },
        "retention": retention,
    }
    print(json.dumps(summary, indent=2, sort_keys=True))

    if not all(retention.values()):
        print("tree-cleaning retention gate failed", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
