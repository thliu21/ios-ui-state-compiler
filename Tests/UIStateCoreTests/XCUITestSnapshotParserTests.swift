import Foundation
import Testing
import UIStateCore

@Suite("XCUITest snapshot parser")
struct XCUITestSnapshotParserTests {
  @Test("Normalizes structured snapshot fields and hierarchy")
  func parsesStructuredSnapshot() throws {
    let nodes = try XCUITestSnapshotParser().parse(try snapshotFixture())
    let root = try #require(nodes.first { $0.id == "xcui-0" })
    let button = try #require(nodes.first { $0.id == "xcui-0.0" })
    let text = try #require(nodes.first { $0.id == "xcui-0.0.0" })
    let frame = try #require(button.frame)

    #expect(nodes.count == 3)
    #expect(root.childIDs == ["xcui-0.0"])
    #expect(button.role == .button)
    #expect(button.label == "Open record detail")
    #expect(button.value == "Ready")
    #expect(button.nativeIdentifier == "fixture.home.open-detail")
    #expect(button.parentID == "xcui-0")
    #expect(button.childIDs == ["xcui-0.0.0"])
    #expect(button.enabled == true)
    #expect(button.visible == nil)
    #expect(button.selected == false)
    #expect(frame.coordinateSpace == .screenPoints)
    #expect(frame.x == 16)
    #expect(frame.y == 382.5)
    #expect(frame.width == 370)
    #expect(frame.height == 52)
    #expect(text.role == .staticText)
  }

  @Test("Byte, node, and depth limits fail before unbounded traversal")
  func resourceLimitsFailClosed() throws {
    let data = try snapshotFixture()

    #expect(
      throws: XCUITestSnapshotParserError.inputTooLarge(limit: data.count - 1)
    ) {
      try XCUITestSnapshotParser(
        limits: NativeTreeParserLimits(
          maximumInputBytes: data.count - 1,
          maximumNodeCount: 100,
          maximumDepth: 10
        )
      ).parse(data)
    }
    #expect(throws: XCUITestSnapshotParserError.nodeLimitExceeded(limit: 2)) {
      try XCUITestSnapshotParser(
        limits: NativeTreeParserLimits(
          maximumInputBytes: data.count,
          maximumNodeCount: 2,
          maximumDepth: 10
        )
      ).parse(data)
    }
    #expect(throws: XCUITestSnapshotParserError.depthLimitExceeded(limit: 2)) {
      try XCUITestSnapshotParser(
        limits: NativeTreeParserLimits(
          maximumInputBytes: data.count,
          maximumNodeCount: 100,
          maximumDepth: 2
        )
      ).parse(data)
    }
  }

  @Test("Malformed roots and invalid fields fail with stable errors")
  func invalidInputFailsClosed() throws {
    #expect(throws: XCUITestSnapshotParserError.malformedJSON) {
      try XCUITestSnapshotParser().parse(Data("{".utf8))
    }
    #expect(throws: XCUITestSnapshotParserError.invalidRoot) {
      try XCUITestSnapshotParser().parse(Data("[]".utf8))
    }

    let source = String(decoding: try snapshotFixture(), as: UTF8.self)
      .replacingOccurrences(of: "\"enabled\": true", with: "\"enabled\": \"yes\"")
    #expect(throws: XCUITestSnapshotParserError.invalidField(name: "enabled")) {
      try XCUITestSnapshotParser().parse(Data(source.utf8))
    }
  }

  private func snapshotFixture() throws -> Data {
    let url = try #require(
      Bundle.module.url(forResource: "xcuitest-snapshot", withExtension: "json")
    )
    return try Data(contentsOf: url)
  }
}
