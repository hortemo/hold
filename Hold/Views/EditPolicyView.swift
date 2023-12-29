import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

struct EditPolicyView: View {
  @Environment(\.modelContext) var modelContext
  @Environment(\.presentationMode) var presentationMode

  @ObservedObject var viewModel: PolicyViewModel

  init(viewModel: PolicyViewModel) {
    self.viewModel = viewModel
  }

  func save() async {
    dismiss()

    viewModel.save(modelContext: modelContext)
    try! modelContext.save()

    try! await ShieldManager.requestAuthorization()
    
    Task {
      await PolicyActor.shared.update()
    }
  }

  func delete() {
    dismiss()

    guard let policy = viewModel.policy else {
      return
    }

    modelContext.delete(policy)
    try! modelContext.save()

    Task {
      await PolicyActor.shared.update()
    }
  }

  func snooze(for duration: TimeInterval) {
    dismiss()

    guard let policy = viewModel.policy else {
      return
    }

    policy.snooze(until: .now + duration)
    try! modelContext.save()

    Task {
      await PolicyActor.shared.update()
    }
  }

  func unsnooze() async {
    snooze(for: 0)
  }

  func dismiss() {
    presentationMode.wrappedValue.dismiss()
  }

  var body: some View {
    NavigationView {
      Form {
        TextField("Name", text: $viewModel.name)

        EditActivityGroupView(viewModel: viewModel.activityGroup)
          .disabled(viewModel.isActive)

        EditScheduleView(viewModel: viewModel.schedule)
          .disabled(viewModel.isActive)

        if !viewModel.isDraft {
          EditPolicyActionsView(
            isActive: viewModel.isActive,
            isSnoozed: viewModel.isSnoozed,
            snooze: snooze,
            unsnooze: unsnooze,
            delete: delete
          )
        }
      }.navigationTitle(viewModel.isDraft ? "New session" : "Edit session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
              dismiss()
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") {
              Task {
                await save()
              }
            }.bold()
          }
        }
    }
  }
}

#Preview{
  EditPolicyView(viewModel: PolicyViewModel())
}
