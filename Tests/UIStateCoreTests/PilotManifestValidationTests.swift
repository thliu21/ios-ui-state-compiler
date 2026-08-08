import Foundation
import Testing
import UIStateCore

@Suite("P2 pilot manifest validation")
struct PilotManifestValidationTests {
  @Test("Valid draft manifest and license ledger pass semantic validation")
  func validDraftPasses() throws {
    let manifest = try PilotManifestCodec.decodeManifest(try fixture("pilot-manifest-valid"))
    let ledger = try PilotManifestCodec.decodeLicenseLedger(try fixture("license-ledger-valid"))

    #expect(PilotManifestValidator.validate(manifest: manifest, licenseLedger: ledger).isEmpty)
  }

  @Test(
    "Invalid identity, split, reference, and redistribution cases fail specifically",
    arguments: [
      ("record-swiftui-001", "record-uikit-001", PilotValidationCode.duplicateRecordID),
      ("swiftui-fixture", "uikit-fixture", PilotValidationCode.crossSplitApp),
      ("license-swiftui", "license-missing", PilotValidationCode.missingLicenseEntry),
      (
        "\"after_record_id\": \"record-uikit-002\"",
        "\"after_record_id\": \"record-missing\"",
        PilotValidationCode.brokenActionPairReference
      ),
    ])
  func invalidManifestFails(
    original: String,
    replacement: String,
    expectedCode: PilotValidationCode
  ) throws {
    let source = String(decoding: try fixture("pilot-manifest-valid"), as: UTF8.self)
    let manifest = try PilotManifestCodec.decodeManifest(
      Data(source.replacingOccurrences(of: original, with: replacement).utf8)
    )
    let ledger = try PilotManifestCodec.decodeLicenseLedger(try fixture("license-ledger-valid"))

    let issues = PilotManifestValidator.validate(manifest: manifest, licenseLedger: ledger)

    #expect(issues.contains { $0.code == expectedCode })
  }

  @Test("Publishable artifact requires explicit redistribution approval")
  func redistributionRequiresApproval() throws {
    let manifest = try PilotManifestCodec.decodeManifest(try fixture("pilot-manifest-valid"))
    let source = String(decoding: try fixture("license-ledger-valid"), as: UTF8.self)
    let ledger = try PilotManifestCodec.decodeLicenseLedger(
      Data(
        source.replacingOccurrences(
          of: "\"redistribution_allowed\": true",
          with: "\"redistribution_allowed\": false"
        ).utf8
      )
    )

    let issues = PilotManifestValidator.validate(manifest: manifest, licenseLedger: ledger)

    #expect(issues.contains { $0.code == .redistributionNotApproved })
  }

  @Test("Frozen manifest enforces pilot coverage gate")
  func frozenManifestEnforcesCoverage() throws {
    let source = String(decoding: try fixture("pilot-manifest-valid"), as: UTF8.self)
    let manifest = try PilotManifestCodec.decodeManifest(
      Data(
        source.replacingOccurrences(of: "\"status\": \"draft\"", with: "\"status\": \"frozen\"")
          .utf8)
    )
    let ledger = try PilotManifestCodec.decodeLicenseLedger(try fixture("license-ledger-valid"))

    let codes = Set(
      PilotManifestValidator.validate(manifest: manifest, licenseLedger: ledger).map(\.code)
    )

    #expect(codes.contains(.frozenRecordCount))
    #expect(codes.contains(.frozenActionPairCount))
  }

  @Test("Unsupported manifest and ledger versions fail decoding")
  func unsupportedVersionsFail() throws {
    let manifest = String(decoding: try fixture("pilot-manifest-valid"), as: UTF8.self)
      .replacingOccurrences(
        of: "\"schema_version\": \"0.1.0\"", with: "\"schema_version\": \"9.9.9\"")
    let ledger = String(decoding: try fixture("license-ledger-valid"), as: UTF8.self)
      .replacingOccurrences(
        of: "\"schema_version\": \"0.1.0\"", with: "\"schema_version\": \"9.9.9\"")

    #expect(throws: DecodingError.self) {
      try PilotManifestCodec.decodeManifest(Data(manifest.utf8))
    }
    #expect(throws: DecodingError.self) {
      try PilotManifestCodec.decodeLicenseLedger(Data(ledger.utf8))
    }
  }

  @Test("Committed paired fixture draft and annotations decode and validate")
  func committedPairedFixtureDraftPasses() throws {
    let manifestData = try repositoryFixture("Fixtures/PilotTrial/manifest.json")
    let manifest = try PilotManifestCodec.decodeManifest(
      manifestData
    )
    let ledger = try PilotManifestCodec.decodeLicenseLedger(
      try repositoryFixture("Fixtures/PilotTrial/license-ledger.json")
    )

    #expect(PilotManifestValidator.validate(manifest: manifest, licenseLedger: ledger).isEmpty)

    let object = try #require(JSONSerialization.jsonObject(with: manifestData) as? [String: Any])
    #expect((object["records"] as? [[String: Any]])?.count == 12)
    #expect((object["action_pairs"] as? [[String: Any]])?.count == 2)

    for annotation in [
      "paired-swiftui-home",
      "paired-swiftui-detail",
      "paired-swiftui-detail-after-home-action",
      "paired-swiftui-form",
      "paired-swiftui-modal",
      "paired-swiftui-long-list",
      "paired-uikit-home",
      "paired-uikit-detail",
      "paired-uikit-detail-after-home-action",
      "paired-uikit-form",
      "paired-uikit-modal",
      "paired-uikit-long-list",
    ] {
      _ = try UIStateCodec.decode(
        try repositoryFixture("Fixtures/PilotTrial/Annotations/\(annotation).json")
      )
    }
  }

  @Test("Committed paired fixture bundle identifiers match the Xcode targets")
  func committedPairedFixtureBundleIdentifiersMatchTargets() throws {
    let data = try repositoryFixture("Fixtures/PilotTrial/manifest.json")
    let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let records = try #require(object["records"] as? [[String: Any]])
    let expectedIdentifiers = [
      "swiftui": "org.thliu21.uistatecompiler.swiftuifixture",
      "uikit": "org.thliu21.uistatecompiler.uikitfixture",
    ]

    for record in records {
      let framework = try #require(record["framework"] as? String)
      let identifier = try #require(record["bundle_identifier"] as? String)
      let expectedIdentifier = try #require(expectedIdentifiers[framework])
      #expect(identifier == expectedIdentifier)
    }
  }

  private func fixture(_ name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
    return try Data(contentsOf: url)
  }

  private func repositoryFixture(_ path: String) throws -> Data {
    let repositoryRoot = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
    return try Data(contentsOf: repositoryRoot.appendingPathComponent(path))
  }
}
