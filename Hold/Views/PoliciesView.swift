import FamilyControls
import Foundation
import SwiftData
import SwiftUI

struct PoliciesView: View {
  @Query var policies: [Policy]

  @State var showFeedbackView = false
  @State var editingPolicyViewModel: PolicyViewModel? = nil

  let templates = [
    PolicyViewModel(
      name: "☀️ Mindful mornings",
      schedule: ScheduleViewModel(
        start: Calendar.current.date(from: DateComponents(hour: 6, minute: 0))!,
        end: Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        weekdays: [2, 3, 4, 5, 6]
      )
    ),
    PolicyViewModel(
      name: "📖 Study hours",
      schedule: ScheduleViewModel(
        start: Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        end: Calendar.current.date(from: DateComponents(hour: 15, minute: 0))!,
        weekdays: [2, 3, 4, 5, 6]
      )
    ),
    PolicyViewModel(
      name: "💼 No work after work",
      schedule: ScheduleViewModel(
        start: Calendar.current.date(from: DateComponents(hour: 18, minute: 0))!,
        end: Calendar.current.date(from: DateComponents(hour: 00, minute: 0))!,
        weekdays: [2, 3, 4, 5, 6]
      )
    ),
    PolicyViewModel(
      name: "😴 Sleep well",
      schedule: ScheduleViewModel(
        start: Calendar.current.date(from: DateComponents(hour: 23, minute: 0))!,
        end: Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!,
        weekdays: [1, 2, 3, 4, 5]
      ),
      activityGroup: ActivityGroupViewModel(
        type: .whitelist
      )
    ),
    PolicyViewModel(
      name: "🔁 Always on",
      schedule: ScheduleViewModel(
        allDay: true,
        weekdays: [1, 2, 3, 4, 5, 6, 7]
      )
    ),
  ]

  func newPolicy() {
    let viewModel = PolicyViewModel()
    viewModel.name = "⏸️ New session"
    editingPolicyViewModel = viewModel
  }

  func editPolicy(_ policy: Policy) {
    let viewModel = PolicyViewModel(policy)
    editingPolicyViewModel = viewModel
  }

  func newPolicy(template: PolicyViewModel) {
    editingPolicyViewModel = template.copy()
  }

  let listRowInsets = EdgeInsets(
    top: 5,
    leading: 20,
    bottom: 5,
    trailing: 20
  )

  var body: some View {
    NavigationView {
      List {
        Section {
          ForEach(policies) { policy in
            PolicyCardView(policy: policy).onTapGesture {
              editPolicy(policy)
            }
          }
        }.listRowSeparator(.hidden)
          .listRowInsets(listRowInsets)

        Section("Suggestions") {
          ForEach(templates) { template in
            PolicyCardView(template: template).onTapGesture {
              newPolicy(template: template)
            }
          }
        }.listRowSeparator(.hidden)
          .listRowInsets(listRowInsets)

        Section("") {
          EmptyView()
        }.padding(.bottom, 50)
      }.listStyle(.plain)
        .navigationTitle("Sessions")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              showFeedbackView = true
            } label: {
              Text("Feedback")
            }.sheet(isPresented: $showFeedbackView) {
              FeedbackView()
            }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              newPolicy()
            } label: {
              Image(systemName: "plus")
            }.bold()
          }
        }.sheet(item: $editingPolicyViewModel, onDismiss: {}) { viewModel in
          EditPolicyView(viewModel: viewModel)
        }
    }
  }
}
