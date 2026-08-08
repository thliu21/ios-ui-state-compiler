# P2 paired fixture trial

Date: 2026-08-08
Status: Draft capture trial; not P2 acceptance

## Question

Can one deterministic five-state contract produce reproducible UIKit and
SwiftUI observations that exercise the draft pilot manifest before third-party
applications are collected?

## Capture boundary

- Source revision: `54e545e5e4bed74302472fa6639e5fc411e18f07`.
- Toolchain: Xcode 26.5 (17F42), Swift 6.3.2, iOS Simulator 26.5.
- Device: iPhone 17 Pro, viewport 402 by 874 points at scale 3.
- Selected device UDID: `3BC2ABB5-651E-429E-8983-8CDBEC035388`.
- Capture script always named that UDID and restored its prior shutdown state.
- The run kept the 30 GiB local reserve and mirrored artifacts without
  overwriting an existing Linux directory.

The artifact-root-relative capture directory is
`pilot/paired-fixture-20260808`. Its ten screenshot hashes and timestamps are in
`Fixtures/PilotTrial/manifest.json`. The screenshots are not in Git.

## Implemented trial

The two independent application targets render `home`, `detail`, `form`,
`modal`, and `long_list` from the same tested state catalog. Both accept an
explicit screen and appearance launch argument, use one English and Simplified
Chinese string catalog, and give matching controls matching accessibility
identifiers.

The final matrix contains ten records:

| Framework | Screen | Locale | Appearance |
| --- | --- | --- | --- |
| SwiftUI | home | en | light |
| SwiftUI | detail | zh-Hans | light |
| SwiftUI | form | en | dark |
| SwiftUI | modal | zh-Hans | dark |
| SwiftUI | long_list | en | light |
| UIKit | home | en | light |
| UIKit | detail | zh-Hans | light |
| UIKit | form | en | dark |
| UIKit | modal | zh-Hans | dark |
| UIKit | long_list | en | light |

Every launch returned a process identifier. Final screenshots were 1206 by
2622 pixels. Independent screenshot inspection found no blank screen, crash,
cropping, or overlap. The first inspection found cramped detail metadata; both
implementations were corrected and all ten states were recaptured.

## Public artifact decision

The application code and fictional content are project-authored and covered by
the repository license. The screenshots also render Apple platform interface
materials and SF Symbols. The reviewed Apple materials describe intellectual
property ownership, trademark use, software-license restrictions, and a rights
request channel, but do not provide a sufficiently explicit basis to relicense
these rendered captures as public Apache-2.0 dataset assets.

The initial ledger therefore records both screenshot families as
`research_only_isolated`, permits research use only, marks commercial
compatibility unclear, and withholds public redistribution. This is a
conservative project decision, not legal advice.

Primary materials reviewed:

- [Apple Intellectual Property](https://www.apple.com/legal/intellectual-property/)
- [Guidelines for Using Apple Trademarks and Copyrights](https://www.apple.com/cl/legal/intellectual-property/guidelinesfor3rdparties.html)
- [Rights and Permissions](https://www.apple.com/legal/contact/rights-permissions.html)
- [Xcode and Apple SDKs Agreement](https://www.apple.com/legal/sla/docs/xcode.pdf)
- [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)

## Validation evidence

- Both Xcode targets built for the exact simulator destination.
- The shared Swift package built and all tests passed after the fixture work.
- The committed test suite decodes the draft manifest, ledger, and all ten
  screenshot-only canonical states, then runs semantic validation.
- Local and Linux read-back SHA-256 digests matched for all ten PNG files and
  both capture metadata files.
- JSON syntax, property-list syntax, project syntax, shell syntax, strict Swift
  formatting, whitespace checks, and the prohibited provider-content scan
  passed.

## Known gaps

- The available environment did not expose a reliable native hierarchy capture
  interface. Every `tree` value remains explicitly null.
- The ten canonical states are honest screenshot-only baselines with metadata
  and empty element arrays; they are not completed manual annotations.
- No coordinate action was executed and checked against an after-state, so
  `action_pairs` remains empty.
- The owner has not yet completed the required representative readability and
  grounding review.

The trial therefore proves the paired build, launch, screenshot, storage, hash,
and draft-manifest path. It does not yet satisfy fixture-trial acceptance or the
P2 checkpoint.
