import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

struct EditActivityGroupView: View {
  @ObservedObject var viewModel: ActivityGroupViewModel

  @State var activityPickerIsPresented = false

  var prefix: String {
    viewModel.type == .whitelist
      ? "Allowed"
      : "Blocked"
  }

  var body: some View {
    Section {
      HStack {
        Text("\(prefix) apps")
        Spacer()
        Button("\(viewModel.numOfApplications) apps") {
          Task {
            try! await ShieldManager.requestAuthorization()
            activityPickerIsPresented = true
          }
        }.familyActivityPicker(
          isPresented: $activityPickerIsPresented,
          selection: $viewModel.selection
        )
      }
      HStack {
        Text("\(prefix) websites")
        Spacer()
        Button("\(viewModel.numOfWebDomains) websites") {
          activityPickerIsPresented = true
        }.familyActivityPicker(
          isPresented: $activityPickerIsPresented,
          selection: $viewModel.selection
        )
      }
    } header: {
      HStack {
        Text("Apps and websites")
        Spacer()
        Picker("Apps and websites", selection: $viewModel.type) {
          Text("Blocklist").tag(ActivityGroupType.blacklist)
          Text("Allowlist").tag(ActivityGroupType.whitelist)
        }.textCase(nil)
      }
    } footer: {
      if viewModel.numOfApplications > 49 || viewModel.numOfWebDomains > 49 {
        Text("Select up to 49 apps and 49 websites")
          .foregroundStyle(.red)
      }
    }
  }
}

#Preview{
  Form {
    EditActivityGroupView(viewModel: ActivityGroupViewModel())
  }
}
