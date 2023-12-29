import DeviceActivity
import Foundation
import SwiftData

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  override func intervalWillStartWarning(for activity: DeviceActivityName) {
    super.intervalWillStartWarning(for: activity)
    Task {
      await PolicyActor.shared.update()
    }
  }

  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    Task {
      await PolicyActor.shared.update()
    }
  }

  override func intervalWillEndWarning(for activity: DeviceActivityName) {
    super.intervalWillEndWarning(for: activity)
    Task {
      await PolicyActor.shared.update()
    }
  }

  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    Task {
      await PolicyActor.shared.update()
    }
  }
}
