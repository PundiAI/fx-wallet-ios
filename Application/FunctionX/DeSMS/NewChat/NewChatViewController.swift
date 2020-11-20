//
//  NewChatViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit

extension WKWrapper where Base == NewChatViewController {
    var view: NewChatViewController.View { return base.view as! NewChatViewController.View }
}

extension NewChatViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? FxWallet else { return nil }

        let vc = NewChatViewController(wallet: wallet)
        if let handler = context["handler"] as? () -> Void {
            vc.didAddContactHandler = handler
        }
        return vc
    }
}

class NewChatViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: FxWallet) {
        fx = FunctionX(wallet: wallet)
        senderName = SmsServiceManager.service(forWallet: wallet).name
        super.init(nibName: nil, bundle: nil)
    }

    fileprivate let fx: FunctionX
    private var wallet: FxWallet { fx.sms.wallet! }

    fileprivate let senderName: String
    var user = (name: "", address: "", date: "", pk: Data())

    var didAddContactHandler: (() -> Void)?

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()

        bind()
        bindNavBar()
    }

    private func bind() {
        weak var welf = self
        wk.view.searchButton.rx.tap.subscribe(onNext: { _ in
            welf?.doSearch()
        }).disposed(by: defaultBag)

        wk.view.addUserButton.rx.tap.subscribe(onNext: { _ in
            welf?.sayHiToUser()
        }).disposed(by: defaultBag)

        wk.view.inputTF.becomeFirstResponder()
    }

    private func bindNavBar() {
        navigationBar.isHidden = true
        wk.view.navBar.rightButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: defaultBag)
    }

    private func sayHiToUser() {
        let service = SmsServiceManager.service(forWallet: wallet)
        for user in service.latestContactList() {
            if user.rawValue.address == self.user.address {
                hud?.text(m: "User is already in the contact list")
                return
            }
        }

        weak var welf = self
        hud?.waiting()
        fx.sms.sendSms(toPK: user.pk, content: "Hi, i'm \(senderName)", fee: "1", gas: 80000).subscribe(onNext: { _ in
            welf?.hud?.success(m: "")
            welf?.didAddContactHandler?()
            welf?.dismiss(animated: true, completion: nil)
        }, onError: { error in
            welf?.hud?.text(m: error.asWKError().msg)
        }).disposed(by: defaultBag)
    }

    private func doSearch() {
        view.endEditing(true)
        wk.view.userContainer.isHidden = true

        weak var welf = self
        hud?.waiting()
        _ = searchSignal()
            .subscribe(onNext: { _ in
                guard let this = welf else { return }
                welf?.hud?.hide()

                this.wk.view.userContainer.isHidden = false
                this.wk.view.recordCountLabel.text = TR("NewChat.TotalRecord$", "1")

                this.wk.view.userNameLabel.text = this.user.name
                this.wk.view.userAddressLabel.text = this.user.address
                this.wk.view.userUpdateDateLabel.text = "Last update : Nov-18-2019 13:50:18"
            }, onError: {
                welf?.hud?.hide()
                welf?.hud?.text(m: $0.asWKError().msg)
            })
    }

    private func searchSignal() -> Observable<Data> {
        let text = wk.view.inputTF.text ?? ""
        if text.isEmpty { return Observable.error(WKError(-1, TR("NewChat.Title"))) }

        if text.hasPrefix("msg"), text.count > 20 {
            return fx.sms.name(ofAddress: text).flatMap {
                return self.publicKey(ofName: $0)
            }
        } else {
            return publicKey(ofName: text)
        }
    }

    private func publicKey(ofName name: String) -> Observable<Data> {
        return fx.sms.publicKey(ofName: name)
            .do(onNext: {
                self.user.pk = $0
                self.user.name = name
                if let pk = PublicKey(data: $0, type: .secp256k1)?.compressed,
                    let address = FunctionXAddress(hrp: .sms, publicKey: pk.data)?.description
                {
                    self.user.address = address
                }
            })
    }
}
