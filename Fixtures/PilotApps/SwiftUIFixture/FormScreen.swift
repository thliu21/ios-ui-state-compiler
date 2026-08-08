import SwiftUI

struct FormScreen: View {
  @State private var name = ""
  @State private var notificationsEnabled = true
  @State private var priority = "normal"

  var body: some View {
    Form {
      Section("fixture.form.section.profile") {
        TextField("fixture.form.name.placeholder", text: $name)
          .accessibilityLabel(Text("fixture.form.name.label"))
          .accessibilityIdentifier(FixtureAccessibilityID.formName)

        Toggle("fixture.form.notifications", isOn: $notificationsEnabled)
          .accessibilityIdentifier(FixtureAccessibilityID.formNotifications)

        Picker("fixture.form.priority", selection: $priority) {
          Text("fixture.form.priority.normal").tag("normal")
          Text("fixture.form.priority.high").tag("high")
        }
        .accessibilityIdentifier(FixtureAccessibilityID.formPriority)
      }

      Section {
        Button("fixture.form.submit") {}
          .disabled(name.isEmpty)
          .accessibilityIdentifier(FixtureAccessibilityID.formSubmit)
      }
    }
    .accessibilityIdentifier(FixtureAccessibilityID.root(for: .form))
    .navigationTitle("fixture.form.title")
  }
}
