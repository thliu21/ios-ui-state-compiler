import Foundation
import Testing
import UIStateCore

@Suite("Offline compiler boundaries")
struct OfflineCompilerTests {
  @Test("Compilation requires at least one evidence input")
  func missingInputFails() {
    let request = OfflineCompileRequest(
      screenID: "missing-input",
      capturedAt: Date(timeIntervalSince1970: 0),
      viewportSizePoints: UIStateSize(width: 390, height: 844)
    )

    #expect(throws: OfflineCompilerError.missingInput) {
      try OfflineCompiler().compile(request)
    }
  }

  @Test("Invalid image bytes fail without producing a partial state")
  func invalidImageFails() {
    let request = OfflineCompileRequest(
      screenID: "invalid-image",
      capturedAt: Date(timeIntervalSince1970: 0),
      screenshotData: Data("not an image".utf8),
      viewportSizePoints: UIStateSize(width: 390, height: 844)
    )

    #expect(throws: OfflineCompilerError.invalidImageData) {
      try OfflineCompiler().compile(request)
    }
  }

  @Test("Screenshot byte limits fail before image decoding")
  func screenshotByteLimitFails() {
    let request = OfflineCompileRequest(
      screenID: "oversized-image",
      capturedAt: Date(timeIntervalSince1970: 0),
      screenshotData: Data([0, 1]),
      viewportSizePoints: UIStateSize(width: 390, height: 844)
    )
    let limits = OfflineCompilerLimits(maximumScreenshotBytes: 1, maximumImagePixelCount: 100)

    #expect(throws: OfflineCompilerError.screenshotTooLarge(limit: 1)) {
      try OfflineCompiler(limits: limits).compile(request)
    }
  }

  @Test("Structured XCUITest JSON compiles through the native-tree model")
  func xcuiTestJSONCompiles() throws {
    let request = OfflineCompileRequest(
      screenID: "xcuitest-json",
      capturedAt: Date(timeIntervalSince1970: 1),
      xcuiTestSnapshotJSON: try snapshotFixture(),
      imageSizePixels: UIStateSize(width: 1_206, height: 2_622),
      viewportSizePoints: UIStateSize(width: 402, height: 874),
      treeCapturedAt: Date(timeIntervalSince1970: 0)
    )

    let result = try OfflineCompiler().compile(request)
    let button = try #require(
      result.state.elements.first {
        $0.nativeIdentifier == "fixture.home.open-detail"
      }
    )

    #expect(result.state.screen.sources == [.uiTree])
    #expect(result.state.screen.treeAgeMS == 1_000)
    #expect(result.state.elements.count == 3)
    #expect(button.role == .button)
    #expect(button.actions.first?.target?.x == 201)
    #expect(button.actions.first?.target?.y == 408.5)
    #expect(result.timings.xcuiTestJSONParseMS >= 0)
    #expect(result.timings.xmlParseMS == 0)
  }

  @Test("Two native-tree formats fail instead of silently choosing one")
  func conflictingNativeTreeInputsFail() throws {
    let request = OfflineCompileRequest(
      screenID: "conflicting-tree-inputs",
      capturedAt: Date(timeIntervalSince1970: 0),
      nativeTreeXML: Data("<Application/>".utf8),
      xcuiTestSnapshotJSON: try snapshotFixture(),
      imageSizePixels: UIStateSize(width: 1_206, height: 2_622),
      viewportSizePoints: UIStateSize(width: 402, height: 874)
    )

    #expect(throws: OfflineCompilerError.conflictingNativeTreeInputs) {
      try OfflineCompiler().compile(request)
    }
  }

  @Test("Timing decoder preserves measurements written before JSON tree support")
  func olderTimingDataDecodes() throws {
    let data = Data(
      """
      {
        "image_decode_ms": 1,
        "xml_parse_ms": 2,
        "serialization_ms": 3,
        "total_ms": 6
      }
      """.utf8
    )

    let timing = try JSONDecoder().decode(OfflineCompileTimings.self, from: data)

    #expect(timing.imageDecodeMS == 1)
    #expect(timing.xmlParseMS == 2)
    #expect(timing.xcuiTestJSONParseMS == 0)
    #expect(timing.treeCleaningMS == 0)
    #expect(timing.serializationMS == 3)
    #expect(timing.totalMS == 6)
  }

  @Test("Conservative cleaning is explicit and reports every removed node")
  func conservativeCleaningIsMeasured() throws {
    let data = try fixture(named: "xcuitest-cleaning-snapshot")
    let raw = try OfflineCompiler().compile(
      OfflineCompileRequest(
        screenID: "raw-tree",
        capturedAt: Date(timeIntervalSince1970: 0),
        xcuiTestSnapshotJSON: data,
        imageSizePixels: UIStateSize(width: 1_206, height: 2_622),
        viewportSizePoints: UIStateSize(width: 402, height: 874)
      )
    )
    let cleaned = try OfflineCompiler().compile(
      OfflineCompileRequest(
        screenID: "cleaned-tree",
        capturedAt: Date(timeIntervalSince1970: 0),
        xcuiTestSnapshotJSON: data,
        imageSizePixels: UIStateSize(width: 1_206, height: 2_622),
        viewportSizePoints: UIStateSize(width: 402, height: 874),
        nativeTreeCleaning: .conservative
      )
    )

    #expect(raw.state.elements.count == 7)
    #expect(raw.treeCleaning.mode == .raw)
    #expect(raw.treeCleaning.inputNodeCount == 7)
    #expect(raw.treeCleaning.outputNodeCount == 7)
    #expect(raw.timings.treeCleaningMS == 0)

    #expect(cleaned.state.elements.count == 4)
    #expect(cleaned.treeCleaning.mode == .conservative)
    #expect(cleaned.treeCleaning.inputNodeCount == 7)
    #expect(cleaned.treeCleaning.outputNodeCount == 4)
    #expect(cleaned.treeCleaning.collapsedWrapperCount == 1)
    #expect(cleaned.treeCleaning.removedDuplicateSubtreeCount == 1)
    #expect(cleaned.treeCleaning.removedDuplicateNodeCount == 2)
    #expect(cleaned.timings.treeCleaningMS >= 0)
  }

  private func snapshotFixture() throws -> Data {
    try fixture(named: "xcuitest-snapshot")
  }

  private func fixture(named name: String) throws -> Data {
    let url = try #require(
      Bundle.module.url(forResource: name, withExtension: "json")
    )
    return try Data(contentsOf: url)
  }
}
