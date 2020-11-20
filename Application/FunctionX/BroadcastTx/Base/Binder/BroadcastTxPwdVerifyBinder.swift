//
//  BroadcastTxPwdInputBinder.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import RxCocoa
import RxSwift
import WKKit

// extension BroadcastTxAlertController {
class PwdVerifyBinder {
    let view: PwdVerifyView

    let bag = DisposeBag()
    private var confirmAction: Action<Bool, Void>?
    private let password: String?

    init(view: PwdVerifyView, password: String? = nil) {
        self.view = view
        self.password = password ?? XWallet.sharedKeyStore.currentWallet?.accessCode

        bind()
        bindKeyboard()
    }

    func bind() {
        if !LocalAuthManager.shared.isUsable {
            view.relayoutForPwd()
        } else {
            weak var welf = self
            view.bioStartButton.rx.tap.subscribe(onNext: { _ in
                welf?.startBioVerify()
            }).disposed(by: bag)

            view.verifyPwdButton.rx.tap.subscribe(onNext: { _ in
                welf?.startPwdVerify()
            }).disposed(by: bag)
        }
    }

    func bind(backAction: CocoaAction, confirmAction: Action<Bool, Void>) {
        self.confirmAction = confirmAction
        let enabled = view.inputTF.rx.text.map { ($0?.count ?? 0) >= 6 }
        view.backButton.rx.action = backAction
        view.confirmButton.rx.action = CocoaAction(enabledIf: enabled, workFactory: { [weak self] _ in
            if let this = self {
                confirmAction.execute(this.password == this.view.inputTF.text)
            }
            return CocoaObservable.empty()
        })
    }

    func startVerify() {
        if LocalAuthManager.shared.isUsable {
            startBioVerify()
        } else {
            startPwdVerify()
        }
    }

    private func startBioVerify() {
        view.relayoutForBio()

        let isTouchID = LocalAuthManager.shared.isAuthTouch
        var config = LocalAuthConfiguration()
        config.authReason = TR(isTouchID ? "Biometrics.AuthTouchID" : "Biometrics.AuthFaceID")
        //            config.authFallbackTitle = TR("Cancel")
        LocalAuthManager.shared.auth(config: config) { [weak self] result in
            switch result {
            case .errorUserCancel: break
            default:
                self?.confirmAction?.execute(result.isSuccess)
            }
        }
    }

    private func startPwdVerify() {
        view.relayoutForPwd()
        view.inputTF.reactiveText = ""
        view.inputTF.becomeFirstResponder()
    }

    private func bindKeyboard() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self, this.view.inputTF.isFirstResponder else { return }

                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y

                this.view.containerView.snp.updateConstraints { make in
                    make.bottom.equalTo(this.view).offset(-margin)
                }
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: bag)
    }
}

// }
