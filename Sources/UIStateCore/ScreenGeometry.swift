/// Coordinate spaces supported by the canonical UI-state geometry contract.
public enum CoordinateSpace: String, CaseIterable, Codable, Sendable {
  case visionNormalized = "vision_normalized"
  case imagePixels = "image_pixels"
  case screenPoints = "screen_points"
  case action1000 = "action_1000"
}

/// A type-level marker for a coordinate space.
public protocol CoordinateSpaceMarker: Sendable {
  static var coordinateSpace: CoordinateSpace { get }
}

public enum VisionNormalizedSpace: CoordinateSpaceMarker {
  public static let coordinateSpace = CoordinateSpace.visionNormalized
}

public enum ImagePixelSpace: CoordinateSpaceMarker {
  public static let coordinateSpace = CoordinateSpace.imagePixels
}

public enum ScreenPointSpace: CoordinateSpaceMarker {
  public static let coordinateSpace = CoordinateSpace.screenPoints
}

/// Structured failures produced while validating or converting geometry.
public enum GeometryError: Error, Equatable, Sendable {
  case invalidPoint(space: CoordinateSpace)
  case invalidRectangle(space: CoordinateSpace)
  case invalidSize(space: CoordinateSpace)
}

/// A finite point whose generic marker prevents accidental cross-space use.
public struct CoordinatePoint<Space: CoordinateSpaceMarker>: Equatable, Sendable {
  public let x: Double
  public let y: Double

  public var coordinateSpace: CoordinateSpace { Space.coordinateSpace }

  public init(x: Double, y: Double) throws {
    guard x.isFinite, y.isFinite else {
      throw GeometryError.invalidPoint(space: Space.coordinateSpace)
    }

    self.x = x
    self.y = y
  }
}

/// A finite rectangle with non-negative dimensions and an explicit space.
public struct CoordinateRect<Space: CoordinateSpaceMarker>: Equatable, Sendable {
  public let x: Double
  public let y: Double
  public let width: Double
  public let height: Double

  public var coordinateSpace: CoordinateSpace { Space.coordinateSpace }

  public init(x: Double, y: Double, width: Double, height: Double) throws {
    guard
      x.isFinite,
      y.isFinite,
      width.isFinite,
      height.isFinite,
      width >= 0,
      height >= 0
    else {
      throw GeometryError.invalidRectangle(space: Space.coordinateSpace)
    }

    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }
}

/// Positive finite dimensions in a declared coordinate space.
public struct CoordinateSize<Space: CoordinateSpaceMarker>: Equatable, Sendable {
  public let width: Double
  public let height: Double

  public var coordinateSpace: CoordinateSpace { Space.coordinateSpace }

  public init(width: Double, height: Double) throws {
    guard width.isFinite, height.isFinite, width > 0, height > 0 else {
      throw GeometryError.invalidSize(space: Space.coordinateSpace)
    }

    self.width = width
    self.height = height
  }
}

/// Integer executor coordinates in the inclusive `0...1000` transport range.
public struct ActionPoint1000: Equatable, Sendable {
  public let x: Int
  public let y: Int

  public var coordinateSpace: CoordinateSpace { .action1000 }

  public init(x: Int, y: Int) throws {
    guard (0...1_000).contains(x), (0...1_000).contains(y) else {
      throw GeometryError.invalidPoint(space: .action1000)
    }

    self.x = x
    self.y = y
  }
}

/// Converts geometry using the image and logical viewport sizes captured for a screen.
public struct ScreenGeometry: Equatable, Sendable {
  public let imageSize: CoordinateSize<ImagePixelSpace>
  public let viewportSize: CoordinateSize<ScreenPointSpace>

  public init(
    imageSize: CoordinateSize<ImagePixelSpace>,
    viewportSize: CoordinateSize<ScreenPointSpace>
  ) {
    self.imageSize = imageSize
    self.viewportSize = viewportSize
  }

  /// Converts a bottom-left Vision rectangle into top-left physical pixels.
  public func imagePixels(
    from rect: CoordinateRect<VisionNormalizedSpace>
  ) throws -> CoordinateRect<ImagePixelSpace> {
    try CoordinateRect<ImagePixelSpace>(
      x: rect.x * imageSize.width,
      y: (1 - rect.y - rect.height) * imageSize.height,
      width: rect.width * imageSize.width,
      height: rect.height * imageSize.height
    )
  }

  /// Converts a top-left pixel rectangle back into bottom-left Vision coordinates.
  public func visionNormalized(
    from rect: CoordinateRect<ImagePixelSpace>
  ) throws -> CoordinateRect<VisionNormalizedSpace> {
    let normalizedHeight = rect.height / imageSize.height

    return try CoordinateRect<VisionNormalizedSpace>(
      x: rect.x / imageSize.width,
      y: 1 - (rect.y / imageSize.height) - normalizedHeight,
      width: rect.width / imageSize.width,
      height: normalizedHeight
    )
  }

  /// Converts logical points into pixels with independent horizontal and vertical scales.
  public func imagePixels(
    from rect: CoordinateRect<ScreenPointSpace>
  ) throws -> CoordinateRect<ImagePixelSpace> {
    let scaleX = imageSize.width / viewportSize.width
    let scaleY = imageSize.height / viewportSize.height

    return try CoordinateRect<ImagePixelSpace>(
      x: rect.x * scaleX,
      y: rect.y * scaleY,
      width: rect.width * scaleX,
      height: rect.height * scaleY
    )
  }

  /// Converts physical pixels into logical points with independent scales.
  public func screenPoints(
    from rect: CoordinateRect<ImagePixelSpace>
  ) throws -> CoordinateRect<ScreenPointSpace> {
    let scaleX = imageSize.width / viewportSize.width
    let scaleY = imageSize.height / viewportSize.height

    return try CoordinateRect<ScreenPointSpace>(
      x: rect.x / scaleX,
      y: rect.y / scaleY,
      width: rect.width / scaleX,
      height: rect.height / scaleY
    )
  }

  /// Converts logical points into integer-valued normalized executor coordinates.
  ///
  /// Values are rounded to the nearest integer, with exact ties rounded away
  /// from zero. Canonical geometry is not clamped to executor bounds here.
  public func action1000(
    from point: CoordinatePoint<ScreenPointSpace>
  ) throws -> ActionPoint1000 {
    let roundedX = (point.x / viewportSize.width * 1_000).rounded(.toNearestOrAwayFromZero)
    let roundedY = (point.y / viewportSize.height * 1_000).rounded(.toNearestOrAwayFromZero)

    guard let x = Int(exactly: roundedX), let y = Int(exactly: roundedY) else {
      throw GeometryError.invalidPoint(space: .action1000)
    }

    return try ActionPoint1000(x: x, y: y)
  }

  /// Converts normalized executor coordinates back into logical points.
  public func screenPoints(
    from point: ActionPoint1000
  ) throws -> CoordinatePoint<ScreenPointSpace> {
    try CoordinatePoint<ScreenPointSpace>(
      x: Double(point.x) / 1_000 * viewportSize.width,
      y: Double(point.y) / 1_000 * viewportSize.height
    )
  }
}
