# Project decisions

Updated: 2026-08-08

## D-001: Public research project

The repository and research outputs are public. The work may inform future
products, so dataset, model, dependency, screenshot, and asset rights are
reviewed as if commercial compatibility may matter.

## D-002: Initial platform and frameworks

The first supported platform is iOS Simulator on Apple Silicon macOS. UIKit and
SwiftUI are the initial framework priorities. Claims about Flutter, React Native,
games, or custom-rendered interfaces require separate held-out evidence.

## D-003: Compute

Deterministic parsing, Apple Vision OCR, fusion, and Core ML inference run on the
local M1 Pro Mac. A Linux RTX 4080 Super workstation is available only for an
evidence-gated training experiment. GPU availability is not a reason to train a
model before the P8 gate.

## D-004: Planner

Offline perception and representation metrics do not use a planner.

The end-to-end benchmark uses a provider-neutral planner adapter. A planner must
support screenshot input when required, structured action output, and a pinned
configuration that can be replayed across paired conditions.

Every run manifest records the provider, exact model identifier or revision,
request date, prompt hash, tool-schema hash, inference configuration, image
detail, and step budget. A floating alias or configuration must not change within
a paired experiment.

Cost-sensitive smoke tests may use a different planner, but results from
different planners are reported separately and never pooled as paired evidence.
The primary planner for final evaluation will be selected through a small pilot
that measures task success, grounding consistency, latency, and cost.

## D-005: Repository license

Original code and documentation use Apache-2.0. External datasets, screenshots,
app assets, trademarks, and model weights retain their own terms and require a
license-ledger entry. An artifact is excluded when intended-use rights are
ambiguous.

## D-006: Simulator safety override

The project owner explicitly removed the handoff's `simplease` prerequisite
because that facility does not exist in this environment. The operational safety
intent remains: select exact UDIDs, avoid global shutdown, do not interfere with
unrelated devices, and record simulator provenance for every benchmark.

## D-007: Human review

The project owner is available for annotation and adjudication. Dataset work
starts with a 50-screen pilot before committing to the 500-screen golden target.

## D-008: Storage gate

The local data volume had approximately 14 GiB available at project start and
116 GiB available at the 2026-08-08 P2 preflight. The pilot keeps a 30 GiB local
reserve. Collection beyond 50 screens requires a fresh estimate and either at
least 80 GiB free after the estimate or an approved external artifact root.

The Linux workstation may provide artifact storage, but GPU work remains blocked
by the evidence gate in D-003. Remote storage is inventoried read-only before the
project writes or mirrors artifacts there.

## D-009: Structured XCUITest hierarchy input

The first structured native-tree adapter uses
`XCUIElement.snapshot().dictionaryRepresentation`, with screenshot evidence
captured separately. The implementation follows Apple's public
[XCUIElement](https://developer.apple.com/documentation/xcuiautomation/xcuielement)
and
[XCUIScreenshotProviding](https://developer.apple.com/documentation/xcuiautomation/xcuiscreenshotproviding)
interfaces and does not depend on the textual debugging description.

The CLI requires `--tree-format xcuitest-json`; it does not guess from file
contents. Numeric element types are mapped only where the pinned Xcode SDK enum
has a known canonical role, and unknown values remain `unknown`. Accessibility
structure is evidence, not visual truth: the adapter does not infer visibility
from frames. XML and XCUITest JSON parse timings remain separate, and older XML
timing records remain decodable.
