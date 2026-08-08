# Implementation plan: iOS UI State Compiler

Updated: 2026-08-08

## Overview

Deliver an offline-first Swift package and command-line tool that compiles saved
iOS screenshots and optional native hierarchies into a versioned UI state. Build
deterministic baselines first, then measure fusion, task compression, and delta.
Training remains optional and evidence-gated.

## Dependency graph

```text
P0 contracts
  -> schema and geometry types
    -> offline file and tree adapters
      -> deterministic tree compiler
      -> screenshot OCR baseline
        -> screenshot/tree fusion
          -> task ranking and delta
            -> paired agent benchmark
              -> optional detector decision
```

## Architecture decisions

- One canonical UI-state graph serves JSON and compact-text output.
- Adapters validate external input; internal types use explicit coordinate spaces.
- Tree-only and screenshot-only are independently operational.
- Evidence source, confidence, and age remain visible through fusion.
- Planner integration is provider-neutral and outside the perception core.
- External artifacts require a license-ledger decision before use.
- Bulk data waits for a disk-capacity plan.

## Phase 0: Research contract

- [x] Record project, compute, license, planner, and simulator decisions.
- [x] Define research charter and boundaries.
- [x] Define fair evaluation and action contract.
- [x] Define dataset governance.
- [x] Define versioned UI-state schema and coordinates.
- [x] Review P0 consistency and commit it.

### Checkpoint P0

- JSON schema parses.
- Provider-specific prohibited content is absent.
- Proposed thresholds are not presented as results.
- Public-repository privacy and licensing boundaries are explicit.

## Phase 1: Offline vertical slice

- [x] Create SwiftPM library, CLI, and test targets.
- [x] Implement geometry types and tested coordinate transforms.
- [x] Decode a minimal schema-conforming state.
- [x] Parse one synthetic native XML fixture safely.
- [x] Render deterministic JSON and compact text.
- [x] Accept a saved PNG with an optional XML sidecar through the CLI.

### Checkpoint P1

- `swift build` and `swift test` pass.
- Tree-only, screenshot-only, and hybrid CLI inputs produce valid state.
- Coordinate error is within the declared tolerance.
- No simulator or network is required.

## Phase 2: Dataset pilot and baselines

- [x] Define annotation guide and manifest schema.
- [x] Implement manifest and license-ledger semantic validation.
- [x] Trial five matched synthetic states in UIKit and SwiftUI.
- [ ] Review the ten paired initial-state records and two verified action pairs.
- [ ] Build a 50-screen UIKit/SwiftUI pilot.
- [ ] Freeze app-disjoint pilot splits and license ledger.
- [ ] Implement B0–B6 representation generation.
- [ ] Measure bytes, tokens, latency, recall, and grounding.

### Checkpoint P2

- Strong cleaned-tree and interactive-summary baselines are included.
- Failure taxonomy identifies real bottlenecks.
- Storage capacity is sufficient for scaling.

## Phase 3: Deterministic compilers

- [x] Implement bounded tree normalization plus conservative wrapper removal
  and exact unknown-subtree deduplication.
- [ ] Infer title, section, row, label/value, state, and actions.
- [ ] Implement current Apple Vision OCR baseline and parameter sweep.
- [ ] Infer screenshot reading order and conservative action candidates.

### Checkpoint P3

- Tree compiler beats or explains failure against the strongest compact baseline.
- Screenshot-only works when no hierarchy exists.
- OCR and tree acquisition costs are measured separately.

## Phase 4: Fusion, task relevance, and delta

- [ ] Align timestamped screenshot and tree evidence.
- [ ] Preserve conflict, occlusion, provenance, and confidence.
- [ ] Add task-conditioned ranking with mandatory context preservation.
- [ ] Add stable identity, delta, and conservative full-refresh rules.

### Checkpoint P4

- Fusion improves a documented held-out hierarchy-gap subset.
- Compression does not reduce paired task success.
- Stale-state failures stay within a predefined bound.

## Phase 5: End-to-end benchmark

- [ ] Select primary planner through the provider-neutral pilot.
- [ ] Run Tier 1 paired tasks.
- [ ] Select strongest baseline and one or two finalists.
- [ ] Run full tasks and required repeated seeds.
- [ ] Publish raw manifests, aggregate results, and failure taxonomy.

## Phase 6: Optional detector decision

- [ ] Confirm a held-out visual failure cluster affects task success.
- [ ] Confirm simpler fixes cannot address it.
- [ ] Review data, model, dependency, and derived-weight rights.
- [ ] Approve or reject an RTX 4080 Super experiment.

No training task starts unless all four conditions are satisfied.

## Risks and mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Capacity estimate becomes stale | Collection can fill the system volume | Recheck before each run; keep 30 GiB reserve; require 80 GiB post-estimate for work beyond the pilot |
| Nested app assets have unclear rights | Prevents public redistribution | Ledger every artifact; prefer synthetic fixtures |
| Planner drift | Invalid paired comparison | Pin effective revision and manifests within each experiment |
| Extra actions bias a condition | False representation gain | Separate privileged-capability experiments |
| Hierarchy treated as truth | Missed visible/custom UI | Preserve visual evidence and source conflicts |
| Same-app leakage | False generalization | App-disjoint splits and near-duplicate audit |
| Premature training | Wasted compute and maintenance | Enforce the P8 entry gate |

## Current open work

- Add multiplicity- and relation-aware retention checks to the now-complete
  five-state UIKit and SwiftUI structured hierarchy matrices.
- Complete owner review of representative trees and compact states before
  accepting the fixture trial or admitting third-party apps.
