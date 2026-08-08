import Foundation
import ImageIO

public enum OfflineCompilerError: Error, Equatable, Sendable {
  case missingInput
  case conflictingNativeTreeInputs
  case missingImageSize
  case invalidImageData
  case screenshotTooLarge(limit: Int)
  case imageDimensionsTooLarge(limit: Int)
  case invalidScreenMetadata
}

/// Resource ceilings applied before decoding screenshot pixels.
public struct OfflineCompilerLimits: Equatable, Sendable {
  public static let `default` = OfflineCompilerLimits(
    maximumScreenshotBytes: 64 * 1_024 * 1_024,
    maximumImagePixelCount: 100_000_000
  )

  public let maximumScreenshotBytes: Int
  public let maximumImagePixelCount: Int

  public init(maximumScreenshotBytes: Int, maximumImagePixelCount: Int) {
    self.maximumScreenshotBytes = maximumScreenshotBytes
    self.maximumImagePixelCount = maximumImagePixelCount
  }
}

/// Saved evidence and capture metadata for one deterministic offline compile.
public struct OfflineCompileRequest: Sendable {
  public let screenID: String
  public let capturedAt: Date
  public let treeCapturedAt: Date?
  public let screenshotData: Data?
  public let nativeTreeXML: Data?
  public let xcuiTestSnapshotJSON: Data?
  public let imageSizePixels: UIStateSize?
  public let viewportSizePoints: UIStateSize
  public let orientation: ScreenOrientation

  public init(
    screenID: String,
    capturedAt: Date,
    screenshotData: Data? = nil,
    nativeTreeXML: Data? = nil,
    xcuiTestSnapshotJSON: Data? = nil,
    imageSizePixels: UIStateSize? = nil,
    viewportSizePoints: UIStateSize,
    orientation: ScreenOrientation = .unknown,
    treeCapturedAt: Date? = nil
  ) {
    self.screenID = screenID
    self.capturedAt = capturedAt
    self.treeCapturedAt = treeCapturedAt
    self.screenshotData = screenshotData
    self.nativeTreeXML = nativeTreeXML
    self.xcuiTestSnapshotJSON = xcuiTestSnapshotJSON
    self.imageSizePixels = imageSizePixels
    self.viewportSizePoints = viewportSizePoints
    self.orientation = orientation
  }
}

/// Monotonic elapsed times kept separate from deterministic representation output.
public struct OfflineCompileTimings: Equatable, Codable, Sendable {
  public let imageDecodeMS: Double
  public let xmlParseMS: Double
  public let xcuiTestJSONParseMS: Double
  public let serializationMS: Double
  public let totalMS: Double

  public init(
    imageDecodeMS: Double,
    xmlParseMS: Double,
    xcuiTestJSONParseMS: Double = 0,
    serializationMS: Double,
    totalMS: Double
  ) {
    self.imageDecodeMS = imageDecodeMS
    self.xmlParseMS = xmlParseMS
    self.xcuiTestJSONParseMS = xcuiTestJSONParseMS
    self.serializationMS = serializationMS
    self.totalMS = totalMS
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    imageDecodeMS = try values.decode(Double.self, forKey: .imageDecodeMS)
    xmlParseMS = try values.decode(Double.self, forKey: .xmlParseMS)
    xcuiTestJSONParseMS =
      try values.decodeIfPresent(Double.self, forKey: .xcuiTestJSONParseMS) ?? 0
    serializationMS = try values.decode(Double.self, forKey: .serializationMS)
    totalMS = try values.decode(Double.self, forKey: .totalMS)
  }

  private enum CodingKeys: String, CodingKey {
    case imageDecodeMS = "image_decode_ms"
    case xmlParseMS = "xml_parse_ms"
    case xcuiTestJSONParseMS = "xcuitest_json_parse_ms"
    case serializationMS = "serialization_ms"
    case totalMS = "total_ms"
  }
}

/// Canonical state, both serializations, and out-of-band timing measurements.
public struct OfflineCompileResult: Sendable {
  public let state: UIState
  public let json: Data
  public let compactText: String
  public let timings: OfflineCompileTimings

  public init(
    state: UIState,
    json: Data,
    compactText: String,
    timings: OfflineCompileTimings
  ) {
    self.state = state
    self.json = json
    self.compactText = compactText
    self.timings = timings
  }
}

/// Compiles saved screenshot and native-tree evidence without simulator or network access.
public struct OfflineCompiler: Sendable {
  private let nativeTreeParser: NativeTreeParser
  private let xcuiTestSnapshotParser: XCUITestSnapshotParser
  private let limits: OfflineCompilerLimits

  public init(
    nativeTreeParser: NativeTreeParser = NativeTreeParser(),
    xcuiTestSnapshotParser: XCUITestSnapshotParser = XCUITestSnapshotParser(),
    limits: OfflineCompilerLimits = .default
  ) {
    self.nativeTreeParser = nativeTreeParser
    self.xcuiTestSnapshotParser = xcuiTestSnapshotParser
    self.limits = limits
  }

  public func compile(_ request: OfflineCompileRequest) throws -> OfflineCompileResult {
    let totalStart = ProcessInfo.processInfo.systemUptime

    guard request.screenshotData != nil || hasNativeTree(request) else {
      throw OfflineCompilerError.missingInput
    }
    guard request.nativeTreeXML == nil || request.xcuiTestSnapshotJSON == nil else {
      throw OfflineCompilerError.conflictingNativeTreeInputs
    }
    guard
      !request.screenID.isEmpty,
      isValid(size: request.viewportSizePoints),
      request.imageSizePixels.map(isValid(size:)) ?? true
    else {
      throw OfflineCompilerError.invalidScreenMetadata
    }

    let imageDecodeStart = ProcessInfo.processInfo.systemUptime
    let imageSize = try resolveImageSize(request)
    let imageDecodeMS = elapsedMilliseconds(since: imageDecodeStart)

    let xmlParseStart = ProcessInfo.processInfo.systemUptime
    let xmlNodes = try request.nativeTreeXML.map(nativeTreeParser.parse) ?? []
    let xmlParseMS =
      request.nativeTreeXML == nil ? 0 : elapsedMilliseconds(since: xmlParseStart)

    let xcuiTestJSONParseStart = ProcessInfo.processInfo.systemUptime
    let xcuiTestNodes =
      try request.xcuiTestSnapshotJSON.map(xcuiTestSnapshotParser.parse) ?? []
    let xcuiTestJSONParseMS =
      request.xcuiTestSnapshotJSON == nil
      ? 0 : elapsedMilliseconds(since: xcuiTestJSONParseStart)
    let nativeNodes = xmlNodes + xcuiTestNodes

    let sources = evidenceSources(request)
    let state = UIState(
      screen: UIStateScreen(
        id: request.screenID,
        capturedAt: request.capturedAt,
        treeCapturedAt: request.treeCapturedAt,
        treeAgeMS: treeAgeMS(request),
        imageSizePixels: imageSize,
        viewportSizePoints: request.viewportSizePoints,
        orientation: request.orientation,
        sources: sources
      ),
      elements: nativeNodes.map(makeElement)
    )

    let serializationStart = ProcessInfo.processInfo.systemUptime
    let json = try UIStateCodec.encode(state, prettyPrinted: true)
    let compactText = UIStateCompactRenderer.render(state)
    let serializationMS = elapsedMilliseconds(since: serializationStart)
    let timings = OfflineCompileTimings(
      imageDecodeMS: imageDecodeMS,
      xmlParseMS: xmlParseMS,
      xcuiTestJSONParseMS: xcuiTestJSONParseMS,
      serializationMS: serializationMS,
      totalMS: elapsedMilliseconds(since: totalStart)
    )

    return OfflineCompileResult(
      state: state,
      json: json,
      compactText: compactText,
      timings: timings
    )
  }

  private func resolveImageSize(_ request: OfflineCompileRequest) throws -> UIStateSize {
    if let screenshotData = request.screenshotData {
      guard
        limits.maximumScreenshotBytes > 0,
        screenshotData.count <= limits.maximumScreenshotBytes
      else {
        throw OfflineCompilerError.screenshotTooLarge(limit: limits.maximumScreenshotBytes)
      }

      guard let source = CGImageSourceCreateWithData(screenshotData as CFData, nil) else {
        throw OfflineCompilerError.invalidImageData
      }
      let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
      guard
        let width = (properties?[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
        let height = (properties?[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue,
        width > 0,
        height > 0
      else {
        throw OfflineCompilerError.invalidImageData
      }
      guard
        limits.maximumImagePixelCount > 0,
        width <= limits.maximumImagePixelCount / height
      else {
        throw OfflineCompilerError.imageDimensionsTooLarge(limit: limits.maximumImagePixelCount)
      }

      let options = [kCGImageSourceShouldCacheImmediately: true] as CFDictionary
      guard let image = CGImageSourceCreateImageAtIndex(source, 0, options) else {
        throw OfflineCompilerError.invalidImageData
      }

      return UIStateSize(width: Double(image.width), height: Double(image.height))
    }

    guard let imageSize = request.imageSizePixels else {
      throw OfflineCompilerError.missingImageSize
    }
    guard
      imageSize.width <= Double(limits.maximumImagePixelCount) / imageSize.height
    else {
      throw OfflineCompilerError.imageDimensionsTooLarge(limit: limits.maximumImagePixelCount)
    }
    return imageSize
  }

  private func evidenceSources(_ request: OfflineCompileRequest) -> [EvidenceSource] {
    var sources: [EvidenceSource] = []
    if request.screenshotData != nil {
      sources.append(.screenshot)
    }
    if hasNativeTree(request) {
      sources.append(.uiTree)
    }
    return sources
  }

  private func treeAgeMS(_ request: OfflineCompileRequest) -> Double? {
    guard hasNativeTree(request), let treeCapturedAt = request.treeCapturedAt else {
      return nil
    }
    return max(0, request.capturedAt.timeIntervalSince(treeCapturedAt) * 1_000)
  }

  private func makeElement(_ node: NativeTreeNode) -> UIStateElement {
    let frame = node.frame.map { frame in
      UIStateRect(
        x: frame.x,
        y: frame.y,
        width: frame.width,
        height: frame.height,
        coordinateSpace: .screenPoints
      )
    }

    return UIStateElement(
      id: node.id,
      role: node.role,
      frames: frame.map { [$0] } ?? [],
      actions: actions(node: node),
      provenance: [.uiTree],
      confidence: 1,
      label: node.label,
      value: node.value,
      nativeIdentifier: node.nativeIdentifier,
      visible: node.visible,
      enabled: node.enabled,
      selected: node.selected,
      parentID: node.parentID,
      childIDs: node.childIDs
    )
  }

  private func actions(node: NativeTreeNode) -> [UIStateAction] {
    guard node.enabled != false, isTapRole(node.role), let frame = node.frame else {
      return []
    }

    return [
      UIStateAction(
        type: .tap,
        target: UIStatePoint(
          x: frame.x + frame.width / 2,
          y: frame.y + frame.height / 2,
          coordinateSpace: .screenPoints
        ),
        confidence: 1,
        evidence: ["native-tree"],
        verification: .treeDeclared
      )
    ]
  }

  private func isTapRole(_ role: ElementRole) -> Bool {
    switch role {
    case .button, .iconButton, .switch, .checkbox, .segmentedControl, .tabItem, .row, .cell:
      return true
    default:
      return false
    }
  }

  private func hasNativeTree(_ request: OfflineCompileRequest) -> Bool {
    request.nativeTreeXML != nil || request.xcuiTestSnapshotJSON != nil
  }

  private func isValid(size: UIStateSize) -> Bool {
    size.width.isFinite && size.height.isFinite && size.width > 0 && size.height > 0
  }

  private func elapsedMilliseconds(since start: TimeInterval) -> Double {
    max(0, (ProcessInfo.processInfo.systemUptime - start) * 1_000)
  }
}
