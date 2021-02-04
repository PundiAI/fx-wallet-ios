//
//  TokenInfoAddressListViewModel.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import XChains
import RxSwift
import RxCocoa
import TrustWalletCore

extension TokenInfoAddressListBinder {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            
            self.bind()
        }
        
        let coin: Coin
        let wallet: WKWallet
        var accounts: AccountList { wallet.accounts(forCoin: coin) }
        
        private var refreshBag = DisposeBag()
        lazy var balance = BalanceRelay(coin: coin)
        
        func add(_ account: Keypair) -> Bool {
            
            let success = accounts.add(account)
            if success { refreshItems.execute() }
            return success
        }
        
        func remove(_ account: Keypair) -> Bool {
            
            for (idx, item) in items.enumerated() {
                if item.account.address == account.address {
                    items.remove(at: idx)
                    return true
                }
            }
            return false
        }
        
        func exchangeItem(from: Int, to: Int) {
            guard from != to, let item = items.get(from) else { return }
            
            items.remove(at: from)
            if to > items.count {
                items.append(item)
            } else {
                items.insert(item, at: to)
            }
            
            accounts.reset(items.map{ $0.account })
        }
        
        private func bind() {
            
            self.pager.hasNext = { _ in false }
            self.refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return Observable.empty() }

                for account in this.wallet.accounts(forCoin: this.coin).accounts {

                    let isNew = this.items.indexOf{ account.address == $0.address } == nil
                    if isNew {
                        this.items.append(CellViewModel(account: account, coin: this.coin))
                    }
                }
                
                self?.bindBalance()
                this.items.forEach{
                    if !this.coin.mergeBalanceRequest { $0.refresh() }
                }
                return .just(this.items)
            }
            
            XWallet.Event.subscribe(.UpdateAddressRemark, { [weak self] (address, _) in
                guard let this = self, let address = address as? String,
                    let item = this.items.first(where: { $0.address == address }) else { return }
                
                item.remark.accept(item.account.remark)
            }, disposedBy: defaultBag)
        }
        
        private func bindBalance() {
            refreshBag = DisposeBag()
            
            let result: Observable<[String]>
            if !coin.mergeBalanceRequest {
                result = Observable.combineLatest(items.map{ $0.balance.value })
            } else {
                
                var map: [String: CellViewModel] = [:]
                items.forEach { map[$0.address] = $0 }
                
                let balanceList = wallet.balanceList(coin: coin)
                balanceList.refreshIfNeed()
                result = balanceList.value.map {
                        
                    var values: [String] = []
                    for (address, v) in $0 {
                        map[address]?.balance.accept(v, false)
                        values.append(v)
                    }
                    return values
                }
            }
            
            result.subscribe(onNext: { [weak self](values) in
                guard let this = self else { return }
                
                var result = "0"
                for v in values {
                    if !v.isUnknownAmount { result = result.add(v, this.coin.decimal) }
                }
                this.balance.accept(result)
            }).disposed(by: refreshBag)
        }
    }
}
