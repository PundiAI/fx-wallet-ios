//
//  SelectWalletConnectAccountCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxCocoa

extension SelectWalletConnectAccountController {
    
    class ListViewModel {
        
        init(wallet: WKWallet, filter: ((Coin, [String: Any]?) -> Bool)? ) {
            self.wallet = wallet
            
            let filter = filter ?? { (_,_) in true }
            loadAccounts(filter)
        }
        
        let wallet: WKWallet
        var items: [SectionViewModel] = []
        
        func loadAccounts(_ filter: (Coin, [String: Any]?) -> Bool) {
            loadEthereumAccounts(filter)
        }
        
        func loadEthereumAccounts(_ filter: (Coin, [String: Any]?) -> Bool) {
            
            var map: [String: Any] = [:]
            for coin in wallet.coins {
                guard coin.isEthereum else { continue }
                
                let addressList = wallet.accounts(forCoin: coin)
                for account in addressList.accounts {
                    if map[account.address] == nil {
                        map[account.address] = 1
                        
                        items.append(SectionViewModel(wallet: wallet, coin: CoinService.current.ethereum, account: account, num: map.count, filter: filter))
                    }
                }
            }
        }
    }
}

extension SelectWalletConnectAccountController {
    class SectionViewModel {
        
        let header: HeaderViewModel
        var items: [CellViewModel] = []
        let footer: FooterViewModel
        var wallet: WKWallet { header.wallet }
        
        init(wallet: WKWallet, coin: Coin, account: Keypair, num: Int, filter: (Coin, [String: Any]?) -> Bool) {
            
            self.header = HeaderViewModel(wallet: wallet, coin: coin, account: account, num: num)
            let address = account.address
            for c in wallet.coins {
                if c.id == coin.id || !filter(c, nil) { continue }
                
                let addressList = wallet.accounts(forCoin: c)
                if addressList.account(for: address) != nil {
                    items.append(CellViewModel(coin: c, account: account, balance: wallet.balance(of: address, coin: c)))
                }
            }

            self.footer = FooterViewModel(count: self.items.count)
        }
        
        var displayItemCount: Int {
            if footer.isExpand { return items.count }
            return min(4, items.count)
        }
    }
}

extension SelectWalletConnectAccountController {
    class HeaderViewModel {
        
        init(wallet: WKWallet, coin: Coin, account: Keypair, num: Int) {
            self.coin = coin
            self.number = num.s
            self.wallet = wallet
            self.account = account
        }
        
        let coin: Coin
        let account: Keypair
        let wallet: WKWallet
        let height: CGFloat = 101
        
        let number: String
        var address: String { account.address }
        lazy var addressRemark: String = UserDefaults.remark(ofAddress: self.address) ?? ""
        
        lazy var balance = wallet.balance(of: address, coin: coin)
        lazy var balanceText: String = {
            let amount = balance.value.value.div10(coin.decimal).thousandth(mb: true)
            return "\(amount) \(coin.token)"
        }()
    }
    
    class FooterViewModel {
        
        var height: CGFloat = 24.auto()
        let count: Int
        var text = ""
        var isExpand = false
        var display = false
        init(count: Int) {
            
            self.count = count + 1
            display = count > 4
            if display {
                height += 46.auto()
                expand(false)
            }
        }
        
        func expand(_ v: Bool) {
            self.isExpand = v
            self.text = v ? "\(count)/\(count)" : "5/\(count)"
        }
    }
}

extension SelectWalletConnectAccountController {
    class CellViewModel {
        
        init(coin: Coin, account: Keypair, balance: Balance) {
            self.coin = coin
            self.account = account
            
            let amount = balance.value.value.div10(coin.decimal).thousandth(mb: true)
            self.balanceText = "\(amount) \(coin.token)"
        }
        
        let coin: Coin
        let account: Keypair
        let balanceText: String
        let height: CGFloat = 36.auto()
    }
}
