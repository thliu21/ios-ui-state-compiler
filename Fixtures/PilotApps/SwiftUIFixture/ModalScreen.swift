import SwiftUI

struct ModalScreen: View {
  let dismiss: () -> Void

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 20) {
        Text("fixture.modal.message")
          .font(.headline)
        Button("fixture.modal.dismiss", action: dismiss)
          .buttonStyle(.borderedProminent)
          .accessibilityIdentifier(FixtureAccessibilityID.modalDismiss)
        Spacer()
      }
      .padding()
      .accessibilityIdentifier(FixtureAccessibilityID.root(for: .modal))
      .navigationTitle("fixture.modal.title")
    }
  }
}
