#!/usr/bin/env python3

import argparse
from collections import Counter
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


def signature(value: dict) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"))


def semantic_signature(element: dict) -> str | None:
    if (
        element["role"] == "unknown"
        and element.get("label") is None
        and element.get("value") is None
        and element.get("native_identifier") is None
    ):
        return None
    return signature(
        {
            "role": element["role"],
            "label": element.get("label"),
            "value": element.get("value"),
            "native_identifier": element.get("native_identifier"),
            "frames": element["frames"],
            "enabled": element.get("enabled"),
            "selected": element.get("selected"),
        }
    )


def semantic_signature_multiset(state: dict) -> Counter[str]:
    return Counter(
        value
        for element in state["elements"]
        if (value := semantic_signature(element)) is not None
    )


def semantic_signatures(state: dict) -> set[str]:
    return set(semantic_signature_multiset(state))


def action_signature_multiset(state: dict) -> Counter[str]:
    signatures = Counter()
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
            signatures[signature(value)] += 1
    return signatures


def action_signatures(state: dict) -> set[str]:
    return set(action_signature_multiset(state))


def native_identifier_multiset(state: dict) -> Counter[str]:
    return Counter(
        element["native_identifier"]
        for element in state["elements"]
        if element.get("native_identifier") is not None
    )


def native_identifiers(state: dict) -> set[str]:
    return set(native_identifier_multiset(state))


def semantic_parent_child_relation_multiset(state: dict) -> Counter[str]:
    elements_by_id = {element["id"]: element for element in state["elements"]}
    semantic_by_id = {
        element_id: value
        for element_id, element in elements_by_id.items()
        if (value := semantic_signature(element)) is not None
    }
    relations = Counter()

    for element_id, child_signature in semantic_by_id.items():
        parent_id = elements_by_id[element_id].get("parent_id")
        visited = set()
        parent: dict = {"boundary": "root"}

        while parent_id is not None:
            if parent_id in visited:
                parent = {"boundary": "cycle"}
                break
            visited.add(parent_id)

            parent_element = elements_by_id.get(parent_id)
            if parent_element is None:
                parent = {"boundary": "missing_parent"}
                break
            if parent_id in semantic_by_id:
                parent = {"semantic_signature": semantic_by_id[parent_id]}
                break
            parent_id = parent_element.get("parent_id")

        relations[
            signature({"parent": parent, "child_signature": child_signature})
        ] += 1

    return relations


def retention_checks(raw: dict, clean: dict) -> dict[str, bool]:
    return {
        "action_signatures_equal": action_signatures(raw) == action_signatures(clean),
        "native_identifiers_equal": native_identifiers(raw) == native_identifiers(clean),
        "semantic_signature_sets_equal": semantic_signatures(raw)
        == semantic_signatures(clean),
        "action_signature_multisets_equal": action_signature_multiset(raw)
        == action_signature_multiset(clean),
        "native_identifier_multisets_equal": native_identifier_multiset(raw)
        == native_identifier_multiset(clean),
        "semantic_signature_multisets_equal": semantic_signature_multiset(raw)
        == semantic_signature_multiset(clean),
        "semantic_parent_child_relation_multisets_equal": (
            semantic_parent_child_relation_multiset(raw)
            == semantic_parent_child_relation_multiset(clean)
        ),
    }


def representation(path: Path, state: dict) -> dict:
    identifier_multiset = native_identifier_multiset(state)
    semantic_multiset = semantic_signature_multiset(state)
    relation_multiset = semantic_parent_child_relation_multiset(state)
    return {
        "bytes": path.stat().st_size,
        "element_count": len(state["elements"]),
        "action_count": sum(len(element["actions"]) for element in state["elements"]),
        "native_identifier_count": len(identifier_multiset),
        "native_identifier_occurrence_count": sum(identifier_multiset.values()),
        "semantic_signature_count": len(semantic_multiset),
        "semantic_element_count": sum(semantic_multiset.values()),
        "semantic_parent_child_relation_count": sum(relation_multiset.values()),
        "unique_semantic_parent_child_relation_count": len(relation_multiset),
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

    retention = retention_checks(raw, clean)
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
