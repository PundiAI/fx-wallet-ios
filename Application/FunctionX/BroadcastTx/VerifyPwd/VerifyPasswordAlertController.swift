//
//  VerifyPasswordAlertController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift

extension VerifyPasswordAlertController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        
        let password = context["password"] as? String
        let vc = VerifyPasswordAlertController(password)
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class VerifyPasswordAlertController: WKPopViewController {

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ password: String?) {
        self.binder = PwdVerifyBinder(view: PwdVerifyView(frame: ScreenBounds), password: password)
        super.init(nibName: nil, bundle: nil)
    }
    
    private let binder: PwdVerifyBinder
    var completionHandler: ((WKError?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        layoutUI()
        configuration()
        logWhenDeinit()
        
        binder.startVerify()
        self.view.layoutIfNeeded()
    }
    
    private func bind() {
        
        weak var welf = self
        let backAction = CocoaAction({ welf?.executeCompletionHandler(error: .canceled) })
        let confirmAction = Action<Bool, Void>(workFactory: { passed in
            if !passed {
                welf?.hud?.error(m: "password error")
            } else {
                welf?.executeCompletionHandler()
            }
            return CocoaObservable.empty()
        })
        binder.bind(backAction: backAction, confirmAction: confirmAction)
    }
    
    private func executeCompletionHandler(error: WKError? = nil) {
        
        let handler = self.completionHandler
        dismiss(animated: true) {
            handler?(error)
        }
    }
    
    //MARK: Utils
    private func configuration() {
        
        transitioning.alertType = .sheet
        transitioningDelegate = transitioning
        contentView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
    }
    
    private func layoutUI() {
        
        backgroundView.gradientBGLayerForPop.frame = ScreenBounds
        binder.view.confirmButton.doGradient67x46(title: "OK")
        
        self.contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(self.binder.view)
        self.binder.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
