import Foundation
import Testing
import UIStateCore

@Suite("UI state Codable contract")
struct UIStateCodableTests {
  @Test("Minimal fixture preserves evidence, coordinates, and unknown values")
  func minimalFixtureRoundTrip() throws {
    let fixture = try #require(
      Bundle.module.url(
        forResource: "minimal-ui-state",
        withExtension: "json"
      ))
    let data = try Data(contentsOf: fixture)

    let state = try UIStateCodec.decode(data)
    let element = try #require(state.elements.first)
    let action = try #require(element.actions.first)

    #expect(state.schemaVersion == UIState.currentSchemaVersion)
    #expect(state.screen.sources == [.screenshot, .geometry])
    #expect(element.provenance == [.uiTree, .geometry])
    #expect(element.frames.first?.coordinateSpace == .screenPoints)
    #expect(action.verification == .treeDeclared)
    #expect(action.target?.coordinateSpace == .screenPoints)
    #expect(element.visible == nil)
    #expect(element.enabled == nil)
    #expect(element.selected == nil)

    let encoded = try UIStateCodec.encode(state, prettyPrinted: true)
    let roundTrip = try UIStateCodec.decode(encoded)
    let encodedObject = try #require(
      JSONSerialization.jsonObject(with: encoded) as? [String: Any]
    )
    let encodedScreen = try #require(encodedObject["screen"] as? [String: Any])
    let encodedElements = try #require(encodedObject["elements"] as? [[String: Any]])
    let encodedElement = try #require(encodedElements.first)

    #expect(roundTrip == state)
    #expect(
      Set(encodedObject.keys) == ["schema_version", "screen", "elements", "relations", "changes"])
    #expect(encodedScreen["image_size_pixels"] != nil)
    #expect(encodedScreen["viewport_size_points"] != nil)
    #expect(encodedElement["visible"] == nil)
    #expect(encodedElement["enabled"] == nil)
    #expect(encodedElement["selected"] == nil)
    #expect(roundTrip.elements.first?.visible == nil)
    #expect(roundTrip.elements.first?.enabled == nil)
    #expect(roundTrip.elements.first?.selected == nil)
  }

  @Test("All coordinate-space wire values round trip", arguments: CoordinateSpace.allCases)
  func coordinateSpaceRoundTrip(_ space: CoordinateSpace) throws {
    let data = try JSONEncoder().encode(space)
    let decoded = try JSONDecoder().decode(CoordinateSpace.self, from: data)

    #expect(decoded == space)
  }

  @Test("All action verification levels round trip", arguments: ActionVerification.allCases)
  func actionVerificationRoundTrip(_ verification: ActionVerification) throws {
    let data = try JSONEncoder().encode(verification)
    let decoded = try JSONDecoder().decode(ActionVerification.self, from: data)

    #expect(decoded == verification)
  }

  @Test("Unsupported schema versions fail decoding")
  func unsupportedVersionFails() throws {
    let fixture = try #require(
      Bundle.module.url(
        forResource: "minimal-ui-state",
        withExtension: "json"
      ))
    let source = try String(contentsOf: fixture, encoding: .utf8)
    let unsupported = source.replacingOccurrences(of: "0.1.0", with: "9.9.9")

    #expect(throws: DecodingError.self) {
      try UIStateCodec.decode(Data(unsupported.utf8))
    }
  }
}
