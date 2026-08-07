import Foundation

public enum EvidenceSource: String, CaseIterable, Codable, Sendable {
  case screenshot
  case uiTree = "ui_tree"
  case ocr
  case geometry
  case detector
  case fusion
  case execution
}

public enum ScreenOrientation: String, CaseIterable, Codable, Sendable {
  case portrait
  case portraitUpsideDown = "portrait_upside_down"
  case landscapeLeft = "landscape_left"
  case landscapeRight = "landscape_right"
  case unknown
}

public enum ElementRole: String, CaseIterable, Codable, Sendable {
  case unknown
  case staticText = "static_text"
  case heading
  case button
  case iconButton = "icon_button"
  case textField = "text_field"
  case secureTextField = "secure_text_field"
  case `switch`
  case checkbox
  case slider
  case segmentedControl = "segmented_control"
  case tabItem = "tab_item"
  case image
  case row
  case cell
  case list
  case table
  case section
  case navigationBar = "navigation_bar"
  case toolbar
  case dialog
  case sheet
  case keyboard
  case scrollContainer = "scroll_container"
  case pageControl = "page_control"
}

public enum ActionType: String, CaseIterable, Codable, Sendable {
  case tap
  case typeText = "type_text"
  case swipe
  case longPress = "long_press"
  case drag
  case pinch
  case scroll
}

public enum ActionVerification: String, CaseIterable, Codable, Sendable {
  case treeDeclared = "tree_declared"
  case visuallyInferred = "visually_inferred"
  case executionVerified = "execution_verified"
}

public enum RelationType: String, CaseIterable, Codable, Sendable {
  case contains
  case belongsToSection = "belongs_to_section"
  case labels
  case valueFor = "value_for"
  case controls
  case rowOf = "row_of"
  case columnOf = "column_of"
  case headerOf = "header_of"
  case selectedTab = "selected_tab"
  case modalOver = "modal_over"
  case scrollsWithin = "scrolls_within"
  case visuallyObscures = "visually_obscures"
}

public enum ChangeType: String, CaseIterable, Codable, Sendable {
  case added
  case removed
  case valueChanged = "value_changed"
  case selectionChanged = "selection_changed"
  case focusChanged = "focus_changed"
  case visibilityChanged = "visibility_changed"
  case modalOpened = "modal_opened"
  case pageChanged = "page_changed"
  case scrollPositionChanged = "scroll_position_changed"
}

public struct UIStateSize: Equatable, Codable, Sendable {
  public let width: Double
  public let height: Double

  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }
}

public struct UIStatePoint: Equatable, Codable, Sendable {
  public let x: Double
  public let y: Double
  public let coordinateSpace: CoordinateSpace

  public init(x: Double, y: Double, coordinateSpace: CoordinateSpace) {
    self.x = x
    self.y = y
    self.coordinateSpace = coordinateSpace
  }

  private enum CodingKeys: String, CodingKey {
    case x
    case y
    case coordinateSpace = "coordinate_space"
  }
}

public struct UIStateRect: Equatable, Codable, Sendable {
  public let x: Double
  public let y: Double
  public let width: Double
  public let height: Double
  public let coordinateSpace: CoordinateSpace

  public init(
    x: Double,
    y: Double,
    width: Double,
    height: Double,
    coordinateSpace: CoordinateSpace
  ) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.coordinateSpace = coordinateSpace
  }

  private enum CodingKeys: String, CodingKey {
    case x
    case y
    case width
    case height
    case coordinateSpace = "coordinate_space"
  }
}

public struct UIStateScreen: Equatable, Codable, Sendable {
  public let id: String
  public let title: String?
  public let capturedAt: Date
  public let treeCapturedAt: Date?
  public let treeAgeMS: Double?
  public let imageSizePixels: UIStateSize
  public let viewportSizePoints: UIStateSize
  public let orientation: ScreenOrientation
  public let sources: [EvidenceSource]

  public init(
    id: String,
    title: String? = nil,
    capturedAt: Date,
    treeCapturedAt: Date? = nil,
    treeAgeMS: Double? = nil,
    imageSizePixels: UIStateSize,
    viewportSizePoints: UIStateSize,
    orientation: ScreenOrientation,
    sources: [EvidenceSource]
  ) {
    self.id = id
    self.title = title
    self.capturedAt = capturedAt
    self.treeCapturedAt = treeCapturedAt
    self.treeAgeMS = treeAgeMS
    self.imageSizePixels = imageSizePixels
    self.viewportSizePoints = viewportSizePoints
    self.orientation = orientation
    self.sources = sources
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case title
    case capturedAt = "captured_at"
    case treeCapturedAt = "tree_captured_at"
    case treeAgeMS = "tree_age_ms"
    case imageSizePixels = "image_size_pixels"
    case viewportSizePoints = "viewport_size_points"
    case orientation
    case sources
  }
}

public struct UIStateAction: Equatable, Codable, Sendable {
  public let type: ActionType
  public let target: UIStatePoint?
  public let confidence: Double
  public let evidence: [String]
  public let verification: ActionVerification

  public init(
    type: ActionType,
    target: UIStatePoint? = nil,
    confidence: Double,
    evidence: [String],
    verification: ActionVerification
  ) {
    self.type = type
    self.target = target
    self.confidence = confidence
    self.evidence = evidence
    self.verification = verification
  }
}

public struct UIStateElement: Equatable, Codable, Sendable {
  public let id: String
  public let role: ElementRole
  public let label: String?
  public let value: String?
  public let nativeIdentifier: String?
  public let frames: [UIStateRect]
  public let visible: Bool?
  public let enabled: Bool?
  public let selected: Bool?
  public let parentID: String?
  public let childIDs: [String]?
  public let actions: [UIStateAction]
  public let provenance: [EvidenceSource]
  public let confidence: Double
  public let snapshotAgeMS: Double?

  public init(
    id: String,
    role: ElementRole,
    frames: [UIStateRect],
    actions: [UIStateAction],
    provenance: [EvidenceSource],
    confidence: Double,
    label: String? = nil,
    value: String? = nil,
    nativeIdentifier: String? = nil,
    visible: Bool? = nil,
    enabled: Bool? = nil,
    selected: Bool? = nil,
    parentID: String? = nil,
    childIDs: [String]? = nil,
    snapshotAgeMS: Double? = nil
  ) {
    self.id = id
    self.role = role
    self.label = label
    self.value = value
    self.nativeIdentifier = nativeIdentifier
    self.frames = frames
    self.visible = visible
    self.enabled = enabled
    self.selected = selected
    self.parentID = parentID
    self.childIDs = childIDs
    self.actions = actions
    self.provenance = provenance
    self.confidence = confidence
    self.snapshotAgeMS = snapshotAgeMS
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case role
    case label
    case value
    case nativeIdentifier = "native_identifier"
    case frames
    case visible
    case enabled
    case selected
    case parentID = "parent_id"
    case childIDs = "child_ids"
    case actions
    case provenance
    case confidence
    case snapshotAgeMS = "snapshot_age_ms"
  }
}

public struct UIStateRelation: Equatable, Codable, Sendable {
  public let type: RelationType
  public let elementID: String
  public let relatedID: String
  public let confidence: Double
  public let provenance: [EvidenceSource]?

  public init(
    type: RelationType,
    elementID: String,
    relatedID: String,
    confidence: Double,
    provenance: [EvidenceSource]? = nil
  ) {
    self.type = type
    self.elementID = elementID
    self.relatedID = relatedID
    self.confidence = confidence
    self.provenance = provenance
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case elementID = "element_id"
    case relatedID = "related_id"
    case confidence
    case provenance
  }
}

public struct UIStateChange: Equatable, Codable, Sendable {
  public let type: ChangeType
  public let elementID: String
  public let previousValue: String?
  public let currentValue: String?
  public let confidence: Double

  public init(
    type: ChangeType,
    elementID: String,
    confidence: Double,
    previousValue: String? = nil,
    currentValue: String? = nil
  ) {
    self.type = type
    self.elementID = elementID
    self.previousValue = previousValue
    self.currentValue = currentValue
    self.confidence = confidence
  }

  private enum CodingKeys: String, CodingKey {
    case type
    case elementID = "element_id"
    case previousValue = "previous_value"
    case currentValue = "current_value"
    case confidence
  }
}

public struct UIState: Equatable, Codable, Sendable {
  public static let currentSchemaVersion = "0.1.0"

  public let schemaVersion: String
  public let screen: UIStateScreen
  public let elements: [UIStateElement]
  public let relations: [UIStateRelation]
  public let changes: [UIStateChange]

  public init(
    screen: UIStateScreen,
    elements: [UIStateElement],
    relations: [UIStateRelation] = [],
    changes: [UIStateChange] = []
  ) {
    self.schemaVersion = Self.currentSchemaVersion
    self.screen = screen
    self.elements = elements
    self.relations = relations
    self.changes = changes
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let schemaVersion = try container.decode(String.self, forKey: .schemaVersion)

    guard schemaVersion == Self.currentSchemaVersion else {
      throw DecodingError.dataCorruptedError(
        forKey: .schemaVersion,
        in: container,
        debugDescription: "Unsupported UI-state schema version: \(schemaVersion)"
      )
    }

    self.schemaVersion = schemaVersion
    self.screen = try container.decode(UIStateScreen.self, forKey: .screen)
    self.elements = try container.decode([UIStateElement].self, forKey: .elements)
    self.relations = try container.decode([UIStateRelation].self, forKey: .relations)
    self.changes = try container.decode([UIStateChange].self, forKey: .changes)
  }

  private enum CodingKeys: String, CodingKey {
    case schemaVersion = "schema_version"
    case screen
    case elements
    case relations
    case changes
  }
}
