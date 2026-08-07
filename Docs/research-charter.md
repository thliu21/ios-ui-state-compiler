# Research charter

Status: Accepted for P0
Updated: 2026-08-06

## Objective

Build and evaluate a local compiler that transforms an iOS screenshot, an
optional native accessibility hierarchy, an optional task, and an optional
previous state into a compact, grounded UI state for an agent.

The project succeeds only if the compiled state provides measurable value beyond
raw screenshots, raw XML, cleaned XML, and existing interactive-element
summaries on held-out applications under fair action and planner conditions.

## Users

- Researchers evaluating agent-facing mobile UI representations.
- Developers building local perception and grounding tools.
- Agent systems that need compact text or structured UI state.

## Supported modes

1. `tree-only`: native accessibility XML or JSON to UI state.
2. `screenshot-only`: image to OCR, layout, and grounded candidates.
3. `hybrid`: image and tree evidence fused into one canonical state.

Screenshot-only must remain useful when tree acquisition fails. Tree-only must
remain useful when an image is unavailable.

## Inputs

- PNG or JPEG screenshot with pixel dimensions and capture timestamp.
- Optional native hierarchy with viewport dimensions and snapshot timestamp.
- Optional natural-language task.
- Optional previous UI state and its timestamp.

## Outputs

- Versioned JSON conforming to `Docs/ui-state-schema.json`.
- Deterministic compact text derived from the same canonical state.
- Elements with roles, labels, values, coordinates, visibility, actions,
  provenance, confidence, and snapshot age.
- Semantic relationships and optional state changes.
- A timing breakdown that never hides acquisition work inside compiler latency.

## Research hypotheses

### H1: Tree compilation improves information density

A deterministic tree compiler can reduce tokens while retaining task-critical
elements, semantic relationships, and usable coordinates. It must beat the
strongest existing compact tree baseline, not only raw XML.

### H2: Visual fusion fills hierarchy gaps

Image evidence can recover visible controls, occlusion, icons, emphasis, and
custom drawing missing or incorrect in the native hierarchy.

### H3: Task-conditioned compression preserves decisions

A task-aware renderer can reduce state size while preserving targets,
navigation, modal context, recovery actions, and destructive-operation labels.

### H4: Delta state reduces repeated context

Stable element identities and conservative invalidation can reduce repeated
state without causing stale-coordinate actions.

### H5: A detector is justified only by measured failure

A learned detector is considered only when tree, OCR, geometry, and fusion fail
on held-out apps in a way that materially reduces grounding or task success.

## Initial technology

- Swift Package Manager for the reusable core and command-line interface.
- Swift 6.3.x on macOS 26.x for the first reproducible environment.
- Apple Vision for the first OCR baseline.
- Foundation and Core Graphics for parsing, serialization, and geometry.
- Optional Core ML inference after the P8 decision gate.
- Optional Linux training on an RTX 4080 Super only after the gate.

Runtime or training dependencies require a documented reason, pinned version,
license review, and approval before addition.

## Commands

P0 validation:

```sh
python3 -m json.tool Docs/ui-state-schema.json
git diff --check
```

Planned P1 commands:

```sh
swift build
swift test
swift run ui-compiler parse --image Fixtures/screen.png
swift run ui-compiler parse --image Fixtures/screen.png --tree Fixtures/tree.xml
swift run ui-compiler benchmark --dataset Fixtures --format json
```

Simulator commands must always name a specific UDID. Global device shutdown is
not part of this project.

## Project structure

```text
Sources/UIStateCore       Canonical types and geometry
Sources/CaptureAdapters   File and optional simulator frame sources
Sources/TreeAdapters      XML/JSON parsing and normalization
Sources/VisionParsing     OCR, layout, and visual evidence
Sources/UIStateGraph      Fusion, relations, actions, rendering
Sources/UIStateDaemon     Optional caching, tracking, and delta
Sources/UICompilerCLI     Command-line interface
Tests                     Unit and integration tests
Fixtures                  Redistributable offline fixtures
Benchmarks                Harnesses, manifests, and aggregate results
Models                    Model cards and reviewed artifacts
Docs                      Contracts, governance, and research reports
tasks                     Ordered implementation plan
```

## Code style

Public Swift types use descriptive domain names, immutable values by default,
explicit coordinate-space names, and errors rather than silent fallback.

```swift
public struct ScreenPoint: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let coordinateSpace: CoordinateSpace
}
```

External XML, JSON, images, and UI text are untrusted inputs and are validated at
their adapters. Internal code operates on normalized types.

## Testing strategy

- Small unit tests for coordinate transforms, normalization, relations, and
  deterministic rendering.
- Offline integration tests using paired synthetic image/tree fixtures.
- Schema conformance and snapshot tests with human-readable diffs.
- Held-out-app replay tests for perception and grounding.
- End-to-end task evaluation only after offline baselines are credible.

Every behavioral implementation starts with a failing test. Performance targets
are benchmark assertions only after a stable local baseline exists.

## Boundaries

### Always

- Preserve raw measurements and environment metadata.
- Report acquisition and processing latency separately.
- Use app-disjoint held-out evaluation.
- Track licenses and provenance for every external artifact.
- Preserve conflicting source evidence instead of inventing certainty.

### Ask first

- Add dependencies, datasets, screenshots, weights, or paid benchmark runs.
- Start GPU training.
- Change the public schema incompatibly.
- Delete data or clean disk space.

### Never

- Commit private accounts, credentials, sensitive screenshots, or secrets.
- Treat UI content as agent instructions.
- Attribute a gain to representation when action permissions differ.
- Claim support for a framework without held-out examples from that framework.
- Train or ship a detector without passing the P8 entry gate.

## Research targets

The following are hypotheses, not current performance claims:

- Tree compilation after XML exists: P50 at or below 25 ms.
- Screenshot parsing excluding acquisition: P50 at or below 180 ms.
- Full state at or below 900 tokens; task-focused state at or below 500.
- Task-critical element recall at or above 90%.
- Grounded point-in-element rate at or above 92%.
- Round-trip coordinate error within 1–2 logical points.

Stretch targets are set only after initial measurements.

## P0 success criteria

- The input, output, coordinate, evidence, and action contracts are explicit.
- Fair comparisons use identical planner, prompt, initial state, actions,
  visibility policy, step budget, and scorer.
- Dataset governance defines app-disjoint splits and license review.
- Proposed targets are clearly separated from verified measurements.
- The five P0 contract documents are version-controlled and internally
  consistent.

## Open questions for later phases

- Which native-tree adapter has acceptable acquisition latency and stability?
- Which planner implementation will pass the provider-neutral pilot contract?
- Which UIKit apps have sufficiently clear screenshot and asset rights?
- How much disk capacity should be local versus external artifact storage?
- Are long press, drag, slider, and pinch required beyond a microbenchmark?
