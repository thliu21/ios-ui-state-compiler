// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "UIStateCompiler",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .library(name: "UIStateCore", targets: ["UIStateCore"]),
    .executable(name: "ui-compiler", targets: ["UICompilerCLI"]),
  ],
  targets: [
    .target(name: "UIStateCore"),
    .executableTarget(
      name: "UICompilerCLI",
      dependencies: ["UIStateCore"]
    ),
    .testTarget(
      name: "UIStateCoreTests",
      dependencies: ["UIStateCore"]
    ),
  ]
)
