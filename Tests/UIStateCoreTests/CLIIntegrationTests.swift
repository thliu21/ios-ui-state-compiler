import Foundation
import Testing
import UIStateCore

@Suite("CLI offline integration", .serialized)
struct CLIIntegrationTests {
  @Test("Screenshot, tree, and hybrid inputs emit canonical JSON")
  func allInputModesEmitJSON() throws {
    let temporaryDirectory = try makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

    let screenshot = temporaryDirectory.appendingPathComponent("one-pixel.png")
    try onePixelPNG().write(to: screenshot)
    let tree = try fixtureURL(named: "native-tree", extension: "xml")

    let modes: [(name: String, arguments: [String], sources: [EvidenceSource], elementCount: Int)] =
      [
        (
          "screenshot-only",
          ["--screenshot", screenshot.path],
          [.screenshot],
          0
        ),
        (
          "tree-only",
          ["--tree", tree.path, "--image-size", "1170x2532"],
          [.uiTree],
          3
        ),
        (
          "hybrid",
          ["--screenshot", screenshot.path, "--tree", tree.path],
          [.screenshot, .uiTree],
          3
        ),
      ]

    for mode in modes {
      let result = try runCLI(
        commonCompileArguments(screenID: mode.name) + mode.arguments + ["--format", "json"]
      )
      try #require(result.status == 0, "\(mode.name): \(result.standardError)")

      let state = try UIStateCodec.decode(Data(result.standardOutput.utf8))
      let timing = try JSONDecoder().decode(
        OfflineCompileTimings.self,
        from: Data(result.standardError.utf8)
      )

      #expect(state.screen.id == mode.name)
      #expect(state.screen.sources == mode.sources)
      #expect(state.elements.count == mode.elementCount)
      #expect(timing.imageDecodeMS >= 0)
      #expect(timing.xmlParseMS >= 0)
      #expect(timing.serializationMS >= 0)
      #expect(timing.totalMS >= 0)
      #expect(!result.standardOutput.contains("serialization_ms"))

      if mode.name == "screenshot-only" || mode.name == "hybrid" {
        #expect(state.screen.imageSizePixels == UIStateSize(width: 1, height: 1))
      } else {
        #expect(state.screen.imageSizePixels == UIStateSize(width: 1_170, height: 2_532))
      }
    }
  }

  @Test("Compact output is byte-for-byte deterministic with a fixed timestamp")
  func compactOutputIsDeterministic() throws {
    let temporaryDirectory = try makeTemporaryDirectory()
    defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

    let screenshot = temporaryDirectory.appendingPathComponent("one-pixel.png")
    try onePixelPNG().write(to: screenshot)
    let tree = try fixtureURL(named: "native-tree", extension: "xml")
    let arguments =
      commonCompileArguments(screenID: "deterministic") + [
        "--screenshot", screenshot.path,
        "--tree", tree.path,
        "--format", "compact",
      ]

    let first = try runCLI(arguments)
    let second = try runCLI(arguments)
    var jsonArguments = arguments
    jsonArguments[jsonArguments.count - 1] = "json"
    let firstJSON = try runCLI(jsonArguments)
    let secondJSON = try runCLI(jsonArguments)

    try #require(first.status == 0, "first invocation failed")
    try #require(second.status == 0, "second invocation failed")
    try #require(firstJSON.status == 0, "first JSON invocation failed")
    try #require(secondJSON.status == 0, "second JSON invocation failed")
    #expect(first.standardOutput == second.standardOutput)
    #expect(firstJSON.standardOutput == secondJSON.standardOutput)
    #expect(first.standardOutput.contains("ui_state|schema=0.1.0"))
    #expect(first.standardOutput.contains("element|id=continue-button|role=button"))
  }
}

private struct CLIResult {
  let status: Int32
  let standardOutput: String
  let standardError: String
}

private func commonCompileArguments(screenID: String) -> [String] {
  [
    "compile",
    "--viewport-size", "390x844",
    "--captured-at", "2026-08-06T20:00:00Z",
    "--screen-id", screenID,
  ]
}

private func runCLI(_ arguments: [String]) throws -> CLIResult {
  let process = Process()
  let standardOutput = Pipe()
  let standardError = Pipe()
  process.executableURL = try executableURL()
  process.arguments = arguments
  process.standardOutput = standardOutput
  process.standardError = standardError

  try process.run()
  process.waitUntilExit()

  return CLIResult(
    status: process.terminationStatus,
    standardOutput: String(
      decoding: standardOutput.fileHandleForReading.readDataToEndOfFile(),
      as: UTF8.self
    ),
    standardError: String(
      decoding: standardError.fileHandleForReading.readDataToEndOfFile(),
      as: UTF8.self
    )
  )
}

private func executableURL() throws -> URL {
  var directory = Bundle.main.bundleURL

  for _ in 0..<8 {
    let candidate = directory.appendingPathComponent("ui-compiler")
    if FileManager.default.isExecutableFile(atPath: candidate.path) {
      return candidate
    }
    directory.deleteLastPathComponent()
  }

  let packageRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
  let buildDirectory = packageRoot.appendingPathComponent(".build")
  if let enumerator = FileManager.default.enumerator(
    at: buildDirectory,
    includingPropertiesForKeys: [.isExecutableKey],
    options: [.skipsHiddenFiles]
  ) {
    for case let candidate as URL in enumerator
    where candidate.lastPathComponent == "ui-compiler"
      && FileManager.default.isExecutableFile(atPath: candidate.path)
    {
      return candidate
    }
  }

  throw CLIIntegrationTestError.executableNotFound
}

private func fixtureURL(named name: String, extension fileExtension: String) throws -> URL {
  guard let url = Bundle.module.url(forResource: name, withExtension: fileExtension) else {
    throw CLIIntegrationTestError.fixtureNotFound
  }
  return url
}

private func makeTemporaryDirectory() throws -> URL {
  let directory = FileManager.default.temporaryDirectory
    .appendingPathComponent("ui-state-compiler-tests")
    .appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  return directory
}

private func onePixelPNG() throws -> Data {
  let base64 =
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
  guard let data = Data(base64Encoded: base64) else {
    throw CLIIntegrationTestError.invalidPNGFixture
  }
  return data
}

private enum CLIIntegrationTestError: Error {
  case executableNotFound
  case fixtureNotFound
  case invalidPNGFixture
}
