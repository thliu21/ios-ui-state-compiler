import UIKit

final class LongListViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.accessibilityIdentifier = FixtureAccessibilityID.root(for: .longList)
    navigationItem.title = FixtureUI.text("fixture.list.title")
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    FixtureContent.listItems.count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let reuseIdentifier = "FixtureListRow"
    let cell =
      tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
      ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
    let item = FixtureContent.listItems[indexPath.row]
    var content = UIListContentConfiguration.valueCell()
    content.text = FixtureUI.text(item.titleKey)
    content.secondaryText = FixtureUI.text("fixture.list.status.ready")
    cell.contentConfiguration = content
    cell.accessibilityIdentifier = FixtureAccessibilityID.listRow(itemID: item.id)
    cell.selectionStyle = .none
    return cell
  }
}
