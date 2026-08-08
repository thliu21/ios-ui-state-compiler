import UIKit

final class ModalViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    view.accessibilityIdentifier = FixtureAccessibilityID.root(for: .modal)
    navigationItem.title = FixtureUI.text("fixture.modal.title")

    let stack = FixtureUI.scrollingStack(in: view)
    stack.addArrangedSubview(FixtureUI.label("fixture.modal.message", style: .headline))

    let dismissButton = FixtureUI.button(
      "fixture.modal.dismiss",
      identifier: FixtureAccessibilityID.modalDismiss,
      prominent: true
    )
    dismissButton.addAction(
      UIAction { [weak self] _ in
        self?.dismiss(animated: true)
      },
      for: .touchUpInside
    )
    stack.addArrangedSubview(dismissButton)
  }
}
