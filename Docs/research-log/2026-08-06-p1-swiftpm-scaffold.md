# P1 SwiftPM scaffold — 2026-08-06

## Decision

The initial package has one reusable library product, one executable product,
and one test target:

```text
UIStateCore      library and tested command logic
ui-compiler      executable backed by UICompilerCLI
UIStateCoreTests Swift Testing target
```

The manifest declares Swift tools 6.2, Swift 6 language mode through that tools
version, and macOS 15 as the minimum platform. The implementation is validated
on Swift 6.3.2 and Xcode 26.5. There are no package dependencies.

Swift source is formatted and linted with the formatter bundled in the recorded
toolchain, using its default two-space indentation.

Swift Package Manager documents that products expose library or executable
artifacts and targets compile source modules or test suites. Swift Testing is
kept only in the test target, consistent with the documented linking boundary.

Sources:

- https://docs.swift.org/swiftpm/documentation/packagedescription/package/
- https://docs.swift.org/swiftpm/documentation/packagedescription/target/
- https://developer.apple.com/documentation/testing/definingtests

## Test-first evidence

The first test run failed because `CLICommand` and `CLIParser` did not exist. The
minimal parser then passed three parameterized cases for no argument, `--help`,
and `--version`.

A second failing test established exact help and version text before `CLIText`
was implemented and connected to the executable.

## Acceptance results

```text
swift build                         passed
swift test                          passed: 3 tests, 5 cases
swift run ui-compiler --help        passed
swift run ui-compiler --version     passed
```

The CLI currently exposes only help and version. Image parsing, tree parsing,
schema encoding, and geometry are intentionally outside this slice.
