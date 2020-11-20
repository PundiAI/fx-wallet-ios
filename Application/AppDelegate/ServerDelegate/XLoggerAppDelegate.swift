import Foundation
import PluggableApplicationDelegate
import TrustWalletCore
import WKKit

final class XLoggerAppDelegate: XApplicationService {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        WKLog.Config(level: .debug, debug: ServerENV.current != .release)
        return true
    }
}
