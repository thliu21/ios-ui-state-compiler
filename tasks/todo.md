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

- [ ] Required fields match the JSON schema.
- [ ] Evidence levels and coordinate spaces survive round trip.
- [ ] Unknown optional values remain unknown rather than becoming false.

**Verification:**

- [ ] Codable round-trip tests pass.
- [ ] Produced fixture validates against the schema.

**Dependencies:** Task 3
**Files likely touched:** two core files, one fixture, one test file
**Estimated scope:** Medium

## Task 5: Parse a synthetic native tree

**Description:** Parse a minimal XML fixture into normalized nodes without
external entities, implicit network access, or unsafe instruction handling.

**Acceptance criteria:**

- [ ] Role, label, value, identifier, frame, and state are normalized.
- [ ] Malformed input produces a structured error.
- [ ] Fixture text is treated only as data.

**Verification:**

- [ ] Valid and malformed XML tests pass.
- [ ] Parser performs no network access.

**Dependencies:** Task 4
**Files likely touched:** parser, normalized node type, two fixtures, tests
**Estimated scope:** Medium

## Task 6: Produce the first offline CLI result

**Description:** Accept a saved PNG and optional XML, then emit canonical JSON,
deterministic compact text, and a timing breakdown.

**Acceptance criteria:**

- [ ] All three input modes return schema-conforming output.
- [ ] Screenshot-only returns useful metadata before OCR is implemented.
- [ ] Timings separate image decode, XML parse, and serialization.

**Verification:**

- [ ] CLI integration tests pass on synthetic fixtures.
- [ ] Repeated output is byte-for-byte deterministic except timestamps.

**Dependencies:** Tasks 4 and 5
**Files likely touched:** CLI, file adapter, renderer, fixtures, tests
**Estimated scope:** Medium

## Checkpoint after Task 6

- [ ] `swift build` passes.
- [ ] `swift test` passes.
- [ ] Offline prototype requires no simulator, network, or paid service.
- [ ] Human review confirms the state remains readable and grounded.
