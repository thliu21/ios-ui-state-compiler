import SwiftUI

@main
struct SwiftUIFixtureApp: App {
  private let initialScreen: FixtureScreen
  private let appearance: FixtureAppearance

  init() {
    do {
      let configuration = try FixtureLaunchConfiguration(
        arguments: ProcessInfo.processInfo.arguments
      )
      initialScreen = configuration.screen
      appearance = configuration.appearance
    } catch {
      initialScreen = .home
      appearance = .light
      print("Fixture launch configuration error: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      FixtureRootView(initialScreen: initialScreen, appearance: appearance)
    }
  }
}
