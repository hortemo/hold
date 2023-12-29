import DeviceActivity
import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

class ShieldManager {
  static func requestAuthorization() async throws {
    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
  }

  static func update(policies: [Policy]) {
    ShieldManager.updateShield(policies: policies)
    ShieldManager.updateSchedule(policies: policies)
  }

  static func updateShield(policies: [Policy]) {
    let activePolicies = policies.filter { $0.isActive() }
    let activeActivityGroups = activePolicies.flatMap { $0.activityGroups ?? [] }

    let blacklistedActivityGroups = activeActivityGroups.filter({ $0.type == .blacklist })
    let whitelistedActivityGroups = activeActivityGroups.filter({ $0.type == .whitelist })

    let blacklistedApplications =
      blacklistedActivityGroups
      .reduce(Set(), { (acc, next) in acc.union(next.applicationTokens) })
    let blacklistedWebDomains =
      blacklistedActivityGroups
      .reduce(Set(), { (acc, next) in acc.union(next.webDomainTokens) })

    let managedSettingsStore = ManagedSettingsStore()
    managedSettingsStore.shield.applications = blacklistedApplications
    managedSettingsStore.shield.webDomains = blacklistedWebDomains

    if let firstWhitelistedActivityGroup = whitelistedActivityGroups.first {
      let whitelistedApplications =
        whitelistedActivityGroups
        .reduce(
          firstWhitelistedActivityGroup.applicationTokens,
          { (acc, next) in acc.intersection(next.applicationTokens) }
        )
      let whitelistedWebDomains =
        whitelistedActivityGroups
        .reduce(
          firstWhitelistedActivityGroup.webDomainTokens,
          { (acc, next) in acc.intersection(next.webDomainTokens) }
        )
      managedSettingsStore.shield.applicationCategories = .all(except: whitelistedApplications)
      managedSettingsStore.shield.webDomainCategories = .all(except: whitelistedWebDomains)
    } else {
      managedSettingsStore.shield.applicationCategories = nil
      managedSettingsStore.shield.webDomainCategories = nil
    }
  }

  static func updateSchedule(policies: [Policy]) {
    let deviceActivityName = DeviceActivityName("nextImportantDate")
    let notificationId = "nextImportantDate"

    UNUserNotificationCenter.current()
      .removeDeliveredNotifications(withIdentifiers: [notificationId])

    let nextImportantDate = policies.compactMap({ $0.nextDate() }).min()
    if let nextImportantDate = nextImportantDate {
      let intervalLength: TimeInterval = .minutes(15)
      let warningTime: TimeInterval = .minutes(1)
      let intervalStart = nextImportantDate + warningTime
      let intervalEnd = intervalStart + intervalLength
      try! DeviceActivityCenter().startMonitoring(
        deviceActivityName,
        during: DeviceActivitySchedule(
          intervalStart: Calendar.current.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: intervalStart
          ),
          intervalEnd: Calendar.current.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: intervalEnd
          ),
          repeats: false,
          warningTime: Calendar.current.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: Date.distantPast,
            to: Date.distantPast + warningTime
          )
        )
      )

      // If shield hasn't been updated within reasonable time,
      // prompt users to open app to force update
      let content = UNMutableNotificationContent()
      content.body = "Open Hold to restart blocking"
      content.sound = nil
      UNUserNotificationCenter.current().add(
        UNNotificationRequest(
          identifier: notificationId,
          content: content,
          trigger: UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
              [.hour, .minute, .second, .nanosecond],
              from: intervalEnd + .minutes(1)
            ),
            repeats: false
          )
        )
      ) { error in }
    } else {
      DeviceActivityCenter().stopMonitoring([deviceActivityName])
      UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
  }
}
