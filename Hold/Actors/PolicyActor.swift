import DeviceActivity
import FamilyControls
import ManagedSettings
import SwiftData
import SwiftUI

@ModelActor
actor PolicyActor {
  static let shared = PolicyActor(modelContainer: HoldModelContainer.shared)

  func fetchPolicies() throws -> [Policy] {
    try modelContext.fetch(FetchDescriptor<Policy>())
  }

  func deleteObsoletePolicies(at date: Date = Date()) {
    let policies = try! fetchPolicies()
    let obsoletePolicies = policies.filter { $0.isObsolete(at: date) }
    obsoletePolicies.forEach { modelContext.delete($0) }
    try! modelContext.save()
  }

  func update() {
    let policies = try! fetchPolicies()
    ShieldManager.update(policies: policies)
  }
}
