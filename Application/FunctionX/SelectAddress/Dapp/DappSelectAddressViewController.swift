//
//  DappSelectAddressViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import RxSwift
import TrustWalletCore
import WKKit

extension DappSelectAddressViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let dapp = context["dapp"] as? Dapp else { return nil }

        let token = context["token"] as? String
        let chain = context["chain"] as? FxChain.Types ?? .hub
        let vc = DappSelectAddressViewController(wallet: wallet, dapp: dapp, chain: chain, token: token)
        if let handler = context["handler"] as? (UIViewController?, Keypair) -> Void {
            vc.confirmHandler = handler
        }
        return vc
    }
}

class DappSelectAddressViewController: SelectAddressViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet, dapp: Dapp, chain: FxChain.Types, token: String? = nil) {
        self.dapp = dapp
        self.token = token
        self.chain = dapp.isSms ? .sms : chain
        super.init(wallet: wallet)
    }

    let dapp: Dapp
    let chain: FxChain.Types
    let token: String?
    var fx: FunctionX { FunctionX.shared }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindDapp()
    }

    override func onClickConfirm() {
        guard let item = selectedItem else { return }

        if !dapp.isSms {
            confirm(item)
        } else {
            registerToSmsIfNeed(item)
        }
    }

    func bindDapp() {
        viewS.subtitleLabel.text = TR("WalletConnect.SelectAddress.Subtitle$", dapp.name)
        viewS.navTitleLabel.text = dapp.name
        viewS.navIconIV.setImage(urlString: dapp.icon, placeHolderImage: dapp.placeholderIcon)
    }

    override var cellClass: Cell.Type { return DappCell.self }
    override var listViewModel: ListViewModel { DappListViewModel(wallet, chain: chain, token: token) }

    private func registerToSmsIfNeed(_ item: CellViewModel) {
        hud?.waiting()
        alreadyRegistered(item).flatMap { name -> Observable<String> in
            self.alreadyAuthorized(item, name: name)
        }.subscribe(onNext: { [weak self] _ in

            self?.hud?.hide()
            self?.confirm(item)
        }, onError: { [weak self] _ in
            self?.hud?.hide()
        }).disposed(by: defaultBag)
    }

    private func alreadyRegistered(_ item: CellViewModel) -> Observable<String> {
        let wallet = self.wallet
        let address = FunctionXAddress(hrp: .hub, publicKey: item.publicKey.data)?.description ?? ""
        let fetchName: Observable<String>
        if let name = UserDefaults.standard.nameOnHUB(ofAddress: address) {
            fetchName = Observable.just(name)
        } else {
            fetchName = fx.hub.name(ofAddress: address)
        }

        return fetchName
            .do(onError: { [weak self] e in

                let shouldRegister = e.asWKError().code == FxRPCApiCode.unknownAddress.rawValue
                if !shouldRegister {
                    self?.hud?.text(m: e.asWKError().msg)
                } else {
                    Router.showRedirectToNameServiceAlert { vc in
                        Router.pushToDappBrowser(dapp: .nameService, wallet: wallet)

                        vc?.dismiss(animated: false, completion: {
                            self?.dismiss(animated: false, completion: nil)
                        })
                    }
                }
            })
    }

    private func alreadyAuthorized(_ item: CellViewModel, name: String) -> Observable<String> {
        let fetchName: Observable<String>
        if let name = UserDefaults.standard.nameOnSMS(ofAddress: item.address) {
            fetchName = Observable.just(name)
        } else {
            fetchName = fx.sms.name(ofAddress: item.address)
                .do(onNext: { UserDefaults.standard.set(nameOnSMS: $0, ofAddress: item.address) })
        }

        let dapp = self.dapp
        return fetchName
            .do(onError: { [weak self] e in

                let error = e.asWKError()
                let shouldAuthorize = error.code == 6 || error.code == 9
                if !shouldAuthorize {
                    self?.hud?.text(m: e.asWKError().msg)
                } else {
                    Router.showAuthorizeDappAlert(dapp: dapp, authorityTypes: [2, 1]) { [weak self] authVC, allow in
                        authVC?.dismiss(animated: false, completion: {
                            guard allow else {
                                self?.hud?.text(m: "user denied")
                                return
                            }

                            let tx = FxTransaction()
                            tx.from = item.address
                            tx.authorizeName = name
                            tx.txType = .nameAuthorization
                            Router.showBroadcastTxAlert(tx: tx, privateKey: item.privateKey) { err, _ in
                                if err == nil {
                                    UserDefaults.standard.set(nameOnSMS: name, ofAddress: item.address)
                                    Router.currentNavigator?.hud?.success(m: "")
                                }
                            }
                        })
                    }
                }
            })
    }

    func confirm(_ item: CellViewModel) {
        let account = Keypair(privateKey: item.privateKey, address: item.address, derivationPath: item.derivationPath)
        if !dapp.isPreInstalled {
            DappManager.shared.bind(account: account, to: dapp)
        }

        if confirmHandler == nil {
            dismiss(animated: true, completion: nil)
        } else {
            confirmHandler?(self, account)
        }
    }
}
