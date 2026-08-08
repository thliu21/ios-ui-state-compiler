import SwiftUI

struct HomeScreen: View {
  let open: (FixtureScreen) -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Image(systemName: "sparkles")
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
          Text("fixture.home.summary")
            .font(.headline)
        }

        GroupBox("fixture.home.status.title") {
          VStack(spacing: 12) {
            StatusRow(
              label: "fixture.home.status.capture",
              value: "fixture.home.status.capture.value"
            )
            Divider()
            StatusRow(
              label: "fixture.home.status.review",
              value: "fixture.home.status.review.value"
            )
          }
        }

        VStack(spacing: 12) {
          NavigationButton(
            title: "fixture.home.open-detail",
            systemImage: "doc.text.magnifyingglass",
            identifier: FixtureAccessibilityID.homeOpenDetail
          ) {
            open(.detail)
          }
          NavigationButton(
            title: "fixture.home.open-form",
            systemImage: "square.and.pencil",
            identifier: FixtureAccessibilityID.homeOpenForm
          ) {
            open(.form)
          }
          NavigationButton(
            title: "fixture.home.open-modal",
            systemImage: "rectangle.on.rectangle",
            identifier: FixtureAccessibilityID.homeOpenModal
          ) {
            open(.modal)
          }
          NavigationButton(
            title: "fixture.home.open-long-list",
            systemImage: "list.bullet",
            identifier: FixtureAccessibilityID.homeOpenLongList
          ) {
            open(.longList)
          }
        }
      }
      .padding()
    }
    .accessibilityIdentifier(FixtureAccessibilityID.root(for: .home))
    .navigationTitle("fixture.home.title")
  }
}

private struct StatusRow: View {
  let label: LocalizedStringKey
  let value: LocalizedStringKey

  var body: some View {
    HStack {
      Text(label)
      Spacer()
      Text(value)
        .foregroundStyle(.secondary)
    }
  }
}

private struct NavigationButton: View {
  let title: LocalizedStringKey
  let systemImage: String
  let identifier: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(title, systemImage: systemImage)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .buttonStyle(.bordered)
    .controlSize(.large)
    .accessibilityIdentifier(identifier)
  }
}
