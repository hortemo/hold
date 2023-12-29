import Foundation
import SwiftData

class HoldModelContainer {
  static let shared = try! ModelContainer(for: Policy.self)
  
  private init() {}
}
