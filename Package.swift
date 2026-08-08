// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "UIStateCompiler",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .library(name: "PilotFixtureSupport", targets: ["PilotFixtureSupport"]),
    .library(name: "UIStateCore", targets: ["UIStateCore"]),
    .executable(name: "ui-compiler", targets: ["UICompilerCLI"]),
  ],
  targets: [
    .target(name: "PilotFixtureSupport"),
    .target(name: "UIStateCore"),
    .executableTarget(
      name: "UICompilerCLI",
      dependencies: ["UIStateCore"]
    ),
    .testTarget(
      name: "PilotFixtureSupportTests",
      dependencies: ["PilotFixtureSupport"]
    ),
    .testTarget(
      name: "UIStateCoreTests",
      dependencies: ["UIStateCore"],
      resources: [.process("Fixtures")]
    ),
  ]
)
