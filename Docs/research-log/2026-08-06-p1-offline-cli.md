# P1 offline CLI vertical slice

Date: 2026-08-06
Status: Accepted for Task 6; human readability checkpoint pending

## Scope

Compile saved evidence in three offline modes:

- Screenshot-only: decode physical pixel dimensions and emit screen metadata.
- Tree-only: normalize XML nodes using caller-supplied image and viewport sizes.
- Hybrid: preserve screenshot and native-tree evidence in one canonical state.

The same state produces sorted canonical JSON and deterministic compact text.
Non-deterministic timing measurements are emitted separately to stderr.

## CLI contract

```text
ui-compiler compile \
  [--screenshot <png>] \
  [--tree <xml>] \
  [--image-size <WxH>] \
  --viewport-size <WxH> \
  [--captured-at <ISO-8601>] \
  [--tree-captured-at <ISO-8601>] \
  [--screen-id <id>] \
  [--orientation <schema-value>] \
  [--format <json|compact>]
```

At least one evidence input is required. Tree-only mode requires explicit image
dimensions because a hierarchy frame does not prove screenshot pixel size.

## Implementation decisions

- Image decoding uses `CGImageSourceCreateWithData` and creates the first
  `CGImage`; width and height come from the decoded image.
- Input metadata is checked before state construction. Defaults limit a
  screenshot to 64 MiB and 100 million pixels.
- Native XML uses the hardened parser from Task 5.
- Native frames become `screen_points` rectangles. Deterministically mapped
  interactive roles receive center-point tap candidates marked
  `tree_declared`; this is structural evidence, not execution verification.
- Screenshot-only output contains image size, viewport, orientation, timestamp,
  and screenshot provenance, with no fabricated OCR elements.
- JSON keys are sorted. Compact rows preserve document order and escape field
  delimiters. Fixed timestamps and IDs produce byte-identical JSON and compact
  output across repeated invocations.
- Timings report `image_decode_ms`, `xml_parse_ms`, `serialization_ms`, and
  `total_ms` as a separate JSON object on stderr.

Apple documents that Image I/O image sources can read from a data object and
create an image at a specified index:

- <https://developer.apple.com/documentation/imageio/cgimagesource>
- <https://developer.apple.com/documentation/imageio/cgimagesourcecreatewithdata(_:_:)>

## Test-driven evidence

1. The first integration run failed compilation because offline timing and
   compiler types did not exist.
2. The first executable integration run then exposed a test-harness path issue;
   executable discovery was made independent of the SwiftPM architecture path.
3. Screenshot-only, tree-only, and hybrid JSON outputs all decoded as canonical
   version `0.1.0` state. Screenshot mode recovered the synthetic PNG's `1 x 1`
   physical size; tree and hybrid modes produced three normalized nodes.
4. Repeated fixed-timestamp invocations produced byte-identical JSON and compact
   stdout. Timing values varied only on stderr, as designed.
5. A generated tree-only JSON document passed the committed Draft 2020-12
   schema through the independent validator: `ok -- validation done`.
6. Boundary tests reject missing evidence, invalid image data, and screenshot
   bytes above the configured limit.
7. The final regression run passed 22 tests in six suites, followed by an
   independent successful SwiftPM build and strict formatter lint.

## Current limitations

- The screenshot fixture is a one-pixel synthetic PNG used only to exercise the
  saved-image decode path.
- Screenshot-only has metadata but no OCR or visual element inference yet.
- Hybrid mode combines provenance but does not yet align conflicting geometry
  or timestamps.
- Timings are instrumentation fields, not benchmark results. No latency claim is
  made from synthetic fixtures or warm local builds.
- A human still needs to review the emitted compact state for readability and
  grounding before the P1 checkpoint is fully closed.

## Acceptance commands

```text
swift test --filter OfflineCompilerTests
swift test --filter CLIIntegrationTests
swift test
swift build
swift format lint --recursive --strict Sources Tests Package.swift
```
