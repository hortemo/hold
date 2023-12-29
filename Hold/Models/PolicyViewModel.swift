import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

class PolicyViewModel: ObservableObject, Identifiable {
  var policy: Policy?

  @Published var name: String
  @Published var schedule: ScheduleViewModel
  @Published var activityGroup: ActivityGroupViewModel

  init(
    policy: Policy? = nil,
    name: String = "New policy",
    schedule: ScheduleViewModel = ScheduleViewModel(),
    activityGroup: ActivityGroupViewModel = ActivityGroupViewModel()
  ) {
    self.policy = policy
    self.name = name
    self.schedule = schedule
    self.activityGroup = activityGroup
  }

  convenience init(_ policy: Policy?) {
    guard let policy = policy else {
      self.init()
      return
    }

    self.init(
      policy: policy,
      name: policy.name,
      schedule: ScheduleViewModel(policy.schedules?.first),
      activityGroup: ActivityGroupViewModel(policy.activityGroups?.first)
    )
  }

  func copy() -> PolicyViewModel {
    PolicyViewModel(
      policy: policy,
      name: name,
      schedule: schedule.copy(),
      activityGroup: activityGroup.copy()
    )
  }

  var isActive: Bool {
    policy?.isActive() ?? false
  }

  var isSnoozed: Bool {
    policy?.isSnoozed() ?? false
  }

  var isDraft: Bool {
    policy == nil
  }

  func save(modelContext: ModelContext) -> Policy {
    let policy = self.policy ?? Policy()
    policy.name = name

    let schedule = schedule.save(modelContext: modelContext)
    policy.schedules = [schedule]

    let activityGroup = activityGroup.save(modelContext: modelContext)
    policy.activityGroups = [activityGroup]

    modelContext.insert(policy)
    return policy
  }
}
