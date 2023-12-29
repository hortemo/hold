import SwiftData
import SwiftUI

@Model
class Policy {
  var name: String = "New policy"
  @Relationship(deleteRule: .cascade, inverse: \Schedule.policies) var schedules: [Schedule]? = []
  @Relationship(deleteRule: .cascade, inverse: \ActivityGroup.policies) var activityGroups:
    [ActivityGroup]? = []
  var snoozedUntil: Date?

  init(
    name: String? = nil,
    schedule: Schedule? = nil,
    activityGroup: ActivityGroup? = nil
  ) {
    if let name = name {
      self.name = name
    }

    if let schedule = schedule {
      self.schedules = [schedule]
    }

    if let activityGroup = activityGroup {
      self.activityGroups = [activityGroup]
    }
  }

  func snooze(until date: Date) {
    snoozedUntil = date
  }

  func isSnoozed(at date: Date = Date()) -> Bool {
    guard let snoozedUntil = snoozedUntil else {
      return false
    }

    return date < snoozedUntil
  }

  func isActive(at date: Date = Date()) -> Bool {
    return isSnoozed(at: date)
      ? false
      : (schedules ?? []).contains { $0.contains(date) }
  }

  func isObsolete(at date: Date = Date()) -> Bool {
    return nextDate(date) == nil
  }

  func nextDate(_ after: Date = Date()) -> Date? {
    return isSnoozed(at: after)
      ? snoozedUntil
      : (schedules ?? [])
        .compactMap { $0.nextDate(after: after) }
        .min()
  }
}
