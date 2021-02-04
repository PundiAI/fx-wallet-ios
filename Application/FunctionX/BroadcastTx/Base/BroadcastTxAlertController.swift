//
//  BroadcastTxViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import SwiftyJSON
import TrustWalletCore

extension BroadcastTxAlertController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
        let privateKey = context["privateKey"] as? PrivateKey else { return nil }
        
        let vc = BroadcastTxAlertController(tx: tx, privateKey: privateKey)
        vc.commitTxImp = context["commitTxImp"] as? Observable<JSON>
        vc.completionHandler = context["handler"] as? (WKError?, JSON) -> Void
        return vc
    }
}

class BroadcastTxAlertController: WKPopViewController {

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, privateKey: PrivateKey) {
        self.tx = tx
        self.privateKey = privateKey
        super.init(nibName: nil, bundle: nil)
    }
    
    let tx: FxTransaction
    let privateKey: PrivateKey
    private let viewS = View(frame: ScreenBounds)
    
    private var keeper: Any?
    fileprivate lazy var infoBinder = InfoBinder(view: viewS.infoView)
    fileprivate lazy var pwdVerifyBinder = PwdVerifyBinder(view: viewS.pwdVerifyView)
    fileprivate lazy var committingBinder = CommittingBinder(view: viewS.committingView)
    fileprivate lazy var resultBinder = ResultBinder(view: viewS.resultView)
    var completionHandler: ((WKError?, JSON) -> Void)?
    var commitTxImp: Observable<JSON>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindInfo()
        bindPwdVerify()
        bindCommitting()
        bindResult()
        
        layoutUI()
        configuration()
        logWhenDeinit()
        
        self.view.layoutIfNeeded()
    }
    
    private func bindInfo() {
        
        weak var welf = self
        let confirmAction = CocoaAction({
            
            welf?.viewS.containerView.setContentOffset(CGPoint(x: ScreenWidth, y: 0), animated: true)
            welf?.pwdVerifyBinder.startVerify()
        })
        infoBinder.bind(tx, closeAction: closeAction, confirmAction: confirmAction)
    }
    
    private func bindPwdVerify() {
        
        weak var welf = self
        let backAction = CocoaAction({
            
            welf?.viewS.pwdVerifyView.inputTF.resignFirstResponder()
            welf?.viewS.containerView.setContentOffset(.zero, animated: true)
        })
        
        let confirmAction = Action<Bool, Void>(workFactory: { passed in
            if passed {
                
                welf?.keeper = welf
                welf?.viewS.pwdVerifyView.inputTF.resignFirstResponder()
                welf?.viewS.containerView.setContentOffset(CGPoint(x: ScreenWidth * 2, y: 0), animated: true)
                welf?.committingBinder.commitAction.execute()
            } else {
                welf?.hud?.error(m: "password error")
            }
            return CocoaObservable.empty()
        })
        pwdVerifyBinder.bind(backAction: backAction, confirmAction: confirmAction)
    }
    
    private func bindCommitting() {
        committingBinder.bind(tx, closeAction: closeAction, privateKey: privateKey, commitTxImp: commitTxImp)
    }
    
    private func bindResult() {
        
        resultBinder.bind(tx, closeAction: closeAction)
        
        weak var welf = self
        committingBinder.commitAction.elements.subscribe(onNext: { (result) in
            guard let this = welf else { return }
            
            this.viewS.resultView.listView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                this.viewS.containerView.setContentOffset(CGPoint(x: ScreenWidth * 3, y: 0), animated: true)
            }
            this.executeCompletionHandler(result: result)
        }).disposed(by: defaultBag)
        
        committingBinder.commitAction.errors.subscribe(onNext: { (err) in
            guard let this = welf else { return }
            this.executeCompletionHandler(error: err.wk)
        }).disposed(by: defaultBag)
    }
    
    private func executeCompletionHandler(error: WKError? = nil, result: JSON = [:]) {
        
        if error != nil {
            self.hud?.text(m: error?.msg ?? "commit tx failed", d: 3, p: .center)
        }
        completionHandler?(error, result)
        keeper = nil
    }
    
    //MARK: Utils
    private var closeAction: CocoaAction {
        return CocoaAction({[weak self] in
            self?.completionHandler?(.canceled, [:])
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func configuration() {
        
        transitioning.alertType = .sheet
        transitioningDelegate = transitioning
        contentView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
    }
    
    private func layoutUI() {
        
        backgroundView.gradientBGLayerForPop.frame = ScreenBounds
        
        self.contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(viewS)
        viewS.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
