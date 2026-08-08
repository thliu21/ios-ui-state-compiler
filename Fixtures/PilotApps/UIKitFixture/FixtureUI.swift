import UIKit

enum FixtureUI {
  static func text(_ key: String) -> String {
    NSLocalizedString(key, bundle: .main, comment: "")
  }

  static func label(
    _ key: String,
    style: UIFont.TextStyle = .body,
    color: UIColor = .label
  ) -> UILabel {
    let label = UILabel()
    label.text = text(key)
    label.font = .preferredFont(forTextStyle: style)
    label.adjustsFontForContentSizeCategory = true
    label.textColor = color
    label.numberOfLines = 0
    return label
  }

  static func button(
    _ key: String,
    systemImage: String? = nil,
    identifier: String,
    prominent: Bool = false
  ) -> UIButton {
    var configuration =
      prominent
      ? UIButton.Configuration.filled()
      : UIButton.Configuration.bordered()
    configuration.title = text(key)
    configuration.image = systemImage.flatMap(UIImage.init(systemName:))
    configuration.imagePadding = 10
    configuration.imagePlacement = .leading

    let button = UIButton(configuration: configuration)
    button.accessibilityIdentifier = identifier
    button.contentHorizontalAlignment = .leading
    return button
  }

  static func scrollingStack(in view: UIView) -> UIStackView {
    let scrollView = UIScrollView()
    let stack = UIStackView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 18

    view.addSubview(scrollView)
    scrollView.addSubview(stack)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
      stack.leadingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.leadingAnchor,
        constant: 16
      ),
      stack.trailingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.trailingAnchor,
        constant: -16
      ),
      stack.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor,
        constant: -20
      ),
      stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
    ])

    return stack
  }

  static func horizontalRow(_ views: [UIView]) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: views)
    stack.axis = .horizontal
    stack.alignment = .firstBaseline
    stack.spacing = 12
    return stack
  }

  static func card(containing content: UIView) -> UIView {
    let card = UIView()
    card.backgroundColor = .secondarySystemGroupedBackground
    card.layer.cornerRadius = 12
    content.translatesAutoresizingMaskIntoConstraints = false
    card.addSubview(content)
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
      content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
      content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
      content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
    ])
    return card
  }
}
