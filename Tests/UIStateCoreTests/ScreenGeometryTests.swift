import Testing
import UIStateCore

@Suite("Screen geometry")
struct ScreenGeometryTests {
  @Test("All coordinate spaces remain explicit in public geometry values")
  func coordinateSpacesAreExplicit() throws {
    let visionRect = try CoordinateRect<VisionNormalizedSpace>(
      x: 0.1,
      y: 0.2,
      width: 0.3,
      height: 0.4
    )
    let pixelPoint = try CoordinatePoint<ImagePixelSpace>(x: 100, y: 200)
    let screenPoint = try CoordinatePoint<ScreenPointSpace>(x: 50, y: 75)
    let actionPoint = try ActionPoint1000(x: 500, y: 750)

    #expect(visionRect.coordinateSpace == .visionNormalized)
    #expect(pixelPoint.coordinateSpace == .imagePixels)
    #expect(screenPoint.coordinateSpace == .screenPoints)
    #expect(actionPoint.coordinateSpace == .action1000)
  }

  @Test("Invalid image and viewport dimensions fail at construction")
  func invalidDimensionsFail() {
    #expect(throws: GeometryError.invalidSize(space: .imagePixels)) {
      try CoordinateSize<ImagePixelSpace>(width: 0, height: 844)
    }
    #expect(throws: GeometryError.invalidSize(space: .screenPoints)) {
      try CoordinateSize<ScreenPointSpace>(width: 390, height: .infinity)
    }
    #expect(throws: GeometryError.invalidPoint(space: .action1000)) {
      try ActionPoint1000(x: 1_001, y: 500)
    }
    #expect(throws: GeometryError.invalidRectangle(space: .screenPoints)) {
      try CoordinateRect<ScreenPointSpace>(x: 0, y: 0, width: -1, height: 20)
    }
  }

  @Test("Vision rectangles flip their vertical origin and round trip")
  func visionRectangleRoundTrip() throws {
    let geometry = try ScreenGeometry(
      imageSize: CoordinateSize<ImagePixelSpace>(width: 1_000, height: 2_000),
      viewportSize: CoordinateSize<ScreenPointSpace>(width: 500, height: 1_000)
    )
    let source = try CoordinateRect<VisionNormalizedSpace>(
      x: 0.1,
      y: 0.2,
      width: 0.3,
      height: 0.4
    )

    let pixels = try geometry.imagePixels(from: source)
    let roundTrip = try geometry.visionNormalized(from: pixels)

    expectApproximatelyEqual(pixels.x, 100)
    expectApproximatelyEqual(pixels.y, 800)
    expectApproximatelyEqual(pixels.width, 300)
    expectApproximatelyEqual(pixels.height, 800)
    expectApproximatelyEqual(roundTrip.x, source.x)
    expectApproximatelyEqual(roundTrip.y, source.y)
    expectApproximatelyEqual(roundTrip.width, source.width)
    expectApproximatelyEqual(roundTrip.height, source.height)
  }

  @Test("Logical points use independent horizontal and vertical scales")
  func nonuniformPointScaleRoundTrip() throws {
    let geometry = try ScreenGeometry(
      imageSize: CoordinateSize<ImagePixelSpace>(width: 1_200, height: 1_800),
      viewportSize: CoordinateSize<ScreenPointSpace>(width: 400, height: 800)
    )
    let source = try CoordinateRect<ScreenPointSpace>(
      x: 10,
      y: 20,
      width: 100,
      height: 40
    )

    let pixels = try geometry.imagePixels(from: source)
    let roundTrip = try geometry.screenPoints(from: pixels)

    expectApproximatelyEqual(pixels.x, 30)
    expectApproximatelyEqual(pixels.y, 45)
    expectApproximatelyEqual(pixels.width, 300)
    expectApproximatelyEqual(pixels.height, 90)
    expectApproximatelyEqual(roundTrip.x, source.x)
    expectApproximatelyEqual(roundTrip.y, source.y)
    expectApproximatelyEqual(roundTrip.width, source.width)
    expectApproximatelyEqual(roundTrip.height, source.height)
  }

  @Test("Action coordinates round to nearest or away from zero")
  func actionCoordinateRoundTrip() throws {
    let geometry = try ScreenGeometry(
      imageSize: CoordinateSize<ImagePixelSpace>(width: 1_170, height: 2_532),
      viewportSize: CoordinateSize<ScreenPointSpace>(width: 390, height: 844)
    )
    let source = try CoordinatePoint<ScreenPointSpace>(x: 130.065, y: 422)

    let action = try geometry.action1000(from: source)
    let roundTrip = try geometry.screenPoints(from: action)

    #expect(action.x == 334)
    #expect(action.y == 500)
    #expect(abs(roundTrip.x - source.x) <= (390.0 / 2_000) + 1e-9)
    #expect(abs(roundTrip.y - source.y) <= (844.0 / 2_000) + 1e-9)
  }
}

private func expectApproximatelyEqual(
  _ actual: Double,
  _ expected: Double,
  tolerance: Double = 1e-9
) {
  #expect(abs(actual - expected) <= tolerance)
}
