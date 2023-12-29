import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

class ScheduleViewModel: ObservableObject {
  enum ScheduleType {
    case duration
    case oneTime
    case weeklyRecurring

    static func from(_ modelScheduleType: Schedule.ScheduleType) -> ScheduleType {
      switch modelScheduleType {
      case .oneTime:
        return .oneTime
      case .weeklyRecurring:
        return .weeklyRecurring
      }
    }

    var modelScheduleType: Schedule.ScheduleType {
      switch self {
      case .duration:
        return .oneTime
      case .oneTime:
        return .oneTime
      case .weeklyRecurring:
        return .weeklyRecurring
      }
    }
  }

  var schedule: Schedule?

  @Published var type: ScheduleType
  @Published var start: Date
  @Published var end: Date
  @Published var duration: TimeInterval
  @Published var allDay: Bool
  @Published var weekdays: [Int]

  init(
    schedule: Schedule? = nil,
    type: ScheduleType = .weeklyRecurring,
    start: Date = .now,
    end: Date = .now,
    duration: TimeInterval = .minutes(20),
    allDay: Bool = false,
    weekdays: [Int] = [2, 3, 4, 5, 6]
  ) {
    self.schedule = schedule
    self.type = type
    self.start = start
    self.end = end
    self.duration = duration
    self.allDay = allDay
    self.weekdays = weekdays
  }

  convenience init(_ schedule: Schedule?) {
    guard let schedule = schedule else {
      self.init()
      return
    }

    self.init(
      schedule: schedule,
      type: ScheduleType.from(schedule.type),
      start: schedule.start,
      end: schedule.end,
      allDay: schedule.allDay,
      weekdays: schedule.weekdays
    )
  }

  func copy() -> ScheduleViewModel {
    ScheduleViewModel(
      schedule: schedule,
      type: type,
      start: start,
      end: end,
      duration: duration,
      allDay: allDay,
      weekdays: weekdays
    )
  }

  func save(modelContext: ModelContext) -> Schedule {
    let schedule = self.schedule ?? Schedule()
    schedule.type = type.modelScheduleType
    schedule.start = type == .duration ? Date.now : start
    schedule.end = type == .duration ? Date.now + duration : end
    schedule.allDay = allDay
    schedule.weekdays = weekdays
    modelContext.insert(schedule)
    return schedule
  }

  func sortedWeekdays() -> [Int] {
    let firstWeekday = Calendar.current.firstWeekday
    return weekdays.sorted {
      ($0 >= firstWeekday) == ($1 >= firstWeekday)
        ? $0 < $1
        : $0 >= firstWeekday
    }
  }

  func weekdaysFormatted() -> String {
    switch weekdays.sorted() {
    case Array(1...7):
      return "Every day"
    case Array(2...6):
      return "Weekdays"
    case [1, 7]:
      return "Weekends"
    default:
      return sortedWeekdays()
        .map { Calendar.current.shortWeekdaySymbols[$0 - 1] }
        .joined(separator: ", ")
    }
  }

  func startDateFormatted() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return Calendar.current.isDate(start, inSameDayAs: Date.now)
      ? "Today"
      : formatter.string(from: start)
  }

  func timeOfDayFormatted() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return type == .weeklyRecurring && allDay
      ? "All day"
      : "\(formatter.string(from: start)) - \(formatter.string(from: end))"
  }

  func durationFormatted() -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    return formatter.string(from: duration) ?? ""
  }

  func formatted() -> String {
    switch type {
    case .duration:
      durationFormatted()
    case .oneTime:
      [startDateFormatted(), timeOfDayFormatted()].joined(separator: ", ")
    case .weeklyRecurring:
      [weekdaysFormatted(), timeOfDayFormatted()].joined(separator: ", ")
    }
  }
}
