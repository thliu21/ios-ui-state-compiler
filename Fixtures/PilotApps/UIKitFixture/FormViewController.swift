import UIKit

final class FormViewController: UIViewController {
  private let nameField = UITextField()
  private let submitButton = FixtureUI.button(
    "fixture.form.submit",
    identifier: FixtureAccessibilityID.formSubmit,
    prominent: true
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
    view.accessibilityIdentifier = FixtureAccessibilityID.root(for: .form)
    navigationItem.title = FixtureUI.text("fixture.form.title")

    let stack = FixtureUI.scrollingStack(in: view)
    stack.addArrangedSubview(FixtureUI.label("fixture.form.section.profile", style: .headline))
    stack.addArrangedSubview(configureNameField())
    stack.addArrangedSubview(notificationsRow())
    stack.addArrangedSubview(priorityControl())

    submitButton.isEnabled = false
    stack.addArrangedSubview(submitButton)
  }

  private func configureNameField() -> UITextField {
    nameField.borderStyle = .roundedRect
    nameField.font = .preferredFont(forTextStyle: .body)
    nameField.adjustsFontForContentSizeCategory = true
    nameField.placeholder = FixtureUI.text("fixture.form.name.placeholder")
    nameField.accessibilityLabel = FixtureUI.text("fixture.form.name.label")
    nameField.accessibilityIdentifier = FixtureAccessibilityID.formName
    nameField.addAction(
      UIAction { [weak self] _ in
        self?.submitButton.isEnabled = !(self?.nameField.text?.isEmpty ?? true)
      },
      for: .editingChanged
    )
    return nameField
  }

  private func notificationsRow() -> UIView {
    let label = FixtureUI.label("fixture.form.notifications")
    let toggle = UISwitch()
    toggle.isOn = true
    toggle.accessibilityIdentifier = FixtureAccessibilityID.formNotifications
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    toggle.setContentHuggingPriority(.required, for: .horizontal)
    return FixtureUI.horizontalRow([label, toggle])
  }

  private func priorityControl() -> UIView {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 8
    stack.addArrangedSubview(FixtureUI.label("fixture.form.priority"))

    let control = UISegmentedControl(items: [
      FixtureUI.text("fixture.form.priority.normal"),
      FixtureUI.text("fixture.form.priority.high"),
    ])
    control.selectedSegmentIndex = 0
    control.accessibilityIdentifier = FixtureAccessibilityID.formPriority
    stack.addArrangedSubview(control)
    return stack
  }
}
