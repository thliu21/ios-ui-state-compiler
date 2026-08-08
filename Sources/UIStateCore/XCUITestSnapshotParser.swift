import CoreFoundation
import Foundation

/// Stable failures for bounded XCUITest snapshot-dictionary parsing.
public enum XCUITestSnapshotParserError: Error, Equatable, Sendable {
  case inputTooLarge(limit: Int)
  case malformedJSON
  case invalidRoot
  case nodeLimitExceeded(limit: Int)
  case depthLimitExceeded(limit: Int)
  case incompleteFrame
  case invalidField(name: String)
}

/// Normalizes `XCUIElementSnapshot.dictionaryRepresentation` JSON attachments.
///
/// Node identifiers use deterministic tree paths because accessibility
/// identifiers can be empty or duplicated. Unknown element-type values remain
/// `.unknown` instead of being guessed from labels or geometry.
public struct XCUITestSnapshotParser: Sendable {
  public let limits: NativeTreeParserLimits

  public init(limits: NativeTreeParserLimits = .default) {
    self.limits = limits
  }

  /// Returns nodes in pre-order after enforcing byte, node, and depth limits.
  public func parse(_ data: Data) throws -> [NativeTreeNode] {
    guard limits.maximumInputBytes > 0, data.count <= limits.maximumInputBytes else {
      throw XCUITestSnapshotParserError.inputTooLarge(limit: limits.maximumInputBytes)
    }

    let object: Any
    do {
      object = try JSONSerialization.jsonObject(with: data)
    } catch {
      throw XCUITestSnapshotParserError.malformedJSON
    }

    guard let root = object as? [String: Any] else {
      throw XCUITestSnapshotParserError.invalidRoot
    }

    var nodes: [NativeTreeNode] = []
    try append(
      root,
      path: [0],
      parentID: nil,
      depth: 1,
      to: &nodes
    )
    return nodes
  }

  private func append(
    _ object: [String: Any],
    path: [Int],
    parentID: String?,
    depth: Int,
    to nodes: inout [NativeTreeNode]
  ) throws {
    guard limits.maximumDepth > 0, depth <= limits.maximumDepth else {
      throw XCUITestSnapshotParserError.depthLimitExceeded(limit: limits.maximumDepth)
    }
    guard limits.maximumNodeCount > 0, nodes.count < limits.maximumNodeCount else {
      throw XCUITestSnapshotParserError.nodeLimitExceeded(limit: limits.maximumNodeCount)
    }

    let children = try childObjects(object["children"])
    let id = nodeID(path)
    let childIDs = children.indices.map { nodeID(path + [$0]) }
    let elementType = try integer(object["elementType"], named: "elementType")

    nodes.append(
      NativeTreeNode(
        id: id,
        role: role(elementType: elementType),
        label: try optionalString(object["label"], named: "label"),
        value: try optionalScalarString(object["value"], named: "value"),
        nativeIdentifier: try optionalString(object["identifier"], named: "identifier"),
        frame: try frame(object["frame"]),
        visible: nil,
        enabled: try optionalBoolean(object["enabled"], named: "enabled"),
        selected: try optionalBoolean(object["selected"], named: "selected"),
        parentID: parentID,
        childIDs: childIDs
      )
    )

    for (index, child) in children.enumerated() {
      try append(
        child,
        path: path + [index],
        parentID: id,
        depth: depth + 1,
        to: &nodes
      )
    }
  }

  private func childObjects(_ value: Any?) throws -> [[String: Any]] {
    guard let value else { return [] }
    guard let values = value as? [Any] else {
      throw XCUITestSnapshotParserError.invalidField(name: "children")
    }

    return try values.map { value in
      guard let child = value as? [String: Any] else {
        throw XCUITestSnapshotParserError.invalidField(name: "children")
      }
      return child
    }
  }

  private func nodeID(_ path: [Int]) -> String {
    "xcui-" + path.map(String.init).joined(separator: ".")
  }

  private func frame(_ value: Any?) throws -> CoordinateRect<ScreenPointSpace>? {
    guard let value else { return nil }
    guard let object = value as? [String: Any] else {
      throw XCUITestSnapshotParserError.invalidField(name: "frame")
    }

    let names = ["X", "Y", "Width", "Height"]
    let presentNames = names.filter { object[$0] != nil }
    guard presentNames.count == names.count else {
      throw XCUITestSnapshotParserError.incompleteFrame
    }

    do {
      return try CoordinateRect<ScreenPointSpace>(
        x: number(object["X"], named: "frame.X"),
        y: number(object["Y"], named: "frame.Y"),
        width: number(object["Width"], named: "frame.Width"),
        height: number(object["Height"], named: "frame.Height")
      )
    } catch is GeometryError {
      throw XCUITestSnapshotParserError.invalidField(name: "frame")
    }
  }

  private func integer(_ value: Any?, named name: String) throws -> Int {
    let rawValue = try number(value, named: name)
    guard rawValue.rounded(.towardZero) == rawValue, let result = Int(exactly: rawValue) else {
      throw XCUITestSnapshotParserError.invalidField(name: name)
    }
    return result
  }

  private func number(_ value: Any?, named name: String) throws -> Double {
    guard
      let value = value as? NSNumber,
      CFGetTypeID(value) != CFBooleanGetTypeID(),
      value.doubleValue.isFinite
    else {
      throw XCUITestSnapshotParserError.invalidField(name: name)
    }
    return value.doubleValue
  }

  private func optionalBoolean(_ value: Any?, named name: String) throws -> Bool? {
    guard let value else { return nil }
    guard
      let value = value as? NSNumber,
      CFGetTypeID(value) == CFBooleanGetTypeID()
    else {
      throw XCUITestSnapshotParserError.invalidField(name: name)
    }
    return value.boolValue
  }

  private func optionalString(_ value: Any?, named name: String) throws -> String? {
    guard let value else { return nil }
    guard let value = value as? String else {
      throw XCUITestSnapshotParserError.invalidField(name: name)
    }
    return value.isEmpty ? nil : value
  }

  private func optionalScalarString(_ value: Any?, named name: String) throws -> String? {
    guard let value, !(value is NSNull) else { return nil }
    if let value = value as? String {
      return value
    }
    if let value = value as? NSNumber {
      if CFGetTypeID(value) == CFBooleanGetTypeID() {
        return value.boolValue ? "true" : "false"
      }
      return value.stringValue
    }
    throw XCUITestSnapshotParserError.invalidField(name: name)
  }

  private func role(elementType: Int) -> ElementRole {
    switch elementType {
    case 5: return .sheet
    case 7, 8: return .dialog
    case 9, 42: return .button
    case 12: return .checkbox
    case 19: return .keyboard
    case 21: return .navigationBar
    case 24: return .toolbar
    case 26: return .table
    case 27, 30: return .row
    case 29, 32: return .list
    case 33: return .slider
    case 34: return .pageControl
    case 37: return .segmentedControl
    case 40, 41: return .switch
    case 43, 44: return .image
    case 45, 49, 52: return .textField
    case 46: return .scrollContainer
    case 48: return .staticText
    case 50: return .secureTextField
    case 75: return .cell
    case 80: return .tabItem
    default: return .unknown
    }
  }
}
