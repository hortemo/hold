import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

class ActivityGroupViewModel: ObservableObject {
  var activityGroup: ActivityGroup?

  @Published var type: ActivityGroupType
  @Published var selection = FamilyActivitySelection(includeEntireCategory: true)

  init(
    activityGroup: ActivityGroup? = nil,
    type: ActivityGroupType = .blacklist,
    applicationTokens: Set<ApplicationToken> = [],
    webDomainTokens: Set<WebDomainToken> = []
  ) {
    self.activityGroup = activityGroup
    self.type = type
    selection.applicationTokens = applicationTokens
    selection.webDomainTokens = webDomainTokens
  }

  convenience init(_ activityGroup: ActivityGroup?) {
    guard let activityGroup = activityGroup else {
      self.init()
      return
    }

    self.init(
      activityGroup: activityGroup,
      type: activityGroup.type,
      applicationTokens: activityGroup.applicationTokens,
      webDomainTokens: activityGroup.webDomainTokens
    )
  }

  var numOfApplications: Int {
    selection.applicationTokens.count
  }

  var numOfWebDomains: Int {
    selection.webDomainTokens.count
  }

  func copy() -> ActivityGroupViewModel {
    ActivityGroupViewModel(
      activityGroup: activityGroup,
      type: type,
      applicationTokens: selection.applicationTokens,
      webDomainTokens: selection.webDomainTokens
    )
  }

  func save(modelContext: ModelContext) -> ActivityGroup {
    let activityGroup = self.activityGroup ?? ActivityGroup()
    activityGroup.type = type
    activityGroup.applicationTokens = selection.applicationTokens
    activityGroup.webDomainTokens = selection.webDomainTokens
    modelContext.insert(activityGroup)
    return activityGroup
  }

  func formatted() -> String {
    let counts = [
      numOfApplications > 0 ? "\(numOfApplications) apps" : nil,
      numOfWebDomains > 0 ? "\(numOfWebDomains) websites" : nil,
    ].compactMap { $0 }
    let prefix = counts.count > 0 ? counts.joined(separator: ", ") : "No apps"
    let postfix = type == .blacklist ? "blocked" : "allowed"
    return "\(prefix) \(postfix)"
  }
}
