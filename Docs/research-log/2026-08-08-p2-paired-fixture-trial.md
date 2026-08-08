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
- SwiftUI structured action source revision:
  `6bece16d4afaa099ba3cf068472ffee07ebadc50`.
- SwiftUI direct-state matrix source revision:
  `26d88823410a2c5486950fb5632e73eda636783f`.
- UIKit structured matrix source revision:
  `fdf29a1c831c45250825718ad16d25500ece4eeb`.
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

The four-state direct SwiftUI run is in
`pilot/swiftui-matrix-20260808-26d8882`. It contains the result bundle and 12
exported attachments for detail, form, modal, and long list. The Linux target
was absent before creation; all 87 files in the result bundle and attachment
directory matched local SHA-256 digests after copying.

The five-test UIKit run is in
`pilot/uikit-matrix-20260808-fdf29a1`. It contains the result bundle and 17
exported attachments for the five direct states plus the home-to-detail action
after-state. The Linux target was absent before creation; all 104 files in the
result bundle and attachment directory matched local SHA-256 digests after
copying.

## Implemented trial

The two independent application targets render `home`, `detail`, `form`,
`modal`, and `long_list` from the same tested state catalog. Both accept an
explicit screen and appearance launch argument, use one English and Simplified
Chinese string catalog, and give matching controls shared accessibility
identifiers across frameworks.

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

The SwiftUI action run added one transition after-state to the manifest, for 11
records at that stage, and one verified action pair. The initial-state recipe,
app, source
revision, device, runtime, viewport, orientation, locale, appearance, Dynamic
Type, and split match across the action pair. The selected simulator was
restored to its prior shutdown state after the run.

## Direct SwiftUI initial-state matrix

Four additional exact-destination tests launched detail in Simplified Chinese
light appearance, form in English dark appearance, modal in Simplified Chinese
dark appearance, and long list in English light appearance. All four tests
passed with zero failures. Each attached one structured snapshot, one lossless
1206 by 2622 screenshot, and one capture metadata record. The detail, form, long
list, and modal snapshots contained 32, 65, 131, and 20 nodes respectively.

Screenshot inspection found each expected screen and appearance with no blank
screen, crash, crop, or overlap. The four records are now
`execution_verified` in the pilot manifest and reference two new
research-only, non-redistributable license entries. Their element annotations
remain empty and their native-tree and compact representations still require
owner grounding review.

A bounded `XCUITestSnapshotParser` now converts the structured JSON attachments
into the same flattened native-node model used by the synthetic XML baseline.
It enforces byte, node, and depth limits, uses deterministic tree-path node IDs,
preserves accessibility identifiers separately, and leaves unknown numeric
element types as `unknown`. It does not infer visibility or visual truth from
accessibility geometry. The parser read the exact before and after attachments
as 43 and 32 nodes, matching the capture harness counts.

An optional `conservative` cleaning mode now provides the first paired cleaned
tree baseline while `raw` remains the default. It collapses only unknown-role,
semantic-empty, single-child wrappers when wrapper and child frames are exactly
equal. It deduplicates only exact sibling subtrees made entirely of unknown-role
nodes without labels, values, native identifiers, or meaningful state. Each run
reports input/output nodes, collapsed wrappers, removed duplicate subtrees and
nodes, plus separate cleaning time.

On the exact action evidence, home changed from 43 to 33 nodes and detail from
32 to 22 nodes. Each state collapsed 10 wrappers and removed no duplicate
subtree. The home action target stayed at
`(201, 408.8333333333333)`, and the detail primary action remained at
`(83.5, 358.5)`. These two states demonstrate deterministic behavior; they do
not establish recall, token, latency, or task-success improvement.

The committed two-state measurement reports canonical JSON decreasing from
46,291 to 36,079 bytes (22.06%) and compact UTF-8 decreasing from 19,137 to
15,105 bytes (21.07%). Unique and multiset action signatures, native
identifiers, semantic signatures, and nearest-semantic parent-child relation
multisets were equal in both comparisons. Exact timings are retained as raw
diagnostic measurements, but two warm invocations are not a latency benchmark.
Token counts remain unavailable until a tokenizer is pinned, and the structural
gates do not replace child-order, visual, or human grounding review.

The four direct initial-state trees add a broader diagnostic comparison.
Conservative cleaning changed 248 raw nodes to 155 nodes, collapsed 91 exact
wrappers, and removed two exact semantic-empty duplicate subtrees containing
two nodes. Canonical JSON decreased from 152,862 to 102,393 bytes (33.02%), and
compact UTF-8 decreased from 63,775 to 42,116 bytes (33.96%). All seven unique,
multiset, and normalized relation gates passed in all four comparisons. These
single-run measurements still do not establish token, latency, child-order,
reading-order, visual-grounding, or task-success gains.

## Structured UIKit initial-state matrix

The symmetric UIKit target ran five exact-destination tests with zero failures.
It exported one structured snapshot, one lossless 1206 by 2622 screenshot, and
one capture metadata record for each direct initial state. The home-to-detail
test also exported the after screenshot and hierarchy plus a verified action
record, for 17 attachments total. Direct detail, form, home, action-after
detail, long list, and modal snapshots contained 34, 35, 42, 34, 90, and 28
nodes respectively.

The home action resolved `fixture.home.open-detail` at frame 16 by 331.3333 by
370 by 34.3333 points. Its recorded center target was `(201, 348.5)`, and the
test required `fixture.detail.root` after the tap. Screenshot inspection found
the expected screens, content, locale, and appearance without blank screens,
crashes, cropping, or overlap. The English detail layout has tight spacing
between the `Source` label and `Synthetic fixture` value; this is retained as a
minor readability observation rather than treated as a capture failure.

Across all six UIKit trees, conservative cleaning changed 263 raw nodes to 214
nodes, collapsed 49 exact wrappers, and removed no duplicate subtree. Canonical
JSON decreased from 160,104 to 135,189 bytes (15.56%), and compact UTF-8
decreased from 63,733 to 53,959 bytes (15.34%). All seven unique, multiset, and
normalized relation gates passed in every comparison. The measurements are
single-run diagnostics and do not establish child-order, reading-order, token,
latency, visual-grounding, or task-success gains.

## Multiplicity failure and policy correction

The first multiset red test reproduced a concrete weakness in the earlier
cleaner: two identical labelled scrollbar subtrees became one while the three
unique-set gates all remained true. On the committed integration fixture, the
old policy changed seven nodes to four; semantic-signature multiplicity and
nearest-semantic parent-child multiplicity both failed.

Revision `67a4987033887cbd97b238da388d4cdefb127843` narrows duplicate removal to
semantic-empty subtrees. The same integration fixture now changes seven nodes to
six by collapsing one wrapper, preserves both labelled scrollbar instances, and
passes all seven gates. All 12 real SwiftUI and UIKit captures were then rerun
from their hash-verified external trees with that exact compiler revision; every
capture passed all seven gates. The lower reduction percentages above are the
cost of preserving the previously lost multiplicity.

## Human grounding review packet

The public `Docs/human-grounding-review-protocol.md` defines seven explicit
human criteria, a review-record shape, conflict handling, and a fail-closed
acceptance rule. A redistribution-withheld packet applies it to eight
representative records: UIKit and SwiftUI home, detail after the verified
action, long list, and modal. It includes the screenshot, source hierarchy,
raw and conservative canonical and compact states, telemetry, measurement,
review template, and hashes for each record.

The verified Linux packet is at artifact-root-relative path
`pilot/grounding-review-20260808-89c9858-v2`. It contains 107 files, its root
manifest covers 106 files, all eight per-record manifests pass, and the root
manifest SHA-256 is
`f7f1ebc7414a71f682ad3a5a51ca44b1c8e4c3f4d0fd6a4669b81b72807d86d0`.
Its packet manifest records eight pending records, both action pairs, project
revision `89c98586d290625cce4adb5b180ebea4e00cddf0`, compiler revision
`67a4987033887cbd97b238da388d4cdefb127843`, and `withheld` redistribution.

The first mirror omitted portable root paths: its root checksum file referred
to local absolute `/tmp` paths. That directory was preserved without overwrite
or deletion and now has a `SUPERSEDED-BY-v2.txt` marker. It is not acceptance
evidence. No review template in v2 has been completed, so the packet does not
change human-grounding status.

## Public artifact decision

The application code and fictional content are project-authored and covered by
the repository license. The screenshots also render Apple platform interface
materials and SF Symbols. The reviewed Apple materials describe intellectual
property ownership, trademark use, software-license restrictions, and a rights
request channel, but do not provide a sufficiently explicit basis to relicense
these rendered captures as public Apache-2.0 dataset assets.

The ledger therefore records both screenshot families, both action trials, and
the direct SwiftUI and UIKit matrix screenshots and native trees as
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
- The four direct-state SwiftUI XCUITests passed 4/4 on the exact destination,
  exported 12 attachments, and left the selected simulator in its prior
  shutdown state.
- The five UIKit XCUITests passed 5/5 on the exact destination, exported 17
  attachments, and left the selected simulator in its prior shutdown state.
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
  paired canonical states plus both action after-states, then runs semantic
  validation over all 12 records and both action pairs.
- Local and Linux read-back SHA-256 digests matched for all ten PNG files and
  both capture metadata files.
- Local and Linux read-back SHA-256 digests also matched for the five exported
  action attachments and their attachment manifest. The action directory was
  verified absent before creation, so no existing Linux artifact was
  overwritten.
- Local and Linux read-back SHA-256 digests matched for all 87 files in the
  direct-state result bundle and exported-attachment directory. Its Linux
  directory was also verified absent before creation.
- Local and Linux read-back SHA-256 digests matched for all 104 files in the
  UIKit result bundle and exported-attachment directory. Its Linux directory
  was also verified absent before creation.
- The withheld human-review v2 packet passed its 106-entry root checksum and
  all eight per-record checksums after Linux copying; every review remains
  explicitly pending.
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
- The structured UIKit action hashes are:
  - before hierarchy:
    `f220ffc5390499029560c9d1ba9364471cede8bac9292b3accdfc5d9c57e4087`
  - before screenshot:
    `815b338e204ce00880033db9fb01d8913adb7fa37309acfb3d250e778df90d30`
  - after hierarchy:
    `a878293bcfc8ab49ff28653155beb8b6f1ff6e50ab008a412486e8e68c7502e2`
  - after screenshot:
    `1eaf5380a976e07785194c3de35f850c2d07ad56d925dcfb1a757628bc590bd4`
  - action record:
    `0e8afb7b6f522dce63de5894591eae1652f109aa1aa87af5e46a96a9d5447d45`
  - exported-attachment manifest:
    `9713d869f71ec19b78f9f5365397a00b17b1e3f8051682a3d3b21a81be16e687`
- JSON syntax, property-list syntax, project syntax, shell syntax, strict Swift
  formatting, whitespace checks, and the prohibited provider-content scan
  passed.

## Known gaps

- All five initial records in each framework now have structured native
  hierarchy evidence. Each framework also has a second detail capture after a
  verified home-to-detail transition.
- The 12 committed annotation files still have empty element arrays; they are
  not completed manual annotations. Offline compilation now produces normalized
  elements from 12 structured captures across both frameworks, but those
  outputs have not been reviewed and backfilled into the annotations. The raw
  dictionaries remain evidence, not visual truth.
- Cleaning has synthetic counterexamples and 12 real captures across both
  frameworks and five initial states. All seven structural gates pass, while
  child-order validation, compact readability review, and token measurements
  remain open. Raw output is retained for every paired comparison.
- Owner review of native-tree evidence, element annotations, and compact states
  remains pending.

The trial now proves the paired build, launch, screenshot, storage, hash,
structured hierarchy, two verified actions, and draft-manifest path. It does
not yet satisfy human grounding acceptance or the P2 checkpoint.
