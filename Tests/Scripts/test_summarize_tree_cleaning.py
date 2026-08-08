#!/usr/bin/env python3

import importlib.util
from pathlib import Path
import unittest


SCRIPT_PATH = (
    Path(__file__).resolve().parents[2] / "Scripts" / "summarize-tree-cleaning.py"
)
SPEC = importlib.util.spec_from_file_location("summarize_tree_cleaning", SCRIPT_PATH)
assert SPEC is not None
assert SPEC.loader is not None
summarizer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(summarizer)


def element(
    identifier: str,
    *,
    role: str = "button",
    label: str | None = "Continue",
    native_identifier: str | None = "fixture.continue",
    parent_id: str | None = None,
    actions: list[dict] | None = None,
) -> dict:
    return {
        "id": identifier,
        "role": role,
        "label": label,
        "value": None,
        "native_identifier": native_identifier,
        "frames": [
            {
                "x": 10,
                "y": 20,
                "width": 100,
                "height": 44,
                "coordinate_space": "screen_points",
            }
        ],
        "enabled": True,
        "selected": False,
        "parent_id": parent_id,
        "child_ids": [],
        "actions": actions or [],
    }


class RetentionChecksTests(unittest.TestCase):
    def test_multiplicity_loss_fails_even_when_unique_sets_match(self) -> None:
        tap = {
            "type": "tap",
            "target": None,
            "verification": "tree_declared",
        }
        raw = {
            "elements": [
                element("button-1", actions=[tap]),
                element("button-2", actions=[tap]),
            ]
        }
        clean = {"elements": [element("button-1", actions=[tap])]}

        checks = summarizer.retention_checks(raw, clean)

        self.assertTrue(checks["semantic_signature_sets_equal"])
        self.assertTrue(checks["native_identifiers_equal"])
        self.assertTrue(checks["action_signatures_equal"])
        self.assertFalse(checks["semantic_signature_multisets_equal"])
        self.assertFalse(checks["native_identifier_multisets_equal"])
        self.assertFalse(checks["action_signature_multisets_equal"])

    def test_empty_wrappers_do_not_change_semantic_parent_child_relations(self) -> None:
        root = element(
            "root", role="window", label="Fixture", native_identifier="fixture.root"
        )
        wrapper = element(
            "wrapper",
            role="unknown",
            label=None,
            native_identifier=None,
            parent_id="root",
        )
        child = element("child", parent_id="wrapper")
        raw = {"elements": [root, wrapper, child]}
        clean = {"elements": [root, element("child", parent_id="root")]}

        checks = summarizer.retention_checks(raw, clean)

        self.assertTrue(checks["semantic_parent_child_relation_multisets_equal"])

    def test_reparenting_fails_when_semantic_elements_stay_equal(self) -> None:
        first_parent = element(
            "first", role="group", label="First", native_identifier="fixture.first"
        )
        second_parent = element(
            "second", role="group", label="Second", native_identifier="fixture.second"
        )
        raw = {
            "elements": [
                first_parent,
                second_parent,
                element("child", parent_id="first"),
            ]
        }
        clean = {
            "elements": [
                first_parent,
                second_parent,
                element("child", parent_id="second"),
            ]
        }

        checks = summarizer.retention_checks(raw, clean)

        self.assertTrue(checks["semantic_signature_multisets_equal"])
        self.assertFalse(checks["semantic_parent_child_relation_multisets_equal"])


if __name__ == "__main__":
    unittest.main()
