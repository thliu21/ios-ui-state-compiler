import SwiftUI

struct DetailScreen: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("fixture.detail.summary")
          .font(.headline)

        GroupBox {
          VStack(spacing: 12) {
            MetadataRow(
              label: "fixture.detail.source.label",
              value: "fixture.detail.source.value"
            )
            Divider()
            MetadataRow(
              label: "fixture.detail.state.label",
              value: "fixture.detail.state.value"
            )
          }
        }

        Button("fixture.detail.primary-action") {}
          .buttonStyle(.borderedProminent)
          .accessibilityIdentifier(FixtureAccessibilityID.detailPrimaryAction)
      }
      .padding()
    }
    .accessibilityIdentifier(FixtureAccessibilityID.root(for: .detail))
    .navigationTitle("fixture.detail.title")
  }
}

private struct MetadataRow: View {
  let label: LocalizedStringKey
  let value: LocalizedStringKey

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(label)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .multilineTextAlignment(.trailing)
    }
  }
}
