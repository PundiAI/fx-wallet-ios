//
//  FxAppUpgradeAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/18.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import StoreKit


fileprivate let AppStroeAppID:String = "1504798360"

extension Router {
    static func showAppUpgradeAlert(message:String, version:String) {
        presentViewController("FxAppUpgradeAlertController", context: ["message":message,
                                                                       "version":version])
    }
}

extension FxAppUpgradeAlertController { 
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let message = context["message"] as? String, let version = context["version"] as? String else { return nil }
        let vc = FxAppUpgradeAlertController(message: message, version: version)
        return vc
    }
}

extension FxAppUpgradeAlertController: NotificationToastProtocol {
    func allowToast(notif: FxNotification) -> Bool { false }
}

class FxAppUpgradeAlertController: FxRegularPopViewController, SKStoreProductViewControllerDelegate {
    let message:String
    let version:String
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(message: String, version:String) {
        self.message = message
        self.version = version
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    override func bindListView() {
        listBinder.push(ContentCell.self, vm: (message, version))
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            Router.dismiss(self) {
                self?.toAppStore()
            }
        }
    }
    
    func toAppStore() {
        let storeProductVC = StoreKit.SKStoreProductViewController()
        storeProductVC.delegate = self
        let dict = [SKStoreProductParameterITunesItemIdentifier: AppStroeAppID]
        storeProductVC.loadProduct(withParameters: dict) { (result, error) in
            guard error == nil else {
                return
            }
        }
        Router.window?.rootViewController?.present(storeProductVC, animated: true, completion: nil)
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                Router.cNavigator?.setNeedsStatusBarAppearanceUpdate()
            }
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}


//MARK: View
extension FxAppUpgradeAlertController {
    class ContentCell: FxTableViewCell {
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        private lazy var titleLabel = UILabel(text: TR("$AppUpgrade.Title", "-"), font: XWallet.Font(ofSize: 24, weight: .medium))
        private lazy var noticeLabel = UILabel(text: "", font: XWallet.Font(ofSize: 14), lines: 0)
        
        override class func height(model: Any?) -> CGFloat {
            if let (message, _) = model as? (String, String) {
                let width = ScreenWidth - 24.auto() * 4
                let paragraphStyle = NSMutableParagraphStyle().then {
                    $0.lineSpacing = 5
                }
                let noticeHeight = message.height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14), .paragraphStyle:paragraphStyle])
                return (29 + 8 + 8 + 56).auto() + noticeHeight + 10.auto()
            }
            return (29 + 8 + 8 + 56).auto() + 40
        }
        
        override func layoutUI() {
            
            titleLabel.adjustsFontSizeToFitWidth = true 
            contentView.addSubviews([tipBackground, titleLabel, noticeLabel])
            
            tipBackground.addSubview(tipIV)
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(29.auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
        
        override func update(model: Any?) {
            if let (message, version) = model as? (String, String) {
                titleLabel.text = TR("$AppUpgrade.Title", version)
                
                let attributedString = NSMutableAttributedString(string: message)
                let paragraphStyle = NSMutableParagraphStyle().then {
                    $0.lineSpacing = 5
                }
                attributedString.addAttribute(.paragraphStyle, value:paragraphStyle,
                                              range:NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(.font, value:XWallet.Font(ofSize: 14),
                                              range:NSMakeRange(0, attributedString.length))
                noticeLabel.attributedText = attributedString
                
            }
        }
    }
}


extension FxAppUpgradeAlertController {
    class ActionCell: WKTableViewCell.ActionCell {
        override func configuration() {
            super.configuration()
            submitButton.title = TR("AppUpgrade.Action.Text")
        }
    }
}
