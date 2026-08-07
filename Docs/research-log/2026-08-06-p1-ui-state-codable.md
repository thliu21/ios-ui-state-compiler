# P1 canonical UI-state Codable implementation

Date: 2026-08-06
Status: Accepted for Task 4

## Scope

Implement Swift domain types for schema version `0.1.0`, decode one minimal
synthetic UI state, and prove that its evidence, coordinate spaces, and unknown
optional booleans survive a deterministic Codable round trip.

## Contract decisions

- Every schema enum is string-backed and conforms to `CaseIterable`, `Codable`,
  and `Sendable`; every non-identity wire value has an explicit mapping.
- Every snake-case JSON field uses an explicit `CodingKeys` mapping.
- `UIState` always constructs version `0.1.0` and rejects any other version
  during decoding.
- `visible`, `enabled`, and `selected` are `Bool?`. Missing or JSON `null`
  values decode as `nil` and never default to `false`.
- The codec uses ISO 8601 dates and sorted JSON keys. Pretty printing is an
  output option rather than a different data model.
- The fixture is synthetic and contains no third-party application assets or
  user data.

## Test-driven evidence

1. The initial focused run copied the fixture into the SwiftPM test bundle and
   then failed compilation because the canonical state types and codec did not
   exist.
2. After implementing the types, the focused suite passed four tests, including
   four coordinate-space cases and three action-verification cases.
3. The test inspects encoded JSON required keys, decodes it again, and confirms
   that unknown booleans remain `nil` and are not serialized as false values.
4. An unsupported schema version produces a structured `DecodingError`.
5. The full regression run passed 12 tests in three suites.

## Independent schema validation

The synthetic source fixture was validated against the committed Draft 2020-12
schema with an ephemeral validator:

```text
uvx check-jsonschema \
  --schemafile Docs/ui-state-schema.json \
  Tests/UIStateCoreTests/Fixtures/minimal-ui-state.json
```

Result: `ok -- validation done`. The validator is not a package or runtime
dependency and no downloaded code is committed to this repository.

## Acceptance commands

```text
swift test --filter UIStateCodableTests
swift test
swift build
swift format lint --recursive --strict Sources Tests Package.swift
```

All commands passed on the recorded local Swift toolchain.
