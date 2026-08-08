# Human grounding review protocol

Status: Draft P2 protocol

## Purpose

This review asks whether a raw or conservatively cleaned native hierarchy and
its compact representation remain grounded in the paired screenshot. It is a
human evidence gate for the synthetic fixture trial, not a claim that an
accessibility hierarchy is visual truth.

Raw screenshots, hierarchies, canonical states, and compact states stay outside
Git while their redistribution status is `withheld`. The public repository may
contain this protocol, source hashes, aggregate measurements, and review
outcomes that do not reproduce withheld content.

## Review unit

One review unit contains:

- the lossless screenshot and source hierarchy;
- raw canonical JSON and compact text;
- conservative canonical JSON and compact text;
- the raw-versus-conservative measurement summary and SHA-256 manifest; and
- the pinned compiler revision, capture metadata, and expected action outcome
  when the record belongs to a verified action pair.

The first representative packet covers both frameworks across home/action,
detail after action, long-list multiplicity, and dark Chinese modal states. Form
remains structurally measured but is not required in the first human packet.

## Reviewer procedure

Review the screenshot before reading either representation, then inspect raw and
conservative outputs in that order. Record `pass`, `fail`, or `uncertain` for
each criterion; do not convert uncertainty into a pass.

1. **Visible content:** all task-relevant visible labels, values, controls, and
   state are represented without invented visual claims.
2. **Action grounding:** every visible actionable control has the expected
   action, native identifier when available, and a target that falls inside the
   displayed control. For action pairs, the recorded target and after root must
   match the verified outcome.
3. **Multiplicity:** repeated visible rows or controls remain separately
   represented. Equal text is not evidence that one instance may be deleted.
4. **Semantic hierarchy:** the nearest meaningful parent-child grouping is
   consistent with the screenshot. Empty framework wrappers may differ.
5. **Reading order:** compact output is usable in the screenshot's apparent
   reading order. The automated parent-child gate does not check this.
6. **Compact readability:** the compact form is unambiguous enough to identify
   the relevant content and action without consulting canonical JSON.
7. **Raw-to-clean preservation:** conservative output introduces no material
   omission, merge, reparenting, state change, or target change relative to raw.

Framework-specific styling and interaction may differ. The owner has already
observed that SwiftUI appears more modern; semantic grounding does not require
pixel-identical UIKit and SwiftUI rendering.

## Review record

Each reviewed unit records the following fields in an external review file:

```json
{
  "record_id": "stable-record-id",
  "reviewer": "reviewer-id",
  "reviewed_at": "ISO-8601",
  "compiler_revision": "40-character commit",
  "screenshot_sha256": "64-character digest",
  "source_tree_sha256": "64-character digest",
  "criteria": {
    "visible_content": "pass|fail|uncertain",
    "action_grounding": "pass|fail|uncertain",
    "multiplicity": "pass|fail|uncertain",
    "semantic_hierarchy": "pass|fail|uncertain",
    "reading_order": "pass|fail|uncertain",
    "compact_readability": "pass|fail|uncertain",
    "raw_to_clean_preservation": "pass|fail|uncertain"
  },
  "findings": []
}
```

A finding identifies the exact visible item or representation line, severity,
expected behavior, observed behavior, and whether it affects task success.

## Acceptance rule

The representative grounding gate passes only when:

- every required unit has one completed review record;
- every criterion is `pass` or every `uncertain` result has a recorded
  adjudication;
- no material content, action, multiplicity, hierarchy, reading-order, or state
  failure remains; and
- both verified home-to-detail action pairs pass action grounding.

A passing representative review closes only the paired-fixture human-grounding
item. It does not establish third-party-app coverage, token improvement,
latency, screenshot-only performance, planner task success, or the P2 checkpoint.

## Conflict handling

When screenshot and hierarchy disagree, preserve both sources and record the
conflict. Do not silently prefer the hierarchy, infer visibility from geometry,
or edit raw evidence. Any cleaner failure is reproduced against raw output and
added to the failure taxonomy before policy expansion.
