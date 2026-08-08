/// Stable identities for the five paired UIKit and SwiftUI fixture states.
public enum FixtureScreen: String, CaseIterable, Codable, Sendable {
  case home
  case detail
  case form
  case modal
  case longList = "long_list"
}
