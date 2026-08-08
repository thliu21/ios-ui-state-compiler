# Offline representation measurements

`Scripts/measure-tree-cleaning.sh` compares raw and conservative compilation of
one saved structured XCUITest tree. It invokes the same built compiler for both
conditions and emits one JSON summary containing:

- canonical JSON and compact UTF-8 byte counts;
- element, action, native-identifier, and unique semantic-signature counts;
- per-stage diagnostic timings from each invocation;
- wrapper and exact-duplicate removal counts; and
- equality gates for action signatures, native identifiers, and unique semantic
  signatures.

The equality gates are intentionally conservative and fail the command when the
cleaned output changes one of those sets. They do not prove visual grounding,
reading order, relation retention, or task success. Single-run timings are
diagnostic only; latency reporting still requires the repeated cold/warm design
in `Docs/evaluation-contract.md`.

Raw screenshots and hierarchy files remain outside Git unless the license ledger
permits redistribution. Aggregate summaries may be committed only after their
source hashes and privacy boundary are reviewed.
