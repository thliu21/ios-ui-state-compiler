# Task list

## Task 1: Validate and publish P0 contracts

**Description:** Verify the five P0 contracts and public repository metadata,
then create the initial public repository without implementation claims.

**Acceptance criteria:**

- [x] JSON schema parses successfully.
- [x] Documentation contains no prohibited provider-specific content.
- [x] License, privacy, simulator, planner, and storage boundaries agree.

**Verification:**

- [x] `python3 -m json.tool Docs/ui-state-schema.json`
- [x] `git diff --check`
- [x] Read back public repository visibility and default branch.

**Dependencies:** None
**Files likely touched:** P0 documents and repository metadata
**Estimated scope:** Medium

## Task 2: Create the SwiftPM shell

**Description:** Add one library, one executable, and one test target with no
third-party dependencies.

**Acceptance criteria:**

- [x] Package builds on the recorded Swift toolchain.
- [x] CLI exposes help and version output.
- [x] Test target executes at least one real test.

**Verification:**

- [x] `swift build`
- [x] `swift test`
- [x] `swift run ui-compiler --help`

**Dependencies:** Task 1
**Files likely touched:** `Package.swift`, two source files, one test file
**Estimated scope:** Medium

## Task 3: Implement coordinate transformations

**Description:** Define explicit geometry types and convert among Vision,
pixels, logical points, and optional normalized action coordinates.

**Acceptance criteria:**

- [x] All four spaces are explicit in public types.
- [x] Vertical-origin conversion and nonuniform scale are covered.
- [x] Invalid viewport dimensions fail rather than silently converting.

**Verification:**

- [x] Focused geometry tests pass.
- [x] Round-trip error meets the coordinate contract.

**Dependencies:** Task 2
**Files likely touched:** two core files and one test file
**Estimated scope:** Medium

## Task 4: Decode and encode canonical UI state

**Description:** Implement Swift domain types matching schema version 0.1.0 and
round-trip one minimal synthetic state.

**Acceptance criteria:**

- [x] Required fields match the JSON schema.
- [x] Evidence levels and coordinate spaces survive round trip.
- [x] Unknown optional values remain unknown rather than becoming false.

**Verification:**

- [x] Codable round-trip tests pass.
- [x] Produced fixture validates against the schema.

**Dependencies:** Task 3
**Files likely touched:** two core files, one fixture, one test file
**Estimated scope:** Medium

## Task 5: Parse a synthetic native tree

**Description:** Parse a minimal XML fixture into normalized nodes without
external entities, implicit network access, or unsafe instruction handling.

**Acceptance criteria:**

- [x] Role, label, value, identifier, frame, and state are normalized.
- [x] Malformed input produces a structured error.
- [x] Fixture text is treated only as data.

**Verification:**

- [x] Valid and malformed XML tests pass.
- [x] Parser performs no network access.

**Dependencies:** Task 4
**Files likely touched:** parser, normalized node type, two fixtures, tests
**Estimated scope:** Medium

## Task 6: Produce the first offline CLI result

**Description:** Accept a saved PNG and optional XML, then emit canonical JSON,
deterministic compact text, and a timing breakdown.

**Acceptance criteria:**

- [x] All three input modes return schema-conforming output.
- [x] Screenshot-only returns useful metadata before OCR is implemented.
- [x] Timings separate image decode, XML parse, and serialization.

**Verification:**

- [x] CLI integration tests pass on synthetic fixtures.
- [x] Repeated output is byte-for-byte deterministic except timestamps.

**Dependencies:** Tasks 4 and 5
**Files likely touched:** CLI, file adapter, renderer, fixtures, tests
**Estimated scope:** Medium

## Checkpoint after Task 6

- [x] `swift build` passes.
- [x] `swift test` passes.
- [x] Offline prototype requires no simulator, network, or paid service.
- [ ] Human review confirms the state remains readable and grounded.

## Task 7: Freeze the P2 pilot data contract

**Description:** Define the annotation guide, pilot manifest, license ledger, and
semantic coverage checks before collecting third-party artifacts.

**Acceptance criteria:**

- [x] Manifest and ledger schemas are versioned and syntactically valid.
- [x] Annotation decisions distinguish screenshot evidence from native-tree evidence.
- [x] Frozen-pilot coverage and app-disjoint split requirements are explicit.
- [x] Valid sample manifest and ledger pass semantic validation.
- [x] Duplicate IDs, cross-split app leakage, broken references, and unapproved
  redistribution fail with specific errors.

**Verification:**

- [x] All JSON schemas parse.
- [x] Focused manifest-validation tests pass.
- [x] Full Swift test suite and strict format lint pass.

**Dependencies:** Task 6
**Files likely touched:** P2 documents, schemas, manifest types, fixtures, tests
**Estimated scope:** Medium

## Task 8: Trial paired UIKit and SwiftUI fixtures

**Description:** Build independent UIKit and SwiftUI applications that expose
the same five deterministic synthetic states, then use their ten observations to
trial the P2 capture and annotation contract.

**Acceptance criteria:**

- [x] A tested shared catalog defines exactly five stable screen identities.
- [x] Both application targets accept the same direct-launch screen argument.
- [x] Matching elements have matching accessibility identifiers.
- [x] Both targets build and run on the explicitly selected simulator UDID.
- [x] English, Simplified Chinese, light, and dark records are represented.
- [x] Owner review confirms screenshot semantic pairing and appearance coverage.
- [x] Ten paired records plus one action after-state and one verified action pair
  pass manifest and ledger checks.
- [ ] Human review confirms screenshot, tree, and compact-state grounding.

**Verification:**

- [x] Focused fixture-support tests pass.
- [x] Full Swift build, tests, and strict format lint pass.
- [x] Each Xcode target builds for the selected simulator destination.
- [x] Capture verification operates only the selected simulator UDID.
- [x] One exact-device SwiftUI XCUITest captures structured before/after trees
  and screenshots, executes a center-coordinate tap, and verifies the after root.
- [x] The exact structured before tree compiles offline through an explicit
  XCUITest JSON format into 43 canonical elements and the recorded action center.
- [x] Raw remains the default; conservative cleaning reports node removals and
  preserves the recorded home action and detail primary-action centers.
- [x] A public two-state aggregate records exact source hashes, JSON/compact
  bytes, raw diagnostic timings, and three passing retention gates without raw
  screenshots or hierarchies.
- [x] Four direct SwiftUI initial-state tests execute on the exact destination
  with zero failures, attach 12 artifacts, and restore the simulator to its
  prior shutdown state.
- [x] All four direct trees compile in raw and conservative modes; the public
  aggregate preserves all three retention sets and withholds raw artifacts.
- [x] A shared UIKit scheme and symmetric five-test UI-test target pass
  `build-for-testing` on the exact destination.
- [ ] Execute the UIKit tests, inspect and hash their artifacts, and admit only
  verified evidence into the manifest and isolated artifact store.

**Dependencies:** Task 7
**Files likely touched:** fixture specification, shared support module and tests,
two application targets, shared string catalog, pilot records
**Estimated scope:** Large, delivered in small commits
