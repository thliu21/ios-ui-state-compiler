/// One deterministic row shared by both fixture applications.
public struct FixtureListItem: Identifiable, Equatable, Sendable {
  public let id: String
  public let titleKey: String

  public init(id: String, titleKey: String) {
    self.id = id
    self.titleKey = titleKey
  }
}

/// Synthetic, non-personal seed data used to expose offscreen list behavior.
public enum FixtureContent {
  public static let listItems = (1...12).map { sequence in
    let suffix = sequence < 10 ? "0\(sequence)" : "\(sequence)"

    return FixtureListItem(
      id: "item-\(sequence)",
      titleKey: "fixture.list.item.\(suffix)"
    )
  }
}
