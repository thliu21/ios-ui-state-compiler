import Foundation

public enum PilotManifestStatus: String, Codable, Sendable {
  case draft
  case frozen
}

public enum PilotFramework: String, Codable, Sendable {
  case uikit
  case swiftui
  case mixed
}

public enum PilotSplit: String, Codable, Sendable {
  case development
  case heldOut = "held_out"
}

public enum PilotAppearance: String, Codable, Sendable {
  case light
  case dark
}

public enum PilotRedistributionStatus: String, Codable, Sendable {
  case allowed
  case withheld
  case excludedPendingClarification = "excluded_pending_clarification"
}

public struct PilotArtifact: Codable, Sendable {
  let path: String
  let sha256: String
  let capturedAt: String
  let source: String
}

public struct PilotViewportSize: Codable, Hashable, Sendable {
  let width: Double
  let height: Double
}

public struct PilotReview: Codable, Sendable {
  let reviewer: String
  let reviewedAt: String
  let state: String
  let notes: String?
}

public struct PilotRecord: Codable, Sendable {
  let recordId: String
  let appId: String
  let appFamilyId: String
  let appName: String
  let repositoryUrl: String
  let pinnedRevision: String
  let framework: PilotFramework
  let bundleIdentifier: String
  let screenshot: PilotArtifact
  let tree: PilotArtifact?
  let annotationPath: String
  let annotationSha256: String
  let deviceType: String
  let runtime: String
  let viewportSizePoints: PilotViewportSize
  let orientation: String
  let locale: String
  let appearance: PilotAppearance
  let dynamicType: String
  let initialStateRecipe: String
  let split: PilotSplit
  let nearDuplicateGroup: String
  let licenseEntryIds: [String]
  let redistributionStatus: PilotRedistributionStatus
  let review: PilotReview
}

public struct PilotActionPoint: Codable, Sendable {
  let x: Double
  let y: Double
  let coordinateSpace: String
}

public struct PilotActionPair: Codable, Sendable {
  let pairId: String
  let beforeRecordId: String
  let afterRecordId: String
  let actionType: String
  let target: PilotActionPoint?
  let outcome: String
  let reviewer: String
  let verifiedAt: String
}

public struct PilotManifest: Codable, Sendable {
  public static let currentSchemaVersion = "0.1.0"

  let schemaVersion: String
  let manifestId: String
  let status: PilotManifestStatus
  let createdAt: String
  let supersedesManifestId: String?
  let annotationGuideVersion: String
  let licenseLedgerId: String
  let records: [PilotRecord]
  let actionPairs: [PilotActionPair]

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
    guard schemaVersion == Self.currentSchemaVersion else {
      throw DecodingError.dataCorruptedError(
        forKey: .schemaVersion,
        in: values,
        debugDescription: "Unsupported pilot manifest schema version: \(schemaVersion)"
      )
    }

    self.schemaVersion = schemaVersion
    manifestId = try values.decode(String.self, forKey: .manifestId)
    status = try values.decode(PilotManifestStatus.self, forKey: .status)
    createdAt = try values.decode(String.self, forKey: .createdAt)
    supersedesManifestId = try values.decodeIfPresent(String.self, forKey: .supersedesManifestId)
    annotationGuideVersion = try values.decode(String.self, forKey: .annotationGuideVersion)
    licenseLedgerId = try values.decode(String.self, forKey: .licenseLedgerId)
    records = try values.decode([PilotRecord].self, forKey: .records)
    actionPairs = try values.decode([PilotActionPair].self, forKey: .actionPairs)
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(schemaVersion, forKey: .schemaVersion)
    try values.encode(manifestId, forKey: .manifestId)
    try values.encode(status, forKey: .status)
    try values.encode(createdAt, forKey: .createdAt)
    try values.encodeIfPresent(supersedesManifestId, forKey: .supersedesManifestId)
    try values.encode(annotationGuideVersion, forKey: .annotationGuideVersion)
    try values.encode(licenseLedgerId, forKey: .licenseLedgerId)
    try values.encode(records, forKey: .records)
    try values.encode(actionPairs, forKey: .actionPairs)
  }

  private enum CodingKeys: String, CodingKey {
    case schemaVersion
    case manifestId
    case status
    case createdAt
    case supersedesManifestId
    case annotationGuideVersion
    case licenseLedgerId
    case records
    case actionPairs
  }
}

public enum LicenseLedgerDecision: String, Codable, Sendable {
  case allowedMainPipeline = "allowed_main_pipeline"
  case researchOnlyIsolated = "research_only_isolated"
  case excludedPendingClarification = "excluded_pending_clarification"
  case excluded
}

public struct LicenseLedgerEntry: Codable, Sendable {
  let artifactId: String
  let artifactType: String
  let name: String
  let sourceUrl: String
  let pinnedRevisionOrHash: String
  let sourceCodeLicense: String?
  let dataOrAssetLicense: String?
  let modelWeightLicense: String?
  let copyrightOrTrademarkNotes: String
  let allowedUses: [String]
  let redistributionAllowed: Bool
  let commercialCompatibility: String
  let reviewer: String
  let reviewDate: String
  let decision: LicenseLedgerDecision
}

public struct LicenseLedger: Codable, Sendable {
  public static let currentSchemaVersion = "0.1.0"

  let schemaVersion: String
  let ledgerId: String
  let updatedAt: String
  let entries: [LicenseLedgerEntry]

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
    guard schemaVersion == Self.currentSchemaVersion else {
      throw DecodingError.dataCorruptedError(
        forKey: .schemaVersion,
        in: values,
        debugDescription: "Unsupported license ledger schema version: \(schemaVersion)"
      )
    }

    self.schemaVersion = schemaVersion
    ledgerId = try values.decode(String.self, forKey: .ledgerId)
    updatedAt = try values.decode(String.self, forKey: .updatedAt)
    entries = try values.decode([LicenseLedgerEntry].self, forKey: .entries)
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: CodingKeys.self)
    try values.encode(schemaVersion, forKey: .schemaVersion)
    try values.encode(ledgerId, forKey: .ledgerId)
    try values.encode(updatedAt, forKey: .updatedAt)
    try values.encode(entries, forKey: .entries)
  }

  private enum CodingKeys: String, CodingKey {
    case schemaVersion
    case ledgerId
    case updatedAt
    case entries
  }
}

public enum PilotManifestCodec {
  public static func decodeManifest(_ data: Data) throws -> PilotManifest {
    try decoder().decode(PilotManifest.self, from: data)
  }

  public static func decodeLicenseLedger(_ data: Data) throws -> LicenseLedger {
    try decoder().decode(LicenseLedger.self, from: data)
  }

  private static func decoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }
}
