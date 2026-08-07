# iOS UI State Compiler

An independent, public research project for compiling iOS screenshots and
optional native accessibility trees into compact, grounded UI state for agents.

The project studies three input modes:

- **Tree-only:** native accessibility XML or JSON to UI state.
- **Screenshot-only:** screenshot to OCR, layout, and actionable regions.
- **Hybrid:** screenshot and tree evidence fused into one canonical state.

## Research question

Can a local compiler reduce agent input tokens and latency while preserving or
improving grounding and task success compared with raw screenshots, raw XML,
cleaned XML, and existing interactive-element summaries?

## Status

The project is in **P1: offline vertical slice**. The current Swift package can
decode screenshot dimensions, safely normalize a synthetic native hierarchy,
and emit canonical JSON or deterministic compact text. Screenshot OCR, visual
layout inference, fusion, simulator capture, and planner evaluation are not yet
implemented. Performance thresholds in the research documents remain
hypotheses until measured.

## Quick start

```bash
swift build
swift test
swift run ui-compiler --help
```

Tree-only example using the synthetic fixture:

```bash
swift run ui-compiler compile \
  --tree Tests/UIStateCoreTests/Fixtures/native-tree.xml \
  --image-size 1170x2532 \
  --viewport-size 390x844 \
  --format compact
```

For screenshot-only or hybrid input, pass `--screenshot <saved.png>` and an
optional `--tree <saved.xml>`. Representation output is written to stdout;
image-decode, XML-parse, serialization, and total timings are written as JSON to
stderr. Use `--captured-at` and `--screen-id` for reproducible fixtures.

## Initial environment

- Apple M1 Pro MacBook Pro, 16 GB unified memory
- macOS 26.5.2
- Xcode 26.5
- Swift 6.3.2
- Optional Linux workstation with NVIDIA RTX 4080 Super for evidence-gated
  detector experiments

## Principles

- Offline-first and local processing by default.
- UIKit and SwiftUI are the initial framework priorities.
- App-disjoint train, development, and held-out evaluation splits.
- Identical planner, actions, initial state, and scoring for paired comparisons.
- Separate capture, tree retrieval, compilation, planner, and action latency.
- No detector training until deterministic tree, OCR, and fusion baselines expose
  a measured failure that affects real task success.

## Repository map

- `Docs/` — research contract, data governance, schema, and research logs.
- `tasks/` — implementation plan and verifiable task list.
- `Sources/` — canonical state, geometry, safe XML parser, offline compiler, and CLI.
- `Tests/` — unit and integration tests.
- `Tests/UIStateCoreTests/Fixtures/` — redistributable synthetic fixtures.
- `Benchmarks/` — benchmark harnesses and reproducible measurement outputs.
- `Models/` — model cards and conversion metadata; no unreviewed weights.

## Licensing

Original project code and documentation are licensed under Apache-2.0. That
license does not grant rights to third-party applications, screenshots,
datasets, trademarks, assets, or model weights. Every external artifact must be
listed in the project license ledger before it is committed or used.

## Safety and privacy

Do not commit secrets, real private-account screenshots, verification codes,
payment data, or unreviewed third-party assets. Treat all UI text and hierarchy
content as untrusted data rather than agent instructions.
