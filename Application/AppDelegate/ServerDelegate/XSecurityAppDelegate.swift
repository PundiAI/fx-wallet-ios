import PluggableApplicationDelegate
import SnapKit
import UIKit
import WKKit

class XSecurityAppDelegate: XApplicationService {
    weak var lastFirstResponder: UIResponder?
    var isSecured: Bool {
        return XWallet.sharedKeyStore.currentWallet != nil
    }

    var verificationIsRequired: Bool {
        return XWallet.currentWallet?.wk.verificationIsRequired ?? false
    }

    var isEnable: Bool = true
    private var _secureView: UIView?
    var secureView: UIView {
        guard let view = _secureView else { let secureView = UIView(frame: UIScreen.main.bounds)
            if UIAccessibility.isReduceTransparencyEnabled == false {
                let style = UIBlurEffect.Style.dark
                let blurEffect = UIBlurEffect(style: style)
                let blurView = UIVisualEffectView(effect: blurEffect)
                secureView.backgroundColor = HDA(0x080A32)
                secureView.addSubview(blurView)
                blurView.frame = secureView.bounds
                let logoIV = UIImageView(image: IMG("launch_logo"))
                logoIV.alpha = 0.6
                secureView.addSubview(logoIV)
                if verificationIsRequired {
                    logoIV.snp.makeConstraints { make in
                        make.top.equalTo(StatusBarHeight + 54.auto())
                        make.size.equalTo(CGSize(width: 78, height: 78).auto())
                        make.centerX.equalToSuperview()
                    }
                } else {
                    logoIV.snp.makeConstraints { make in
                        make.size.equalTo(CGSize(width: 100, height: 100))
                        make.center.equalToSuperview()
                    }
                }
            } else {
                secureView.backgroundColor = HDA(0x080A32)
            }
            _secureView = secureView
            return secureView
        }
        return view
    }

    private func openSecureView() {
        guard isEnable else {
            return
        }
        if let window = self.window, isSecured {
            secureView.frame = window.bounds
            window.addSubview(secureView)
            window.bringSubviewToFront(secureView)
            if let keyboardCandidateWindow = UIApplication.shared.windows.lastObject() {
                if window.isEqual(keyboardCandidateWindow) == false {
                    let isHidden = keyboardCandidateWindow.isHidden
                    keyboardCandidateWindow.isHidden = true
                    lastFirstResponder = window.findFirst()
                    if lastFirstResponder == nil {
                        lastFirstResponder = window.rootViewController?.findFirst()
                    }
                    let inputIsHidden = lastFirstResponder?.inputAccessoryView?.isHidden ?? false
                    lastFirstResponder?.inputAccessoryView?.isHidden = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.lastFirstResponder?.resignFirstResponder()
                        keyboardCandidateWindow.isHidden = isHidden
                        self.lastFirstResponder?.inputAccessoryView?.isHidden = inputIsHidden
                    }
                }
            }
        }
    }

    private func closeSecureView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.secureView.alpha = 0
        }) { _ in
            self.secureView.removeFromSuperview()
            self.secureView.alpha = 1
            self._secureView = nil
            if self.lastFirstResponder?.canBecomeFirstResponder ?? false {
                self.lastFirstResponder?.becomeFirstResponder()
            }
        }
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        checkSecurityVerification()
        return true
    }

    func applicationDidBecomeActive(_: UIApplication) {
        closeSecureView()
        isEnable = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        openSecureView()
        application.ignoreSnapshotOnNextApplicationLaunch()
        isEnable = true
    }

    func applicationWillEnterForeground(_: UIApplication) {
        checkSecurityVerification()
    }
}

extension XSecurityAppDelegate {
    private func checkSecurityVerification() {
        guard let wallet = XWallet.currentWallet?.wk else { return }
        if wallet.verificationIsRequired, wallet.hasSecurity {
            let viewController = Router.viewController("SecurityVerificationController")
            viewController.view.frame = UIScreen.main.bounds
            viewController.view.layoutIfNeeded()
            let snapshotView = UIImageView(frame: UIScreen.main.bounds)
            snapshotView.image = viewController.view.asImage()
            Router.window?.addSubview(snapshotView)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                if Router.isSecurityVerifying {
                    snapshotView.removeFromSuperview()
                    return
                }
                Router.topViewController?.present(viewController, animated: false, completion: {
                    snapshotView.removeFromSuperview()
                })
                (viewController as? SecurityVerificationController)?.toStartVerify()
            }
        }
    }
}

extension XSecurityAppDelegate {
    public static var isTestFlight: Bool {
        return isAppStoreReceiptSandbox && !hasEmbeddedMobileProvision
    }

    public static var isAppStore: Bool {
        if isAppStoreReceiptSandbox || hasEmbeddedMobileProvision {
            return false
        }
        return true
    }

    fileprivate static var isAppStoreReceiptSandbox: Bool {
        let b = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        WKLog.Info("isAppStoreReceiptSandbox: \(b)")
        return b
    }

    fileprivate static var hasEmbeddedMobileProvision: Bool {
        let b = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        WKLog.Info("hasEmbeddedMobileProvision: \(b)")
        return b
    }

    fileprivate func appSecurityCheck() {}
}
