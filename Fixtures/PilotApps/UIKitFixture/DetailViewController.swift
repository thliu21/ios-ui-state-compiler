import UIKit

final class DetailViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    view.accessibilityIdentifier = FixtureAccessibilityID.root(for: .detail)
    navigationItem.title = FixtureUI.text("fixture.detail.title")

    let stack = FixtureUI.scrollingStack(in: view)
    stack.addArrangedSubview(FixtureUI.label("fixture.detail.summary", style: .headline))

    let metadata = UIStackView()
    metadata.axis = .vertical
    metadata.spacing = 12
    metadata.addArrangedSubview(
      metadataRow("fixture.detail.source.label", value: "fixture.detail.source.value"))
    metadata.addArrangedSubview(
      metadataRow("fixture.detail.state.label", value: "fixture.detail.state.value"))
    stack.addArrangedSubview(FixtureUI.card(containing: metadata))

    let action = FixtureUI.button(
      "fixture.detail.primary-action",
      identifier: FixtureAccessibilityID.detailPrimaryAction,
      prominent: true
    )
    stack.addArrangedSubview(action)
  }

  private func metadataRow(_ labelKey: String, value valueKey: String) -> UIView {
    let label = FixtureUI.label(labelKey, color: .secondaryLabel)
    let value = FixtureUI.label(valueKey)
    value.textAlignment = .right
    label.setContentHuggingPriority(.required, for: .horizontal)
    return FixtureUI.horizontalRow([label, value])
  }
}
