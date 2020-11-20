import UIKit
import WKKit

class XWalletAppDelegate: XApplicationService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadServers(application, launchOptions)
        WKNavigationBar.leftButtonFont = XWallet.Font(ofSize: 18)
        WKNavigationBar.titleViewFont = XWallet.Font(ofSize: 18)
        WKNavigationBar.rightButtonFont = XWallet.Font(ofSize: 18)
        Router.resetRootController(wallet: XWallet.sharedKeyStore.currentWallet)
        return true
    }
    
    func application(_: UIApplication, shouldAllowExtensionPointIdentifier _: UIApplication.ExtensionPointIdentifier) -> Bool {
        return false
    }
}

extension XWalletAppDelegate {
    private func loadServers(_: UIApplication, _: [UIApplication.LaunchOptionsKey: Any]?) {
        WKServer.addServer(aClass: NetworkServer.self, params: nil)
        WKServer.addServer(aClass: AccountServer.self, params: nil)
        WKServer.addServer(aClass: WKLanguageServer.self, params: nil)
        WKServer.addServer(aClass: WKFirebaseServer.self, params: nil)
    }
}
