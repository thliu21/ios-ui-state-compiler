import SwiftUI

struct LongListScreen: View {
  var body: some View {
    List(FixtureContent.listItems) { item in
      HStack {
        Text(LocalizedStringKey(item.titleKey))
        Spacer()
        Text("fixture.list.status.ready")
          .foregroundStyle(.secondary)
      }
      .accessibilityIdentifier(FixtureAccessibilityID.listRow(itemID: item.id))
    }
    .accessibilityIdentifier(FixtureAccessibilityID.root(for: .longList))
    .navigationTitle("fixture.list.title")
  }
}
