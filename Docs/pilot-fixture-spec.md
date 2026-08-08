# Paired pilot fixture specification

Status: Accepted for implementation
Updated: 2026-08-08

## Objective

Build two independent iOS applications that present the same five synthetic UI
states: one implemented with SwiftUI and one with UIKit. The ten observations
form a controlled trial of the P2 capture and annotation contract before any
third-party application or artifact is admitted to the pilot.

The fixtures test framework differences, collection mechanics, and annotation
readability. They are not benchmark results and do not count as app-disjoint
evidence because both applications share one fixture family.

## Toolchain and platform

- Xcode 26.5 (build 17F42) and Swift 6.3.2.
- iOS 17.0 minimum deployment target.
- iOS Simulator 26.5 on the explicitly selected iPhone 17 Pro device.
- Programmatic UIKit and SwiftUI interfaces with no storyboards.
- No network, account, permission, third-party dependency, or third-party asset.

The SwiftUI target uses an `App` entry point and `NavigationStack`. The UIKit
target uses an application delegate, `UIWindow`, and `UINavigationController`.
These choices follow the current Apple framework contracts rather than adding a
compatibility layer that the research question does not need.

## State catalog

Each target exposes the same stable screen identifiers, visible seed content,
accessibility identifiers, and intended actions.

| Screen ID | Required structure | Intended research challenge |
| --- | --- | --- |
| `home` | Title, summary, status cards, detail navigation | Grouping and repeated labels |
| `detail` | Back navigation, metadata, primary action | Label/value association |
| `form` | Text input, toggle, picker, disabled submit | Control state and availability |
| `modal` | Background content and presented sheet | Presentation boundaries |
| `long_list` | Stable rows extending below the viewport | Scrolling and offscreen content |

The content is fictional and contains no personal account data. One decorative
symbol remains visually present but hidden from accessibility in both targets;
the visible adjacent text carries its meaning. This creates a deliberate visual
and native-tree difference without making an interactive control inaccessible.

## Deterministic launch contract

Both applications accept:

```text
--fixture-screen <home|detail|form|modal|long_list>
--fixture-appearance <light|dark>
```

Missing arguments select `home`. An unknown or incomplete value is a launch
configuration error in the shared parser. Appearance defaults to `light` when it
is omitted. Application entry points record errors and fall back to `home` in
light appearance so a collection run remains diagnosable.

All seed identities and ordering are constants. The fixtures do not use current
time, random values, persisted user defaults, or remote data. Relaunching the
same target with the same arguments must recreate the same semantic state.

## Locale and appearance

The applications use a shared string catalog for English and Simplified
Chinese. Source text remains centralized and translatable; UI code must not
assemble localizable sentences from fragments. Light and dark appearances use
system semantic colors so both can be captured without target-specific styling.

The first runnable increment verifies English in light appearance. Chinese and
dark captures remain required before this fixture trial is accepted.

## Accessibility and identity

- Every interactive control has a stable `fixture.<screen>.<element>`
  accessibility identifier.
- Matching elements use matching identifiers across UIKit and SwiftUI.
- List and card identity comes from fixture data, never array offsets.
- Icon-only interactive controls require an accessibility label.
- Decorative images are hidden from accessibility.
- Dynamic Type must not be disabled or replaced with fixed-size text.

## Repository structure

```text
Sources/PilotFixtureSupport/          shared pure state and launch contract
Tests/PilotFixtureSupportTests/       deterministic contract tests
Fixtures/PilotApps/PilotFixtures.xcodeproj
Fixtures/PilotApps/Shared/            string catalog and shared app data
Fixtures/PilotApps/SwiftUIFixture/    SwiftUI application target
Fixtures/PilotApps/UIKitFixture/      UIKit application target
```

The shared support module contains no framework UI code and remains testable
with SwiftPM on macOS. Each application target owns its rendering code so the
trial compares native framework structures rather than wrapper output.

## Verification

Implementation proceeds in independently verifiable increments:

1. Write failing tests for the five-state catalog and launch parser.
2. Implement the shared support module and pass focused and full Swift tests.
3. Build each application for the exact simulator destination.
4. Launch each screen directly, capture its screenshot and native hierarchy,
   and confirm the requested screen identity.
5. Compare paired states for visible content and accessibility identifiers.
6. Request human review of representative screenshot, tree, and compact state.

Simulator commands always name the selected device UDID. They must not use a
global shutdown command or operate an unrelated device.

## Trial acceptance

The fixture trial is accepted only when:

- Both targets build without third-party dependencies.
- All five screen arguments produce the intended state in both targets.
- English, Simplified Chinese, light, and dark coverage is recorded.
- The ten records pass manifest and license-ledger validation.
- Screenshot and hierarchy timestamps, hashes, and provenance are preserved.
- At least one verified action-before/action-after pair is recorded.
- Human review confirms that the canonical and compact states remain readable
  and grounded in the captured evidence.

Raw captures remain local until their self-authored provenance and redistribution
decision are represented in the license ledger.

## Primary framework references

- [SwiftUI `App`](https://developer.apple.com/documentation/swiftui/app)
- [SwiftUI `NavigationStack`](https://developer.apple.com/documentation/swiftui/navigationstack)
- [UIKit application delegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate)
- [UIKit navigation controller](https://developer.apple.com/documentation/uikit/uinavigationcontroller)
- [Localizing text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog)
- [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)
