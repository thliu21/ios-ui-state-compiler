public enum PilotValidationCode: String, Equatable, Hashable, Sendable {
  case ledgerIdMismatch
  case duplicateRecordID
  case duplicateActionPairID
  case duplicateLicenseEntryID
  case crossSplitApp
  case crossSplitAppFamily
  case crossSplitNearDuplicateGroup
  case missingLicenseEntry
  case redistributionNotApproved
  case brokenActionPairReference
  case actionPairContextMismatch
  case frozenRecordCount
  case frozenActionPairCount
  case missingFrameworkCoverage
  case missingLocaleCoverage
  case missingAppearanceCoverage
  case insufficientViewportCoverage
  case missingHeldOutApp
}

public struct PilotValidationIssue: Equatable, Sendable {
  public let code: PilotValidationCode
  public let subject: String

  public init(code: PilotValidationCode, subject: String) {
    self.code = code
    self.subject = subject
  }
}

public enum PilotManifestValidator {
  public static func validate(
    manifest: PilotManifest,
    licenseLedger: LicenseLedger
  ) -> [PilotValidationIssue] {
    var issues: [PilotValidationIssue] = []

    if manifest.licenseLedgerId != licenseLedger.ledgerId {
      issues.append(.init(code: .ledgerIdMismatch, subject: manifest.licenseLedgerId))
    }

    issues.append(
      contentsOf: duplicateIssues(
        manifest.records.map(\.recordId),
        code: .duplicateRecordID
      ))
    issues.append(
      contentsOf: duplicateIssues(
        manifest.actionPairs.map(\.pairId),
        code: .duplicateActionPairID
      ))
    issues.append(
      contentsOf: duplicateIssues(
        licenseLedger.entries.map(\.artifactId),
        code: .duplicateLicenseEntryID
      ))

    issues.append(
      contentsOf: splitIssues(
        manifest.records.map { ($0.appId, $0.split) },
        code: .crossSplitApp
      ))
    issues.append(
      contentsOf: splitIssues(
        manifest.records.map { ($0.appFamilyId, $0.split) },
        code: .crossSplitAppFamily
      ))
    issues.append(
      contentsOf: splitIssues(
        manifest.records.map { ($0.nearDuplicateGroup, $0.split) },
        code: .crossSplitNearDuplicateGroup
      ))

    var ledgerByID: [String: LicenseLedgerEntry] = [:]
    for entry in licenseLedger.entries where ledgerByID[entry.artifactId] == nil {
      ledgerByID[entry.artifactId] = entry
    }

    for record in manifest.records {
      for licenseID in record.licenseEntryIds {
        guard let entry = ledgerByID[licenseID] else {
          issues.append(
            .init(code: .missingLicenseEntry, subject: "\(record.recordId):\(licenseID)"))
          continue
        }

        if record.redistributionStatus == .allowed,
          !entry.redistributionAllowed
            || entry.decision != .allowedMainPipeline
            || !entry.allowedUses.contains("redistribution")
        {
          issues.append(
            .init(code: .redistributionNotApproved, subject: "\(record.recordId):\(licenseID)")
          )
        }
      }
    }

    var recordsByID: [String: PilotRecord] = [:]
    for record in manifest.records where recordsByID[record.recordId] == nil {
      recordsByID[record.recordId] = record
    }

    for pair in manifest.actionPairs {
      guard
        let before = recordsByID[pair.beforeRecordId],
        let after = recordsByID[pair.afterRecordId]
      else {
        issues.append(.init(code: .brokenActionPairReference, subject: pair.pairId))
        continue
      }

      if !hasMatchingContext(before, after) {
        issues.append(.init(code: .actionPairContextMismatch, subject: pair.pairId))
      }
    }

    if manifest.status == .frozen {
      issues.append(contentsOf: frozenCoverageIssues(manifest))
    }

    return issues
  }

  private static func duplicateIssues(
    _ values: [String],
    code: PilotValidationCode
  ) -> [PilotValidationIssue] {
    var seen: Set<String> = []
    var reported: Set<String> = []

    return values.compactMap { value in
      guard !seen.insert(value).inserted, reported.insert(value).inserted else {
        return nil
      }
      return PilotValidationIssue(code: code, subject: value)
    }
  }

  private static func splitIssues(
    _ assignments: [(String, PilotSplit)],
    code: PilotValidationCode
  ) -> [PilotValidationIssue] {
    var splitsBySubject: [String: Set<PilotSplit>] = [:]
    for (subject, split) in assignments {
      splitsBySubject[subject, default: []].insert(split)
    }

    return
      splitsBySubject
      .filter { $0.value.count > 1 }
      .keys
      .sorted()
      .map { PilotValidationIssue(code: code, subject: $0) }
  }

  private static func hasMatchingContext(_ before: PilotRecord, _ after: PilotRecord) -> Bool {
    before.appId == after.appId
      && before.pinnedRevision == after.pinnedRevision
      && before.deviceType == after.deviceType
      && before.runtime == after.runtime
      && before.viewportSizePoints == after.viewportSizePoints
      && before.orientation == after.orientation
      && before.locale == after.locale
      && before.appearance == after.appearance
      && before.dynamicType == after.dynamicType
      && before.initialStateRecipe == after.initialStateRecipe
      && before.split == after.split
  }

  private static func frozenCoverageIssues(
    _ manifest: PilotManifest
  ) -> [PilotValidationIssue] {
    var issues: [PilotValidationIssue] = []

    if manifest.records.count != 50 {
      issues.append(.init(code: .frozenRecordCount, subject: "\(manifest.records.count)"))
    }
    if manifest.actionPairs.count < 10 {
      issues.append(.init(code: .frozenActionPairCount, subject: "\(manifest.actionPairs.count)"))
    }

    let frameworks = Set(manifest.records.map(\.framework))
    let hasUIKit = frameworks.contains(.uikit) || frameworks.contains(.mixed)
    let hasSwiftUI = frameworks.contains(.swiftui) || frameworks.contains(.mixed)
    if !hasUIKit || !hasSwiftUI {
      issues.append(.init(code: .missingFrameworkCoverage, subject: "uikit_and_swiftui"))
    }

    let languagePrefixes = Set(manifest.records.map { localePrefix($0.locale) })
    if !languagePrefixes.contains("en") || !languagePrefixes.contains("zh") {
      issues.append(.init(code: .missingLocaleCoverage, subject: "en_and_zh"))
    }

    let appearances = Set(manifest.records.map(\.appearance))
    if !appearances.contains(.light) || !appearances.contains(.dark) {
      issues.append(.init(code: .missingAppearanceCoverage, subject: "light_and_dark"))
    }

    if Set(manifest.records.map(\.viewportSizePoints)).count < 2 {
      issues.append(.init(code: .insufficientViewportCoverage, subject: "fewer_than_two"))
    }

    if !manifest.records.contains(where: { $0.split == .heldOut }) {
      issues.append(.init(code: .missingHeldOutApp, subject: manifest.manifestId))
    }

    return issues
  }

  private static func localePrefix(_ locale: String) -> String {
    locale.split(whereSeparator: { $0 == "-" || $0 == "_" }).first.map(String.init) ?? locale
  }
}
