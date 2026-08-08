import UIKit

final class HomeViewController: UIViewController {
  var onOpen: ((FixtureScreen) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    view.accessibilityIdentifier = FixtureAccessibilityID.root(for: .home)
    navigationItem.title = FixtureUI.text("fixture.home.title")

    let stack = FixtureUI.scrollingStack(in: view)
    stack.addArrangedSubview(summaryRow())
    stack.addArrangedSubview(statusCard())
    stack.addArrangedSubview(
      navigationButton(
        "fixture.home.open-detail",
        image: "doc.text.magnifyingglass",
        identifier: FixtureAccessibilityID.homeOpenDetail,
        screen: .detail
      ))
    stack.addArrangedSubview(
      navigationButton(
        "fixture.home.open-form",
        image: "square.and.pencil",
        identifier: FixtureAccessibilityID.homeOpenForm,
        screen: .form
      ))
    stack.addArrangedSubview(
      navigationButton(
        "fixture.home.open-modal",
        image: "rectangle.on.rectangle",
        identifier: FixtureAccessibilityID.homeOpenModal,
        screen: .modal
      ))
    stack.addArrangedSubview(
      navigationButton(
        "fixture.home.open-long-list",
        image: "list.bullet",
        identifier: FixtureAccessibilityID.homeOpenLongList,
        screen: .longList
      ))
  }

  private func summaryRow() -> UIView {
    let image = UIImageView(image: UIImage(systemName: "sparkles"))
    image.tintColor = .tintColor
    image.isAccessibilityElement = false
    image.setContentHuggingPriority(.required, for: .horizontal)

    let summary = FixtureUI.label("fixture.home.summary", style: .headline)
    return FixtureUI.horizontalRow([image, summary])
  }

  private func statusCard() -> UIView {
    let content = UIStackView()
    content.axis = .vertical
    content.spacing = 12
    content.addArrangedSubview(FixtureUI.label("fixture.home.status.title", style: .headline))
    content.addArrangedSubview(
      statusRow("fixture.home.status.capture", value: "fixture.home.status.capture.value"))
    content.addArrangedSubview(
      statusRow("fixture.home.status.review", value: "fixture.home.status.review.value"))
    return FixtureUI.card(containing: content)
  }

  private func statusRow(_ labelKey: String, value valueKey: String) -> UIView {
    let label = FixtureUI.label(labelKey)
    let value = FixtureUI.label(valueKey, color: .secondaryLabel)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    value.setContentHuggingPriority(.required, for: .horizontal)
    return FixtureUI.horizontalRow([label, value])
  }

  private func navigationButton(
    _ key: String,
    image: String,
    identifier: String,
    screen: FixtureScreen
  ) -> UIButton {
    let button = FixtureUI.button(key, systemImage: image, identifier: identifier)
    button.addAction(
      UIAction { [weak self] _ in
        self?.onOpen?(screen)
      },
      for: .touchUpInside
    )
    return button
  }
}
