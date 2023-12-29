import DeviceActivity
import FamilyControls
import SwiftData
import SwiftUI
import UserNotifications

@main
struct HoldApp: App {
  @Environment(\.scenePhase) var scenePhase

  let modelContainer = HoldModelContainer.shared

  init() {
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.provisional]) {
        granted, error in
      }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) {
          if scenePhase == .active {
            Task {
              await PolicyActor.shared.deleteObsoletePolicies()
              await PolicyActor.shared.update()
            }
          }
        }
    }
  }
}

struct ContentView: View {
  @Environment(\.modelContext) var modelContext

  @State var newPolicyViewModel: PolicyViewModel?

  func handleHoldButtonPress() {
    newPolicyViewModel = PolicyViewModel(
      name: "⏸️ Deep focus",
      schedule: ScheduleViewModel(
        type: .duration
      ),
      activityGroup: ActivityGroupViewModel(
        type: .whitelist
      )
    )
  }

  var body: some View {
    VStack {
      ZStack(alignment: .bottom) {
        TabView {
          PoliciesView()
            .toolbar(.hidden, for: .tabBar)
        }

        Button(action: handleHoldButtonPress) {
          Image("appIconCircularBlack")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
        }.sheet(item: $newPolicyViewModel) { viewModel in
          EditPolicyView(viewModel: viewModel)
        }
      }
    }
  }
}
