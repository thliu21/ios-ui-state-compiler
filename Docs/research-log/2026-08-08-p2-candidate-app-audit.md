# P2 candidate app audit: first pass

Date: 2026-08-08
Status: Candidate screening only; no third-party artifacts collected

## Question

Which UIKit and SwiftUI applications are suitable for the first pilot without
creating avoidable licensing, reproducibility, entitlement, or storage risk?

## Method

This pass used only each project's GitHub repository, README, license file,
current default-branch revision, and repository metadata. No candidate was cloned,
built, run, or included in the dataset. Repository sizes below are GitHub's
reported `size` field and are not download estimates; dependency and large-file
downloads can increase local use.

## Findings

| Candidate | Framework evidence | Revision reviewed | Source-code terms | Operational finding | Initial decision |
| --- | --- | --- | --- | --- | --- |
| Self-authored fixture pair | One UIKit app and one SwiftUI app by construction | Not yet created | Project Apache-2.0 | Can use seeded local content, matched screens, explicit accessibility gaps, and no third-party assets | Proceed first for five-screen annotation trial |
| [Foqos](https://github.com/awaseem/foqos) | README identifies SwiftUI views and SwiftUI technology | `b5a9568e2d3ba8e6bbc5831c90db6958d8790ec3` | [MIT](https://github.com/awaseem/foqos/blob/main/LICENSE) | About 28.8 MiB reported, but local development requires Screen Time and NFC entitlements; asset and mark coverage is not yet reviewed | Candidate only; not in first build batch |
| [isowords](https://github.com/pointfreeco/isowords) | README identifies a SwiftUI app and preview applications | `c727d3a7c49cf0c98f2fa4f24c562f81e30165f7` | [Custom education-focused terms](https://github.com/pointfreeco/isowords/blob/main/LICENSE.md) | Base repository reports about 3.7 MiB but requires large-file assets; the license restricts the complete software to educational, noncommercial use and restricts redistribution | Exclude from main pilot; research-only isolation if ever approved |
| [Kickstarter iOS](https://github.com/kickstarter/ios-oss) | Current Swift source contains SwiftUI; the mature app also provides native snapshot coverage | `b0ad9f20c53fe9728ba47ec4c01b7c9e0acff7f0` | [Apache-2.0](https://github.com/kickstarter/ios-oss/blob/main/LICENSE) | About 3.55 GiB reported; README documents hard-coded mock data and nearly 600 snapshots, but its listed Xcode baseline is old and nested screenshots, marks, assets, and notices need review | High-value later candidate; do not clone yet |
| [Wikipedia iOS](https://github.com/wikimedia/wikipedia-ios) | Current Swift source imports both UIKit and SwiftUI | `61f1533dd7d803d9f7bb73b1e81f0cd624f5751f` | [MIT](https://github.com/wikimedia/wikipedia-ios/blob/main/LICENSE.txt) | About 1.35 GiB reported; setup installs tools, multiple schemes use remote services, and article views include web components; content and trademark terms remain separate | Possible mixed-framework held-out app after nested review |

## Source-to-decision log

| Question | Primary source | Finding | Impact | Confidence |
| --- | --- | --- | --- | --- |
| Can Foqos run as a low-friction SwiftUI fixture? | [Foqos README](https://github.com/awaseem/foqos#requirements) | The project requires developer-account entitlements for key Screen Time and NFC paths | It is not the first reproducible fixture despite a permissive source license | High |
| Is isowords commercially compatible with the main pipeline? | [isowords license](https://github.com/pointfreeco/isowords/blob/main/LICENSE.md) | The complete software is limited to educational/noncommercial use and has redistribution restrictions | Main-pipeline use is rejected under the current governance contract | High |
| Does Kickstarter provide stable seeded states? | [Kickstarter README](https://github.com/kickstarter/ios-oss#readme) | It documents an open-source mock mode with hard-coded data and an extensive snapshot corpus | Strong later candidate if build and nested rights review pass | Medium; not built locally |
| Is Wikipedia a simple offline UIKit held-out app? | [Wikipedia iOS README](https://github.com/wikimedia/wikipedia-ios#building-and-running) | It is buildable on Simulator, but schemes use remote services and several views rely on web components | Treat as mixed and network-sensitive, not a simple offline UIKit baseline | High for architecture boundary; not built locally |

## Decision

Create a small self-authored fixture pair before cloning any external candidate.
The pair should expose the same seeded content through UIKit and SwiftUI while
including a few deliberate differences: unlabeled icon, nested list rows,
disabled state, sheet or dialog, scroll boundary, and one screenshot/tree
disagreement. This supports annotation and compiler tests without claiming
real-world framework generalization.

External apps remain necessary for held-out validity. Their inclusion requires a
separate pinned build check, nested asset and trademark review, deterministic
state recipe, and raw-artifact redistribution decision.

## Next action

Specify the two fixture apps and five representative screens. Do not begin the
50-screen collection until the owner reviews those five annotations and the
validator accepts their draft manifest.
