import Alamofire
import PluggableApplicationDelegate
import PromiseKit
import RxSwift
import UIKit
import WKKit

class XConfigAppDelegate: XApplicationService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        loadServers(application, launchOptions)
        return true
    }

    private func loadServers(_: UIApplication, _: [UIApplication.LaunchOptionsKey: Any]?) {}
}
