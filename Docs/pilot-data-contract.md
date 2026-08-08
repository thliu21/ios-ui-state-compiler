# P2 pilot data contract

Status: Accepted for implementation
Updated: 2026-08-08

## Objective

Build a 50-screen, manually reviewed pilot that tests whether the dataset fields,
annotation process, licensing review, and storage assumptions are usable before
the project scales collection. The pilot is evidence for process quality; it is
not evidence for model or agent performance.

## Versioned artifacts

Each pilot release contains:

- One manifest conforming to `pilot-manifest-schema.json`.
- One license ledger conforming to `license-ledger-schema.json`.
- One annotation JSON file per screen conforming to the canonical UI-state
  schema, plus review metadata in the manifest.
- Screenshot and optional native-tree artifacts referenced by relative path and
  SHA-256 digest.
- A generated coverage and validation report.

Manifest and ledger versions are independent of the canonical UI-state schema.
The initial versions are `0.1.0`. A frozen manifest is immutable; corrections
produce a new version and record the superseded manifest ID.

## Record identity and provenance

`record_id` is stable across metadata corrections. `app_id` identifies an app or
fixture family, not a build. A pinned source revision, bundle identifier, runtime,
device, viewport, locale, appearance, and capture timestamps identify the exact
observation.

All artifact paths are repository-relative or artifact-root-relative. Every
artifact has a lowercase SHA-256 digest. A missing tree is explicit rather than
represented by an empty file. Screenshot and tree timestamps stay separate.

## Pilot coverage gate

A manifest may remain `draft` while records are being collected. To become
`frozen`, validation must confirm:

- Exactly 50 screen records.
- UIKit and SwiftUI coverage.
- English and Chinese coverage.
- Light and dark appearance coverage.
- At least two distinct viewport sizes.
- At least ten verified action-before/action-after pairs.
- At least one held-out app, with every app assigned to only one split.
- Unique record IDs and valid license-ledger references.
- Every publishable artifact explicitly approved for redistribution.

These are coverage checks, not target class balances. The validation report must
publish the actual distribution and expose gaps.

## Split contract

The pilot uses `development` and `held_out` splits. An `app_id` may occur in only
one split. Related fixture families that share templates or assets use one
`app_id` or one `app_family_id` and remain in the same split.

Held-out artifacts cannot influence annotation-rule tuning, thresholds, prompt
tuning, or manual exception rules. Reviewers may correct factual annotation
errors, but the correction and reason are logged.

## Action-pair contract

An action pair links a before record, one coordinate-based action, and an after
record. Both records must share the same app, build, environment, and initial
state recipe except for the verified action outcome. The target point uses an
explicit coordinate space. Verification records the reviewer and outcome; a
declared but unexecuted action is not a verified pair.

## Public artifact boundary

The manifest and aggregate report may be committed once they contain no private
data. Screenshots, trees, and annotations may be committed only when their
ledger decision is `allowed_main_pipeline` and `redistribution_allowed` is true.
Otherwise the manifest records hashes and access instructions without publishing
the raw artifact.

## Capacity gate

Before a collection command writes artifacts, it records available bytes,
estimates output and temporary space, and keeps a 30 GiB reserve on the macOS
data volume. The 50-screen pilot pauses below that reserve. Collection beyond the
pilot requires a fresh estimate and either at least 80 GiB free after the
estimate or an approved external artifact root.

Linux storage is an optional artifact mirror until deterministic local baselines
show a compute need. Mirroring must preserve hashes and cannot silently become
the only copy of an unpublished annotation.

## Human checkpoints

The owner reviews:

1. Five representative annotations before bulk pilot labeling.
2. Every ambiguity that affects evaluation or split membership.
3. The frozen coverage report and license ledger.
4. A compact representation sample before the P2 checkpoint closes.

## Completion evidence

P2 dataset-contract work is complete when schema syntax checks pass, the sample
manifest and ledger pass semantic validation, invalid cross-split and licensing
fixtures fail for the expected reasons, and the 50-screen frozen manifest passes
the coverage gate.
