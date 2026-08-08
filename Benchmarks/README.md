# Offline representation measurements

`Scripts/measure-tree-cleaning.sh` compares raw and conservative compilation of
one saved structured XCUITest tree. It invokes the same built compiler for both
conditions and emits one JSON summary containing:

- canonical JSON and compact UTF-8 byte counts;
- element, action, native-identifier occurrence, semantic-element, and
  normalized semantic parent-child relation counts;
- per-stage diagnostic timings from each invocation;
- wrapper and exact-duplicate removal counts; and
- equality gates for unique and multiset action signatures, native identifiers,
  semantic signatures, and normalized semantic parent-child relations.

The equality gates are intentionally conservative and fail the command when the
cleaned output changes one of those structures. Parent-child comparison ignores
semantic-empty wrappers so permitted wrapper collapse does not cause a false
failure. It does not prove child ordering, visual grounding, reading order, or
task success. Single-run timings are diagnostic only; latency reporting still
requires the repeated cold/warm design in `Docs/evaluation-contract.md`.

Raw screenshots and hierarchy files remain outside Git unless the license ledger
permits redistribution. Aggregate summaries may be committed only after their
source hashes and privacy boundary are reviewed.

The first reviewed aggregate is
`pilot-action-tree-cleaning-2026-08-08.json`. It contains two self-authored
SwiftUI fixture states, exact source-tree hashes, representation sizes, cleaning
counts, and single-run diagnostic timings. It contains no raw screenshot or
hierarchy content.

`swiftui-initial-state-tree-cleaning-2026-08-08.json` extends that diagnostic
comparison to direct detail, form, modal, and long-list captures. The exact
device tests passed 4/4, all external files matched their Linux mirror, and all
seven retention gates passed for every state. The file still does not establish
token, latency, child-order, reading-order, visual-grounding, or task-success
gains.

`uikit-state-tree-cleaning-2026-08-08.json` records the symmetric UIKit
five-state matrix plus the verified action's after-detail capture. The exact
device tests passed 5/5 and all six raw-versus-conservative comparisons passed
the same seven retention gates. The same diagnostic-only limitations apply.
