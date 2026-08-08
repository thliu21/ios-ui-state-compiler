import PilotFixtureSupport
import Testing

@Suite("Pilot fixture support")
struct PilotFixtureSupportTests {
  @Test("Catalog exposes exactly five ordered stable screen identities")
  func screenCatalogIsStable() {
    #expect(
      FixtureScreen.allCases.map(\.rawValue) == [
        "home",
        "detail",
        "form",
        "modal",
        "long_list",
      ])
  }

  @Test("Missing screen argument deterministically selects home")
  func missingArgumentSelectsHome() throws {
    let configuration = try FixtureLaunchConfiguration(arguments: ["FixtureApp"])

    #expect(configuration.screen == .home)
    #expect(configuration.appearance == .light)
  }

  @Test("Screen argument selects every fixture state", arguments: FixtureScreen.allCases)
  func argumentSelectsScreen(_ screen: FixtureScreen) throws {
    let configuration = try FixtureLaunchConfiguration(
      arguments: ["FixtureApp", "--fixture-screen", screen.rawValue]
    )

    #expect(configuration.screen == screen)
  }

  @Test("Incomplete and unknown screen arguments fail specifically")
  func invalidArgumentsFail() {
    #expect(throws: FixtureLaunchError.missingScreenValue) {
      try FixtureLaunchConfiguration(arguments: ["FixtureApp", "--fixture-screen"])
    }
    #expect(throws: FixtureLaunchError.unknownScreen("settings")) {
      try FixtureLaunchConfiguration(
        arguments: ["FixtureApp", "--fixture-screen", "settings"]
      )
    }
    #expect(throws: FixtureLaunchError.duplicateScreenArgument) {
      try FixtureLaunchConfiguration(
        arguments: [
          "FixtureApp", "--fixture-screen", "home", "--fixture-screen", "detail",
        ]
      )
    }
    #expect(throws: FixtureLaunchError.missingAppearanceValue) {
      try FixtureLaunchConfiguration(arguments: ["FixtureApp", "--fixture-appearance"])
    }
    #expect(throws: FixtureLaunchError.unknownAppearance("sepia")) {
      try FixtureLaunchConfiguration(
        arguments: ["FixtureApp", "--fixture-appearance", "sepia"]
      )
    }
    #expect(throws: FixtureLaunchError.duplicateAppearanceArgument) {
      try FixtureLaunchConfiguration(
        arguments: [
          "FixtureApp", "--fixture-appearance", "light", "--fixture-appearance", "dark",
        ]
      )
    }
  }

  @Test("Appearance argument selects light and dark deterministically")
  func appearanceArgumentSelectsStyle() throws {
    let light = try FixtureLaunchConfiguration(
      arguments: ["FixtureApp", "--fixture-appearance", "light"]
    )
    let dark = try FixtureLaunchConfiguration(
      arguments: ["FixtureApp", "--fixture-appearance", "dark"]
    )

    #expect(light.appearance == .light)
    #expect(dark.appearance == .dark)
  }

  @Test("Synthetic list data has stable, non-personal identities")
  func listDataIsStable() {
    #expect(FixtureContent.listItems.count == 12)
    #expect(FixtureContent.listItems.map(\.id) == (1...12).map { "item-\($0)" })
    #expect(Set(FixtureContent.listItems.map(\.id)).count == 12)
    #expect(FixtureContent.listItems.allSatisfy { !$0.titleKey.isEmpty })
  }

  @Test("Accessibility identifiers are framework-neutral and stable")
  func accessibilityIdentifiersAreStable() {
    #expect(FixtureAccessibilityID.root(for: .home) == "fixture.home.root")
    #expect(FixtureAccessibilityID.homeOpenDetail == "fixture.home.open-detail")
    #expect(FixtureAccessibilityID.formSubmit == "fixture.form.submit")
    #expect(
      FixtureAccessibilityID.listRow(itemID: "item-1")
        == "fixture.long-list.row.item-1")
  }
}
