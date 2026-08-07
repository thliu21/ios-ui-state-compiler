# P1 native-tree parser

Date: 2026-08-06
Status: Accepted for Task 5

## Scope

Parse an untrusted, synthetic XCUITest-style hierarchy into flat normalized
nodes. Preserve role, label, value, identifier, logical-point frame, tri-state
properties, and parent/child relationships without network or filesystem entity
resolution.

This fixture exercises the common native hierarchy surface used by UIKit and
SwiftUI accessibility trees. It is not yet evidence of coverage across real
applications or framework-specific edge cases.

## Threat model

- XML can request local-file or network-backed external entities.
- DTD and entity expansion can consume unbounded resources.
- Deep or very large trees can exhaust memory or stack-like parser state.
- Labels and values can contain instruction-like text that must remain inert
  data.
- Raw parser diagnostics can echo untrusted content or implementation details.

## Controls

- Parse only caller-supplied `Data`; never initialize the parser from a URL.
- Reject `DOCTYPE` and entity declarations before parsing.
- Set `shouldResolveExternalEntities` to `false`, external-entity policy to
  `never`, and the external URL allowlist to empty.
- Abort on internal or external entity delegate callbacks as defense in depth.
- Enforce defaults of 8 MiB input, 50,000 nodes, and depth 256.
- Return stable structured error categories without raw XML values.
- Treat element text and attributes only as data. An instruction-like fixture
  label is preserved byte-for-byte as a Swift string.

Apple documents that enabling external entity resolution can cause additional
network or disk I/O, and provides a `never` resolving policy:

- <https://developer.apple.com/documentation/foundation/xmlparser/shouldresolveexternalentities>
- <https://developer.apple.com/documentation/foundation/xmlparser/externalentityresolvingpolicy-swift.enum>

## Test-driven evidence

1. The first focused run failed compilation because parser types did not exist.
2. The initial implementation exposed an Apple-platform module difference:
   `XMLParser` is available from `Foundation` on this toolchain, with no separate
   `FoundationXML` module. The import was corrected without adding a dependency.
3. The focused suite passed five tests covering valid normalization, malformed
   XML, a local-file external entity declaration, node limits, and byte/depth
   limits.
4. The full regression run passed 17 tests in four suites.

## Current limitations

- The role mapping is a deterministic pilot mapping, not a complete taxonomy.
- Text-node content is ignored because the current native fixture carries UI
  content in attributes.
- Nodes without `uid` or `id` receive deterministic document-order IDs.
- No real simulator hierarchy has been ingested yet.

## Acceptance commands

```text
swift test --filter NativeTreeParserTests
swift test
swift build
swift format lint --recursive --strict Sources Tests Package.swift
```

All commands passed on the recorded local Swift toolchain. No package dependency
was added.
