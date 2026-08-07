import Foundation

/// Resource limits applied before and during native-tree parsing.
public struct NativeTreeParserLimits: Equatable, Sendable {
  public static let `default` = NativeTreeParserLimits(
    maximumInputBytes: 8 * 1_024 * 1_024,
    maximumNodeCount: 50_000,
    maximumDepth: 256
  )

  public let maximumInputBytes: Int
  public let maximumNodeCount: Int
  public let maximumDepth: Int

  public init(
    maximumInputBytes: Int,
    maximumNodeCount: Int,
    maximumDepth: Int
  ) {
    self.maximumInputBytes = maximumInputBytes
    self.maximumNodeCount = maximumNodeCount
    self.maximumDepth = maximumDepth
  }
}

/// Stable error categories that do not expose raw untrusted XML content.
public enum NativeTreeParserError: Error, Equatable, Sendable {
  case inputTooLarge(limit: Int)
  case prohibitedDeclaration
  case nodeLimitExceeded(limit: Int)
  case depthLimitExceeded(limit: Int)
  case duplicateNodeID
  case incompleteFrame
  case invalidAttribute(name: String)
  case malformedXML
}

/// A flattened, normalized native hierarchy node in screen-point coordinates.
public struct NativeTreeNode: Equatable, Sendable {
  public let id: String
  public let role: ElementRole
  public let label: String?
  public let value: String?
  public let nativeIdentifier: String?
  public let frame: CoordinateRect<ScreenPointSpace>?
  public let visible: Bool?
  public let enabled: Bool?
  public let selected: Bool?
  public let parentID: String?
  public let childIDs: [String]

  public init(
    id: String,
    role: ElementRole,
    label: String? = nil,
    value: String? = nil,
    nativeIdentifier: String? = nil,
    frame: CoordinateRect<ScreenPointSpace>? = nil,
    visible: Bool? = nil,
    enabled: Bool? = nil,
    selected: Bool? = nil,
    parentID: String? = nil,
    childIDs: [String] = []
  ) {
    self.id = id
    self.role = role
    self.label = label
    self.value = value
    self.nativeIdentifier = nativeIdentifier
    self.frame = frame
    self.visible = visible
    self.enabled = enabled
    self.selected = selected
    self.parentID = parentID
    self.childIDs = childIDs
  }
}

/// Parses untrusted native hierarchy XML without resolving external entities.
public struct NativeTreeParser: Sendable {
  public let limits: NativeTreeParserLimits

  public init(limits: NativeTreeParserLimits = .default) {
    self.limits = limits
  }

  /// Returns nodes in document order after enforcing byte, node, and depth limits.
  public func parse(_ data: Data) throws -> [NativeTreeNode] {
    guard limits.maximumInputBytes > 0, data.count <= limits.maximumInputBytes else {
      throw NativeTreeParserError.inputTooLarge(limit: limits.maximumInputBytes)
    }

    guard !containsProhibitedDeclaration(data) else {
      throw NativeTreeParserError.prohibitedDeclaration
    }

    let delegate = NativeTreeParserDelegate(limits: limits)
    let parser = XMLParser(data: data)
    parser.delegate = delegate
    parser.shouldProcessNamespaces = false
    parser.shouldReportNamespacePrefixes = false
    parser.shouldResolveExternalEntities = false
    parser.externalEntityResolvingPolicy = .never
    parser.allowedExternalEntityURLs = []

    let succeeded = parser.parse()

    if let failure = delegate.failure {
      throw failure
    }
    guard succeeded else {
      throw NativeTreeParserError.malformedXML
    }

    return delegate.normalizedNodes
  }

  private func containsProhibitedDeclaration(_ data: Data) -> Bool {
    String(decoding: data, as: UTF8.self)
      .replacingOccurrences(of: "\0", with: "")
      .range(
        of: #"<!\s*(doctype|entity)\b"#,
        options: [.regularExpression, .caseInsensitive]
      ) != nil
  }
}

private final class NativeTreeParserDelegate: NSObject, XMLParserDelegate {
  private final class Draft {
    let id: String
    let role: ElementRole
    let label: String?
    let value: String?
    let nativeIdentifier: String?
    let frame: CoordinateRect<ScreenPointSpace>?
    let visible: Bool?
    let enabled: Bool?
    let selected: Bool?
    let parentID: String?
    var childIDs: [String] = []

    init(
      id: String,
      role: ElementRole,
      label: String?,
      value: String?,
      nativeIdentifier: String?,
      frame: CoordinateRect<ScreenPointSpace>?,
      visible: Bool?,
      enabled: Bool?,
      selected: Bool?,
      parentID: String?
    ) {
      self.id = id
      self.role = role
      self.label = label
      self.value = value
      self.nativeIdentifier = nativeIdentifier
      self.frame = frame
      self.visible = visible
      self.enabled = enabled
      self.selected = selected
      self.parentID = parentID
    }
  }

  let limits: NativeTreeParserLimits
  var failure: NativeTreeParserError?

  private var orderedDrafts: [Draft] = []
  private var stack: [Draft] = []
  private var nodeIDs = Set<String>()

  init(limits: NativeTreeParserLimits) {
    self.limits = limits
  }

  var normalizedNodes: [NativeTreeNode] {
    orderedDrafts.map { draft in
      NativeTreeNode(
        id: draft.id,
        role: draft.role,
        label: draft.label,
        value: draft.value,
        nativeIdentifier: draft.nativeIdentifier,
        frame: draft.frame,
        visible: draft.visible,
        enabled: draft.enabled,
        selected: draft.selected,
        parentID: draft.parentID,
        childIDs: draft.childIDs
      )
    }
  }

  func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    guard failure == nil else { return }

    guard limits.maximumDepth > 0, stack.count < limits.maximumDepth else {
      fail(.depthLimitExceeded(limit: limits.maximumDepth), parser: parser)
      return
    }
    guard limits.maximumNodeCount > 0, orderedDrafts.count < limits.maximumNodeCount else {
      fail(.nodeLimitExceeded(limit: limits.maximumNodeCount), parser: parser)
      return
    }

    do {
      let id = nodeID(attributes: attributeDict)
      guard nodeIDs.insert(id).inserted else {
        fail(.duplicateNodeID, parser: parser)
        return
      }

      let draft = Draft(
        id: id,
        role: role(elementName: elementName, attributes: attributeDict),
        label: nonEmpty(attributeDict["label"]),
        value: attributeDict["value"],
        nativeIdentifier: nonEmpty(attributeDict["identifier"] ?? attributeDict["name"]),
        frame: try frame(attributes: attributeDict),
        visible: try boolean(named: "visible", attributes: attributeDict),
        enabled: try boolean(named: "enabled", attributes: attributeDict),
        selected: try boolean(named: "selected", attributes: attributeDict),
        parentID: stack.last?.id
      )

      stack.last?.childIDs.append(id)
      orderedDrafts.append(draft)
      stack.append(draft)
    } catch let error as NativeTreeParserError {
      fail(error, parser: parser)
    } catch {
      fail(.malformedXML, parser: parser)
    }
  }

  func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?
  ) {
    if !stack.isEmpty {
      stack.removeLast()
    }
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    if failure == nil {
      failure = .malformedXML
    }
  }

  func parser(
    _ parser: XMLParser,
    foundInternalEntityDeclarationWithName name: String,
    value: String?
  ) {
    fail(.prohibitedDeclaration, parser: parser)
  }

  func parser(
    _ parser: XMLParser,
    foundExternalEntityDeclarationWithName name: String,
    publicID: String?,
    systemID: String?
  ) {
    fail(.prohibitedDeclaration, parser: parser)
  }

  func parser(
    _ parser: XMLParser,
    resolveExternalEntityName name: String,
    systemID: String?
  ) -> Data? {
    fail(.prohibitedDeclaration, parser: parser)
    return nil
  }

  private func fail(_ error: NativeTreeParserError, parser: XMLParser) {
    guard failure == nil else { return }
    failure = error
    parser.abortParsing()
  }

  private func nodeID(attributes: [String: String]) -> String {
    if let explicit = nonEmpty(attributes["uid"] ?? attributes["id"]) {
      return explicit
    }
    return "node-\(orderedDrafts.count)"
  }

  private func role(
    elementName: String,
    attributes: [String: String]
  ) -> ElementRole {
    let rawType = attributes["type"] ?? elementName
    let type = rawType.replacingOccurrences(of: "XCUIElementType", with: "")

    switch type {
    case "StaticText": return .staticText
    case "Button", "Link": return .button
    case "TextField", "TextView": return .textField
    case "SecureTextField": return .secureTextField
    case "Switch", "Toggle": return .switch
    case "CheckBox": return .checkbox
    case "Slider": return .slider
    case "SegmentedControl": return .segmentedControl
    case "Tab", "TabButton": return .tabItem
    case "Image": return .image
    case "Cell": return .cell
    case "CollectionView", "Outline": return .list
    case "Table": return .table
    case "NavigationBar": return .navigationBar
    case "Toolbar": return .toolbar
    case "Alert": return .dialog
    case "Sheet": return .sheet
    case "Keyboard": return .keyboard
    case "ScrollView": return .scrollContainer
    case "PageIndicator": return .pageControl
    default: return .unknown
    }
  }

  private func frame(
    attributes: [String: String]
  ) throws -> CoordinateRect<ScreenPointSpace>? {
    let names = ["x", "y", "width", "height"]
    let presentNames = names.filter { attributes[$0] != nil }

    guard !presentNames.isEmpty else { return nil }
    guard presentNames.count == names.count else {
      throw NativeTreeParserError.incompleteFrame
    }

    let x = try number(named: "x", attributes: attributes)
    let y = try number(named: "y", attributes: attributes)
    let width = try number(named: "width", attributes: attributes)
    let height = try number(named: "height", attributes: attributes)

    do {
      return try CoordinateRect<ScreenPointSpace>(
        x: x,
        y: y,
        width: width,
        height: height
      )
    } catch {
      throw NativeTreeParserError.invalidAttribute(name: "frame")
    }
  }

  private func number(
    named name: String,
    attributes: [String: String]
  ) throws -> Double {
    guard let rawValue = attributes[name], let value = Double(rawValue), value.isFinite else {
      throw NativeTreeParserError.invalidAttribute(name: name)
    }
    return value
  }

  private func boolean(
    named name: String,
    attributes: [String: String]
  ) throws -> Bool? {
    guard let rawValue = attributes[name] else { return nil }

    switch rawValue.lowercased() {
    case "true", "1": return true
    case "false", "0": return false
    default: throw NativeTreeParserError.invalidAttribute(name: name)
    }
  }

  private func nonEmpty(_ value: String?) -> String? {
    guard let value, !value.isEmpty else { return nil }
    return value
  }
}
