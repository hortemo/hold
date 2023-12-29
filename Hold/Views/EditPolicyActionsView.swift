import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

struct EditPolicyActionsView: View {
  @Environment(\.scenePhase) var scenePhase
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var isActive: Bool
  var isSnoozed: Bool
  var snooze: (TimeInterval) async -> Void
  var unsnooze: () async -> Void
  var delete: () async -> Void
  
  @State var now = Date()
  @State var appearedAt = Date()
  @State var showingSnoozeSheet = false
  
  var actionsDelay: TimeInterval {
#if DEBUG
    return 2.0
#else
    return 10.0
#endif
  }
  
  func handleAppear() {
    appearedAt = Date.now
    now = Date.now
  }
  
  var timeUntilActionsAreEnabled: TimeInterval {
    isActive
    ? actionsDelay - now.timeIntervalSince(appearedAt)
    : 0
  }
  
  var actionsAreEnabled: Bool {
    timeUntilActionsAreEnabled <= 0
  }
  
  var body: some View {
    Section {
      if isSnoozed {
        Button("Unsnooze") {
          Task {
            await unsnooze()
          }
        }.tint(.purple)
      } else {
        Button("Snooze") {
          showingSnoozeSheet = true
        }.tint(.purple)
      }
      Button("Delete", role: .destructive) {
        Task {
          await delete()
        }
      }
    } header: {
      HStack {
        Text("Actions")
        Spacer()
        if !actionsAreEnabled {
          let secondsRemaining = Int(ceil(timeUntilActionsAreEnabled))
          Text("Available in \(secondsRemaining)")
            .textCase(nil)
        }
      }
    }.disabled(!actionsAreEnabled)
      .onAppear {
        handleAppear()
      }
      .onChange(of: scenePhase) { oldPhase, newPhase in
        if newPhase == .active {
          handleAppear()
        }
      }
      .onReceive(timer) { time in
        now = time
      }
      .sheet(isPresented: $showingSnoozeSheet) {
        SnoozeDurationSheet { duration in
          Task {
            await snooze(duration)
          }
        }
      }
  }
}

#Preview{
  Form {
    EditPolicyActionsView(
      isActive: true,
      isSnoozed: false,
      snooze: { duration in },
      unsnooze: {},
      delete: {}
    )
  }
}

struct SnoozeDurationSheet: View {
  struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = nextValue()
    }
  }
  
  var onSubmit: (TimeInterval) -> Void
  
  @State var snoozeSheetHeight: CGFloat = InnerHeightPreferenceKey.defaultValue
  @State var duration: TimeInterval = .minutes(5)
  
  var body: some View {
    VStack {
      Text("Snooze session")
        .font(.title3)
        .fontDesign(.rounded)
        .fontWeight(.medium)
      
      DurationPicker(selection: $duration)
      
      Button {
        onSubmit(duration)
      } label: {
        Text("Snooze")
          .fontDesign(.rounded)
          .fontWeight(.medium)
          .frame(maxWidth: .infinity, minHeight: 50)
          .background(.purple)
          .foregroundColor(.white)
          .cornerRadius(.infinity)
      }
    }.padding()
      .overlay {
        GeometryReader { geometry in
          Color.clear.preference(
            key: InnerHeightPreferenceKey.self,
            value: geometry.size.height
          )
        }
      }
      .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
        snoozeSheetHeight = newHeight
      }
      .presentationDetents([.height(snoozeSheetHeight)])
  }
}

#Preview{
  SnoozeDurationSheet { duration in }
}
