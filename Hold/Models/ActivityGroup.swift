import ManagedSettings
import SwiftData
import SwiftUI

@Model
class ActivityGroup {
  var name: String = "Activity group"
  var type = ActivityGroupType.whitelist
  var applicationTokens = Set<ApplicationToken>()
  var webDomainTokens = Set<WebDomainToken>()
  var policies: [Policy]? = []

  init() {}
}

enum ActivityGroupType: Codable {
  case whitelist
  case blacklist
}
