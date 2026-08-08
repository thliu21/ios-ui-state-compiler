# P2 paired fixture trial

Date: 2026-08-08
Status: Draft capture trial; not P2 acceptance

## Question

Can one deterministic five-state contract produce reproducible UIKit and
SwiftUI observations that exercise the draft pilot manifest before third-party
applications are collected?

## Capture boundary

- Paired screenshot source revision:
  `54e545e5e4bed74302472fa6639e5fc411e18f07`.
- Structured action source revision:
  `6bece16d4afaa099ba3cf068472ffee07ebadc50`.
- Toolchain: Xcode 26.5 (17F42), Swift 6.3.2, iOS Simulator 26.5.
- Device: iPhone 17 Pro, viewport 402 by 874 points at scale 3.
- Selected device UDID: `3BC2ABB5-651E-429E-8983-8CDBEC035388`.
- Capture script always named that UDID and restored its prior shutdown state.
- The run kept the 30 GiB local reserve and mirrored artifacts without
  overwriting an existing Linux directory.

The artifact-root-relative capture directory is
`pilot/paired-fixture-20260808`. Its ten screenshot hashes and timestamps are in
`Fixtures/PilotTrial/manifest.json`. The screenshots are not in Git.

The first action trial is in
`pilot/paired-fixture-action-20260808-6bece16`. It contains before/after
screenshots, before/after structured accessibility snapshots, the verified
action record, and an exported-attachment manifest. These files are also kept
outside Git.

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

## Owner screenshot review

The owner reviewed the paired captures and confirmed that UIKit and SwiftUI
express the same information and that requested light and dark appearances
match. The owner also observed framework-specific styling and interaction
differences, with SwiftUI appearing more modern. These differences remain part
of the trial evidence; semantic equivalence does not require pixel-identical
rendering or identical framework interaction behavior.

## Structured action trial

The shared `SwiftUIFixture` scheme now has one narrow XCUITest. It uses
`XCUIElement.snapshot().dictionaryRepresentation` for structured hierarchy
evidence, attaches lossless screenshots, resolves the element with identifier
`fixture.home.open-detail`, and taps the normalized center coordinate. The
test then requires `fixture.detail.root` to appear before it records the after
state. This follows the public XCUITest element and screenshot interfaces
rather than parsing the explicitly debugging-only textual description:

- [XCUIElement](https://developer.apple.com/documentation/xcuiautomation/xcuielement)
- [XCUIScreenshotProviding](https://developer.apple.com/documentation/xcuiautomation/xcuiscreenshotproviding)

The exact-device run passed one test with zero failures. The before snapshot
contained 43 nodes and the after snapshot contained 32 nodes. The resolved
action element frame was 16 by 382.6667 by 370 by 52.3333 points; its recorded
center target was `(201, 408.83333333333337)` screen points. The after root
appeared, and both screenshots were visually checked for the expected English,
light-appearance home and detail states.

The action run adds one transition after-state to the manifest, for 11 records
total, and one verified action pair. The initial-state recipe, app, source
revision, device, runtime, viewport, orientation, locale, appearance, Dynamic
Type, and split match across the action pair. The selected simulator was
restored to its prior shutdown state after the run.

A bounded `XCUITestSnapshotParser` now converts the structured JSON attachments
into the same flattened native-node model used by the synthetic XML baseline.
It enforces byte, node, and depth limits, uses deterministic tree-path node IDs,
preserves accessibility identifiers separately, and leaves unknown numeric
element types as `unknown`. It does not infer visibility or visual truth from
accessibility geometry. The parser read the exact before and after attachments
as 43 and 32 nodes, matching the capture harness counts.

## Public artifact decision

The application code and fictional content are project-authored and covered by
the repository license. The screenshots also render Apple platform interface
materials and SF Symbols. The reviewed Apple materials describe intellectual
property ownership, trademark use, software-license restrictions, and a rights
request channel, but do not provide a sufficiently explicit basis to relicense
these rendered captures as public Apache-2.0 dataset assets.

The initial ledger therefore records both screenshot families and the action
trial's screenshots and native trees as `research_only_isolated`, permits
research use only, marks commercial compatibility unclear, and withholds public
redistribution. This is a conservative project decision, not legal advice.

Primary materials reviewed:

- [Apple Intellectual Property](https://www.apple.com/legal/intellectual-property/)
- [Guidelines for Using Apple Trademarks and Copyrights](https://www.apple.com/cl/legal/intellectual-property/guidelinesfor3rdparties.html)
- [Rights and Permissions](https://www.apple.com/legal/contact/rights-permissions.html)
- [Xcode and Apple SDKs Agreement](https://www.apple.com/legal/sla/docs/xcode.pdf)
- [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)

## Validation evidence

- Both Xcode targets built for the exact simulator destination.
- The shared Swift package built and all tests passed after the fixture work.
- The structured snapshot parser's focused red/green cycle passed three tests
  covering normalization, malformed input, invalid fields, and resource limits;
  both exact action attachments also parsed successfully outside the test
  fixture.
- The offline compiler and CLI accept the JSON through explicit
  `--tree-format xcuitest-json`; the exact before attachment produced 43
  canonical elements, 121 ms snapshot age, and the recorded action center
  `(201, 408.8333333333333)`. The one-run parse timing is diagnostic evidence,
  not a performance result.
- The committed test suite decodes the draft manifest, ledger, and all ten
  paired canonical states plus the action after-state, then runs semantic
  validation over all 11 records and the action pair.
- Local and Linux read-back SHA-256 digests matched for all ten PNG files and
  both capture metadata files.
- Local and Linux read-back SHA-256 digests also matched for the five exported
  action attachments and their attachment manifest. The action directory was
  verified absent before creation, so no existing Linux artifact was
  overwritten.
- The structured action hashes are:
  - before hierarchy:
    `e00f3b134e5686d4f1e05f2f9a25a42353d61c044e067a1f45c1e9003692ca9b`
  - before screenshot:
    `43e324a403faebc275d7d8e78d048d734c51a7441fb6c4a8eee442591f56e264`
  - after hierarchy:
    `bc4ff5d1a2f4abc68a0171c84ae854f7f4754b3b522f81527dd7fc8435339b2d`
  - after screenshot:
    `a34e08a42d1e119747bc9ea31bd403b638c4bbac3b37426cf71dca0dbbb1216f`
  - action record:
    `05c0bb28f10c6dd37c5e83c54f56f741bf407ee22df3253a70533d69a7ed32e8`
- JSON syntax, property-list syntax, project syntax, shell syntax, strict Swift
  formatting, whitespace checks, and the prohibited provider-content scan
  passed.

## Known gaps

- Only the SwiftUI home-to-detail transition has structured native hierarchy
  evidence. The other nine paired screenshot records still have null trees,
  and UIKit hierarchy coverage has not started.
- The 11 committed annotation files still have empty element arrays; they are
  not completed manual annotations. Offline compilation now produces normalized
  elements from the two action trees, but those outputs have not been reviewed
  and backfilled into the annotations. The raw dictionaries remain evidence,
  not visual truth.
- Wrapper removal and structural deduplication remain open. The raw 43-node and
  32-node states are deliberately retained as the comparison baseline before
  any cleaning policy is introduced.
- Owner review of native-tree evidence, element annotations, and compact states
  remains pending.

The trial now proves the paired build, launch, screenshot, storage, hash,
structured hierarchy, one verified action, and draft-manifest path. It does not
yet satisfy human grounding acceptance or the P2 checkpoint.
