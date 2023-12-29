import ManagedSettings
import ManagedSettingsUI
import SwiftUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  let cyan = UIColor(red: 0.39, green: 0.82, blue: 1.00, alpha: 1.00)

  func shieldConfiguration(
    application: Application? = nil,
    webDomain: WebDomain? = nil
  ) -> ShieldConfiguration {
    let name = application?.localizedDisplayName ?? webDomain?.domain ?? "this app"
    return ShieldConfiguration(
      backgroundBlurStyle: .dark,
      backgroundColor: .black,
      icon: UIImage(named: "appIconCircularBlack"),
      title: ShieldConfiguration.Label(text: "Hold up!", color: cyan),
      subtitle: ShieldConfiguration.Label(
        text: "\(name) is blocked.", color: .white),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: .black),
      primaryButtonBackgroundColor: cyan
    )
  }

  override func configuration(shielding application: Application) -> ShieldConfiguration {
    return shieldConfiguration(application: application)
  }

  override func configuration(shielding application: Application, in category: ActivityCategory)
    -> ShieldConfiguration
  {
    return shieldConfiguration(application: application)
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    return shieldConfiguration(webDomain: webDomain)
  }

  override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory)
    -> ShieldConfiguration
  {
    return shieldConfiguration(webDomain: webDomain)
  }
}
