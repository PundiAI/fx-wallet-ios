import Foundation
import PluggableApplicationDelegate
import UIKit
import WKKit
public class XApplicationService: NSObject, ApplicationService {
    public var window: UIWindow?
    init(nativeWindow: UIWindow) {
        super.init()
        window = nativeWindow
        window?.backgroundColor = HDA(0x080A32)
        WKRouter.mainWindowBlock = {
            nativeWindow
        }
    }
}

@UIApplicationMain
class AppDelegate: PluggableApplicationDelegate {
    override var services: [ApplicationService] {
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        return [
            XLoggerAppDelegate(nativeWindow: window),
            XConfigAppDelegate(nativeWindow: window),
            XWalletAppDelegate(nativeWindow: window),
            XSecurityAppDelegate(nativeWindow: window),
            XRemoteAppDelegate(nativeWindow: window),
        ]
    }
}
