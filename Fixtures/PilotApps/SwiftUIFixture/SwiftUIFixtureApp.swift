import SwiftUI

@main
struct SwiftUIFixtureApp: App {
  private let initialScreen: FixtureScreen

  init() {
    do {
      initialScreen = try FixtureLaunchConfiguration(
        arguments: ProcessInfo.processInfo.arguments
      ).screen
    } catch {
      initialScreen = .home
      print("Fixture launch configuration error: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      FixtureRootView(initialScreen: initialScreen)
    }
  }
}
