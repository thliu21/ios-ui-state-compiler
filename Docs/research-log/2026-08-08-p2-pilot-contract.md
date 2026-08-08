# P2 pilot contract and validator

Date: 2026-08-08
Status: Implemented and locally verified

## Scope

This increment fixed the data contract before collecting app artifacts. It added
a versioned pilot manifest, license ledger, annotation guide, sample fixtures,
and an offline semantic validator with no third-party dependencies.

## Capacity preflight

The macOS data volume reported 116 GiB available before implementation. The
pilot contract therefore keeps a 30 GiB reserve and requires a fresh estimate
before every collection run. Work beyond the 50-screen pilot requires at least
80 GiB free after the estimate or an approved external artifact root.

The Linux workstation remains optional. No remote access, artifact copy, or GPU
work occurred in this increment.

## Validation behavior

The validator checks:

- Manifest and ledger version compatibility.
- Duplicate record, action-pair, and ledger IDs.
- App, app-family, and near-duplicate leakage across splits.
- License-ledger references and explicit redistribution approval.
- Action-pair record references and matching capture context.
- Frozen-pilot counts and framework, locale, appearance, viewport, and held-out
  coverage.

Draft manifests may be incomplete while collection is in progress. Frozen
manifests fail closed when any pilot coverage gate is missing.

## Verification

- All four documentation schemas parsed as JSON.
- Strict Swift format lint passed.
- `swift build` passed.
- `swift test` passed with 27 tests across 7 suites.
- The direct provider-term repository scan returned no matches.

## Remaining P2 work

- Human-review five representative synthetic annotations.
- Select and license-review candidate UIKit and SwiftUI apps.
- Collect and validate the 50-screen pilot.
- Freeze the app-disjoint manifest and publish the measured coverage report.
- Implement and measure B0-B6 representations.
