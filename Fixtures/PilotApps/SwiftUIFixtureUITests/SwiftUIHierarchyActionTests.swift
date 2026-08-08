import Foundation
import XCTest

@MainActor
final class SwiftUIHierarchyActionTests: XCTestCase {
  func testHomeToDetailProducesStructuredEvidence() throws {
    let app = XCUIApplication()
    app.launchArguments = [
      "--fixture-screen", "home",
      "--fixture-appearance", "light",
      "-AppleLanguages", "(en)",
      "-AppleLocale", "en",
    ]
    app.launch()

    let homeRoot = app.descendants(matching: .any)["fixture.home.root"]
    XCTAssertTrue(homeRoot.waitForExistence(timeout: 5))

    let detailButton = app.buttons["fixture.home.open-detail"]
    XCTAssertTrue(detailButton.waitForExistence(timeout: 5))
    XCTAssertTrue(detailButton.isHittable)

    try attachHierarchy(of: app, named: "before-home-hierarchy.json")
    attachScreenshot(of: app, named: "before-home-screenshot.png")

    let targetFrame = detailButton.frame
    let target: [String: Any] = [
      "x": targetFrame.midX,
      "y": targetFrame.midY,
      "coordinate_space": "screen_points",
    ]
    detailButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

    let detailRoot = app.descendants(matching: .any)["fixture.detail.root"]
    XCTAssertTrue(detailRoot.waitForExistence(timeout: 5))

    let verifiedAt = ISO8601DateFormatter().string(from: Date())
    try attachHierarchy(of: app, named: "after-detail-hierarchy.json")
    attachScreenshot(of: app, named: "after-detail-screenshot.png")
    try attachJSON(
      [
        "schema_version": "0.1.0",
        "pair_id": "swiftui-home-to-detail",
        "before_record_id": "paired-swiftui-home",
        "after_record_id": "paired-swiftui-detail-after-home-action",
        "action_type": "tap",
        "target_identifier": "fixture.home.open-detail",
        "target": target,
        "outcome_identifier": "fixture.detail.root",
        "verified_at": verifiedAt,
      ],
      named: "home-to-detail-action.json"
    )
  }

  private func attachHierarchy(of app: XCUIApplication, named name: String) throws {
    let snapshot = try app.snapshot()
    try attachJSON(snapshot.dictionaryRepresentation, named: name)
  }

  private func attachScreenshot(of app: XCUIApplication, named name: String) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func attachJSON(_ object: Any, named name: String) throws {
    let data = try JSONSerialization.data(
      withJSONObject: object,
      options: [.prettyPrinted, .sortedKeys]
    )
    let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}
