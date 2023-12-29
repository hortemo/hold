import SwiftData
import SwiftUI

@Model
class Schedule {
  enum ScheduleType: Codable {
    case oneTime
    case weeklyRecurring
  }

  var type = ScheduleType.weeklyRecurring
  var start = Date.now
  var end = Date.now
  var allDay = true
  var weekdays = [Int]()
  var policies: [Policy]? = []

  init() {}

  func dateComponentsRepresentation() -> [(DateComponents, DateComponents)] {
    let components: Set<Calendar.Component> = [
      .year, .month, .day, .hour, .minute, .second, .nanosecond,
    ]
    let startComponents = Calendar.current.dateComponents(components, from: start)
    let endComponents = Calendar.current.dateComponents(components, from: end)

    switch type {
    case .oneTime:
      return [
        (
          DateComponents(
            year: startComponents.year,
            month: startComponents.month,
            day: startComponents.day,
            hour: allDay ? 0 : startComponents.hour,
            minute: allDay ? 0 : startComponents.minute,
            second: allDay ? 0 : startComponents.second,
            nanosecond: allDay ? 0 : startComponents.nanosecond
          ),
          DateComponents(
            year: endComponents.year,
            month: endComponents.month,
            day: endComponents.day,
            hour: allDay ? 23 : endComponents.hour,
            minute: allDay ? 59 : endComponents.minute,
            second: allDay ? 59 : endComponents.second,
            nanosecond: allDay ? 999_999_999 : endComponents.nanosecond
          )
        )
      ]
    case .weeklyRecurring:
      return weekdays.map { weekday in
        return (
          DateComponents(
            hour: allDay ? 0 : startComponents.hour,
            minute: allDay ? 0 : startComponents.minute,
            second: 0,
            nanosecond: 0,
            weekday: weekday
          ),
          DateComponents(
            hour: allDay ? 23 : endComponents.hour,
            minute: allDay ? 59 : endComponents.minute,
            second: allDay ? 59 : 0,
            nanosecond: allDay ? 999_999_999 : 0
          )
        )
      }
    }
  }

  func contains(_ date: Date = Date()) -> Bool {
    dateComponentsRepresentation().contains { (startComponents, endComponents) in
      guard
        let start = Calendar.current.nextDate(
          after: date,
          matching: startComponents,
          matchingPolicy: .nextTime,
          direction: .backward
        ),
        let end = Calendar.current.nextDate(
          after: start,
          matching: endComponents,
          matchingPolicy: .nextTime,
          direction: .forward
        )
      else {
        return false
      }

      return start <= date && date < end
    }
  }

  func nextDate(after date: Date = Date()) -> Date? {
    dateComponentsRepresentation().flatMap { (startComponents, endComponents) in
      [startComponents, endComponents].compactMap {
        Calendar.current.nextDate(
          after: date,
          matching: $0,
          matchingPolicy: .nextTime,
          direction: .forward
        )
      }
    }.min()
  }
}
