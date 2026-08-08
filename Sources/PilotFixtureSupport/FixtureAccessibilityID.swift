/// Matching accessibility identifiers shared by the UIKit and SwiftUI targets.
public enum FixtureAccessibilityID {
  public static let homeOpenDetail = "fixture.home.open-detail"
  public static let homeOpenForm = "fixture.home.open-form"
  public static let homeOpenModal = "fixture.home.open-modal"
  public static let homeOpenLongList = "fixture.home.open-long-list"
  public static let detailPrimaryAction = "fixture.detail.primary-action"
  public static let formName = "fixture.form.name"
  public static let formNotifications = "fixture.form.notifications"
  public static let formPriority = "fixture.form.priority"
  public static let formSubmit = "fixture.form.submit"
  public static let modalDismiss = "fixture.modal.dismiss"

  public static func root(for screen: FixtureScreen) -> String {
    "fixture.\(component(for: screen)).root"
  }

  public static func listRow(itemID: String) -> String {
    "fixture.long-list.row.\(itemID)"
  }

  private static func component(for screen: FixtureScreen) -> String {
    switch screen {
    case .home, .detail, .form, .modal:
      screen.rawValue
    case .longList:
      "long-list"
    }
  }
}
