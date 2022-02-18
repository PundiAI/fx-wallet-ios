 
import UIKit
import WKKit
import RxSwift
import RxCocoa
 
class XWalletAppDelegate: XApplicationService { 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadServers(application, launchOptions)
        WKNavigationBar.leftButtonFont = XWallet.Font(ofSize: 18)
        WKNavigationBar.titleViewFont = XWallet.Font(ofSize: 18)
        WKNavigationBar.rightButtonFont = XWallet.Font(ofSize: 18)
        Router.resetRootController(wallet: XWallet.sharedKeyStore.currentWallet)
        return true
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier
                        extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) ->Bool {
        return false
    }
}

//MARK: Utils
extension XWalletAppDelegate { 
    private func loadServers(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        WKServer.addServer(aClass: NetworkServer.self, params: nil)
        WKServer.addServer(aClass: AccountServer.self, params: nil)
        WKServer.addServer(aClass: FxConfigServer.self, params: nil)
        WKServer.addServer(aClass: ChainTransactionServer.self, params: nil)
        WKServer.addServer(aClass: FxAppUpgradeServer.self)
        WKServer.addServer(aClass: MigrateServer.self)
    }
}
