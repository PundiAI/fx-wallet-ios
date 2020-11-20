//
//  CellViewModel.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import RxCocoa
import RxSwift
import TrustWalletCore

// MARK: ListViewModel

extension SelectAddressViewController {
    class ListViewModel: WKListViewModel<CellViewModel> {
        let wallet: Wallet
        var selectedItem = BehaviorRelay<CellViewModel?>(value: nil)

        init(_ wallet: Wallet) {
            self.wallet = wallet
            super.init()

            weak var welf = self
            pager.startPage = 0
            pager.hasNext = { $0.count < 100 }
            fetchItems = { pager in

                var items: [CellViewModel] = []
                let lastItemIdx = pager.page * pager.pageSize
                if let this = welf {
                    for i in 0 ..< pager.pageSize {
                        items.append(this.cellVM(derivationAddress: lastItemIdx + i))
                    }
                }
                return Observable.just(items)
                //                return Observable.just(items).delay(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance)
            }
        }

        func cellVM(derivationAddress: Int) -> CellViewModel {
            return CellViewModel(wallet, derivationAddress: derivationAddress)
        }
    }
}

// MARK: CellViewModel

extension SelectAddressViewController {
    class CellViewModel {
        private let wallet: Wallet
        private var hdWallet: HDWallet?

        var coinType: String { "118" }
        let derivationAddress: Int
        var derivationPath: String { "m/44'/\(coinType)'/0'/0/\(derivationAddress)" }

        private(set) var address = ""
        public let addressRemark = BehaviorRelay<String>(value: "")
        public let isSelected = BehaviorRelay<Bool>(value: false)

        init(_ wallet: Wallet, derivationAddress: Int) {
            self.wallet = wallet
            hdWallet = wallet.key.wallet(password: Data())
            self.derivationAddress = derivationAddress
            address = generateAddress()
            if let remark = UserDefaults.standard.remark(ofAddress: address) {
                addressRemark.accept(remark)
            }
        }

        func update(addressRemark: String) {
            self.addressRemark.accept(addressRemark)
            UserDefaults.standard.set(remark: addressRemark, ofAddress: address)
            XWallet.Event.send(.UpdateAddressRemark, object: address)
        }

        func generateAddress() -> String { return "" }

        // MARK: Utils

        var privateKey: PrivateKey {
            if let hdWallet = self.hdWallet {
                return hdWallet.getKey(derivationPath: derivationPath)
            }
            return PrivateKey()
        }

        var publicKey: PublicKey {
            return privateKey.getPublicKeySecp256k1(compressed: true)
        }
    }
}
