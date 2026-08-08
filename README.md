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

The project is in **P2: dataset pilot and baselines**. The current Swift package can
decode screenshot dimensions, safely normalize synthetic XML or structured
XCUITest JSON hierarchies, and emit canonical JSON or deterministic compact
text. Independent UIKit and SwiftUI fixture applications now expose five matched
deterministic states for the first capture and annotation trial. Screenshot OCR,
visual layout inference, fusion, and planner evaluation are not yet implemented.
Performance thresholds in the research documents remain hypotheses until
measured.

The pilot manifest and license ledger have offline decoding and semantic checks
for app-disjoint splits, references, redistribution approval, and frozen-pilot
coverage.

## Quick start

```bash
swift build
swift test
swift run ui-compiler --help
```

List and build the two fixture applications without adding dependencies:

```bash
xcodebuild -project Fixtures/PilotApps/PilotFixtures.xcodeproj -list
xcodebuild \
  -project Fixtures/PilotApps/PilotFixtures.xcodeproj \
  -scheme SwiftUIFixture \
  -destination 'platform=iOS Simulator,id=<explicit-udid>' \
  -derivedDataPath /tmp/ios-ui-state-compiler-derived \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Build `UIKitFixture` with the same command and destination. After both products
exist, `Scripts/capture-pilot-fixtures.sh` captures the five paired states. It
requires an explicit UDID and enforces the local 30 GiB storage reserve.

The `SwiftUIFixture` scheme also contains a narrow UI test for the first
`home`-to-`detail` action trial. It captures lossless screenshots and structured
XCUITest accessibility snapshots as result-bundle attachments:

```bash
xcodebuild test \
  -project Fixtures/PilotApps/PilotFixtures.xcodeproj \
  -scheme SwiftUIFixture \
  -destination 'platform=iOS Simulator,id=<explicit-udid>' \
  -resultBundlePath /tmp/swiftui-action.xcresult \
  -only-testing:SwiftUIFixtureUITests/SwiftUIHierarchyActionTests/testHomeToDetailProducesStructuredEvidence
```

Export the attachments with `xcrun xcresulttool export attachments`. Raw
screenshots and trees remain outside Git until the license ledger explicitly
permits redistribution.

Tree-only example using the synthetic fixture:

```bash
swift run ui-compiler compile \
  --tree Tests/UIStateCoreTests/Fixtures/native-tree.xml \
  --image-size 1170x2532 \
  --viewport-size 390x844 \
  --format compact
```

Structured XCUITest snapshot JSON uses an explicit format instead of content
auto-detection:

```bash
swift run ui-compiler compile \
  --tree Tests/UIStateCoreTests/Fixtures/xcuitest-snapshot.json \
  --tree-format xcuitest-json \
  --image-size 1206x2622 \
  --viewport-size 402x874 \
  --format compact
```

For screenshot-only or hybrid input, pass `--screenshot <saved.png>` and an
optional `--tree <saved-path>`. Representation output is written to stdout.
Image decode, XML parse, XCUITest JSON parse, serialization, and total timings
are separate JSON fields on stderr. Use `--captured-at`, including fractional
ISO-8601 seconds from capture tools, and `--screen-id` for reproducible fixtures.

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
- `Sources/` — canonical state, geometry, bounded XML and XCUITest JSON parsers,
  offline compiler, and CLI.
- `Tests/` — unit and integration tests.
- `Fixtures/PilotApps/` — matched, self-authored UIKit and SwiftUI applications.
- `Fixtures/PilotApps/SwiftUIFixtureUITests/` — exact-element hierarchy and action evidence.
- `Tests/UIStateCoreTests/Fixtures/` — redistributable synthetic fixtures.
- `Scripts/` — explicit-device collection helpers and capacity gates.
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
