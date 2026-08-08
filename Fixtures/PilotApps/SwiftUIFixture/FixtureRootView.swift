import SwiftUI

struct FixtureRootView: View {
  @State private var path: [FixtureScreen]
  @State private var presentsModal: Bool
  private let appearance: FixtureAppearance

  init(initialScreen: FixtureScreen, appearance: FixtureAppearance) {
    self.appearance = appearance
    _path = State(
      initialValue: initialScreen == .home || initialScreen == .modal
        ? [] : [initialScreen]
    )
    _presentsModal = State(initialValue: initialScreen == .modal)
  }

  var body: some View {
    NavigationStack(path: $path) {
      HomeScreen(open: open)
        .navigationDestination(for: FixtureScreen.self) { screen in
          destination(for: screen)
        }
    }
    .sheet(isPresented: $presentsModal) {
      ModalScreen {
        presentsModal = false
      }
    }
    .preferredColorScheme(appearance == .dark ? .dark : .light)
  }

  private func open(_ screen: FixtureScreen) {
    if screen == .modal {
      presentsModal = true
    } else if screen != .home {
      path.append(screen)
    }
  }

  @ViewBuilder
  private func destination(for screen: FixtureScreen) -> some View {
    switch screen {
    case .detail:
      DetailScreen()
    case .form:
      FormScreen()
    case .longList:
      LongListScreen()
    case .home, .modal:
      HomeScreen(open: open)
    }
  }
}
