import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let initialScreen: FixtureScreen
    let appearance: FixtureAppearance
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

    let home = HomeViewController()
    let navigationController = UINavigationController(rootViewController: home)
    home.onOpen = { [weak home, weak navigationController] screen in
      Self.open(
        screen,
        home: home,
        navigationController: navigationController,
        animated: true
      )
    }

    let window = UIWindow(windowScene: windowScene)
    window.overrideUserInterfaceStyle = appearance == .dark ? .dark : .light
    window.rootViewController = navigationController
    self.window = window
    window.makeKeyAndVisible()

    guard initialScreen != .home else { return }
    DispatchQueue.main.async {
      Self.open(
        initialScreen,
        home: home,
        navigationController: navigationController,
        animated: false
      )
    }
  }

  private static func open(
    _ screen: FixtureScreen,
    home: HomeViewController?,
    navigationController: UINavigationController?,
    animated: Bool
  ) {
    switch screen {
    case .home:
      navigationController?.popToRootViewController(animated: animated)
    case .detail:
      navigationController?.pushViewController(DetailViewController(), animated: animated)
    case .form:
      navigationController?.pushViewController(FormViewController(), animated: animated)
    case .modal:
      let modal = UINavigationController(rootViewController: ModalViewController())
      home?.present(modal, animated: animated)
    case .longList:
      navigationController?.pushViewController(LongListViewController(), animated: animated)
    }
  }
}
