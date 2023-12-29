import Foundation

extension TimeInterval {
  static let second: TimeInterval = 1
  static let minute: TimeInterval = 60 * second
  static let hour: TimeInterval = 60 * minute
  static let day: TimeInterval = 24 * hour

  static func seconds(_ count: Double) -> TimeInterval {
    count * second
  }

  static func minutes(_ count: Double) -> TimeInterval {
    count * minute
  }

  static func hours(_ count: Double) -> TimeInterval {
    count * hour
  }

  static func days(_ count: Double) -> TimeInterval {
    count * day
  }

  var seconds: Int {
    Int(magnitude)
  }

  var minutes: Int {
    Int(magnitude / TimeInterval.minute)
  }

  var hours: Int {
    Int(magnitude / TimeInterval.hour)
  }

  var days: Int {
    Int(magnitude / TimeInterval.day)
  }
}
