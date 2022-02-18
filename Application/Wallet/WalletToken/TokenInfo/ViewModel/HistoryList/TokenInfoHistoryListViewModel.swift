//
//  TokenInfoHistoryListViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON
import TrustWalletCore
extension TokenInfoHistoryListBinder {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        let coin: Coin
        let wallet: WKWallet
        lazy var lastUpdateDate = BehaviorRelay<(String, UpdateStateView.State)>(value: (TR("Token.History.Header.Updating"), .updating))
        
        
        var accounts: AccountList { wallet.accounts(forCoin: coin) }
        
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            
            //            let add = "fx" //"pay" //0x
            //            let nm = NodeManager.shared
            //            if add.hasPrefix(nm.currentFxNode.hrp) { //fx
            //                let coin = CoinService.current.fxCore
            //                if wallet.coinManager.has(coin) {
            //                    for a in wallet.accounts(forCoin: coin).addresses {
            //                        let has = a.lowercased() == add.lowercased()
            //                    }
            //                }
            //            } else if add.hasPrefix(nm.currentFxPaymentNode.hrp) { //fx
            //                let coin = CoinService.current.payc
            //                if wallet.coinManager.has(coin) {
            //                    for a in wallet.accounts(forCoin: coin).addresses {
            //                        let has = a.lowercased() == add.lowercased()
            //                    }
            //                }
            //            } else if AnyAddress.isValid(string: add, coin: .ethereum) {
            //
            //            }
            
            self.pager.startPage = 0
            self.pager.pageSize = 10
            self.fetchItems = { [weak self] pager in
                guard let this = self, let manager = ChainTransactionServer.shared else { return Observable.empty() }
                this.lastUpdateDate.accept((TR("Token.History.Header.Updating"), .updating))
                let addresses = this.wallet.accounts(forCoin: this.coin).addresses
                
                let chainId = coin.chainType.rawValue
                
                return manager.loadData(addressList: addresses, symbol: coin.symbol, contract: coin.contract,
                                        chainId: chainId, pageSize: pager.pageSize ,
                                        page: pager.page, lastId: pager.lastItemId, cache: nil)
                    .observeOn(MainScheduler.instance)
                    .map({ (rs) -> ChainTransactionResult in
                        let lastId = rs.items.lastObject()?.currencyId ?? ""
                        pager.lastItemId = lastId
                        return rs
                    })
                    .map { [weak self] (rs) -> [TokenInfoTxInfo] in
                        let now =  Date()
                        self?.fetchLastUpdateDate(now)
                        return rs.items
                    }
                    .map {
                        $0.map { (txInfo) -> CellViewModel in
                            let keyPair = self?.accounts.account(for: txInfo.fromAddress)
                            let tokeyPair = self?.accounts.account(for: txInfo.toAddress)
                            let coin = self?.coin
                            return CellViewModel(txInfo, keyPair, tokeyPair, coin, wallet)
                        }
                    }.catchError { [weak self] (e) -> Observable<[TokenInfoHistoryListBinder.CellViewModel]> in
                        let now =  Date()
                        self?.fetchLastUpdateDate(now)
                        return  Observable<[TokenInfoHistoryListBinder.CellViewModel]>.empty()
                    } 
            }
            
        }
        
        private func twentyFour() -> Bool {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = NSLocale.current
            timeFormatter.dateStyle = DateFormatter.Style.none
            timeFormatter.timeStyle = DateFormatter.Style.short
            
            let ampmtext = timeFormatter.string(from: NSDate() as Date)
            return ampmtext.range(of: "M") != nil ? false : true
        }
        
        private func fetchLastUpdateDate(_ item: Date?) {
            if let dt = item {
                let format = twentyFour() ? "dd/MM/YYYY HH:mm" : "dd/MM/YYYY h:mm a"
                let dateText = dt.format(with: format, locale: WKLocale.Shared.locale)
                lastUpdateDate.accept((TR("Token.History.LastUpdate$", dateText), .updated))
            }
        }
        
    }
}

extension TokenInfoHistoryListBinder {
    
    enum TemplateType: Int {
        case eth = 0
        case btc = 1
        case crossChain = 2
    }
    
    class CellViewModel: RxObject {
        
        init(_ txInfo: TokenInfoTxInfo, _ account: Keypair? = nil, _ toAccount: Keypair? = nil, _ coin: Coin? = nil, _ wallet: WKWallet) {
            self.account = account
            self.toAccount = toAccount
            self.txInfo = txInfo
            self.coin = coin
            self.wallet = wallet
            super.init()
            
            if txInfo.symbol.isNotEmpty {
                txInfo.symbol.exchangeRate().value
                    .filter{ $0.isAvailable }
                    .take(1)
                    .subscribe(onNext: { [weak self](v) in
                        if v.isAvailable, let amount = self?.txInfo.amount {
                            self?.legalAmount.accept("$\(amount.mul(v.value, ThisAPP.CurrencyDecimal))")
                        }
                    }).disposed(by: defaultBag)
            }
        }
        let txInfo: TokenInfoTxInfo
        
        let wallet: WKWallet
        let account: Keypair?
        let toAccount: Keypair?
        let coin: Coin?
        lazy var remark = BehaviorRelay<String?>(value: account?.remark)
        
        lazy var toRemark = BehaviorRelay<String?>(value: toAccount?.remark)
        
        var dateText: String  {
            return Date.timeAgo(since: Date(timeIntervalSince1970: TimeInterval(txInfo.timestamp)))
        }
        
        lazy var legalAmount = BehaviorRelay<String>(value: "$--")
        
        lazy var amountText = "\(txInfo.amount) \(txInfo.unit)"
        
        var btcAmountText: String {
            let amount = txInfo.amount.add(txInfo.fee)
            guard let _ = txInfo.bitcoin else {
                return amountPrefix + "\(amount) \(txInfo.unit)"
            }
            return amountPrefix + "\(txInfo.amount) \(txInfo.unit)"
        }
        
        var amountPrefix: String {
            return txInfo.type == 1 ? "-" : "+"
        }
        
        var btcAmountColor: UIColor {
            return txInfo.type == 1 ? HDA(0xFA6237) : HDA(0x71A800)
        }
        
        var btcAddressList: [BitcoinAddressModel] {
            guard let list = txInfo.bitcoin else {
                var temp = [BitcoinAddressModel]()
                let model = BitcoinAddressModel()
                model.address = txInfo.fromAddress
                model.amount = txInfo.amount.add(txInfo.fee)
                temp.append(model)
                return temp
            }
            return list.items
        }
        
        var fromText:String {
            let fAddress = txInfo.fromAddress
            if fAddress.count > 4 {
                return "...\((fAddress as NSString).substring(from: fAddress.count - 4))"
            }
            return "...\(fAddress)"
        }
        
        var toText:String {
            let toAddress = txInfo.toAddress
            if toAddress.count > 4 {
                return "...\((toAddress as NSString).substring(from: toAddress.count - 4))"
            }
            return "...\(toAddress)"
        }
        
        var txIcon: UIImage? {
            return TokenInfoTxInfo.Types(rawValue: txInfo.type) ==  .transIn ? IMG("Tx.Receive") : IMG("Tx.Send")
        }
        
        var feeText: String {
            return TR("SendToken.Fee.Total$$", txInfo.fee.thousandth(ThisAPP.CurrencyDecimal), feeUnit)
        }
        
        var bridgeFeeText: String {
            guard let cross = txInfo.crossChain, cross.fee.length > 0 else {
                return ""
            }
            return TR("CrossChain.BridgeFee$$", cross.fee.thousandth(ThisAPP.CurrencyDecimal), feeUnit)
        }
        
        func addressColor(address: String) -> UIColor {
            
            guard let coin = self.coin else {
                return COLOR.title
            }
            return wallet.accounts(forCoin: coin).addresses.map {$0.lowercased()}.contains(address) ? HDA(0x0552DC) : COLOR.title
        }
        
        func crossAddressColor(address: String) -> UIColor {
            var has = false
            let nm = NodeManager.shared
            if address.hasPrefix(nm.currentFxNode.hrp) { //fx
                let coin = CoinService.current.fxCore
                if wallet.coinManager.has(coin) {
                    for a in wallet.accounts(forCoin: coin).addresses {
                        
                        if a.lowercased() == address.lowercased() {
                            has = true
                            break
                        }
                    }
                    return has ? HDA(0x0552DC) : COLOR.title
                }
                
            } else if address.hasPrefix(nm.currentFxPaymentNode.hrp) { //fx
                let coin = CoinService.current.payc
                if wallet.coinManager.has(coin) {
                    for a in wallet.accounts(forCoin: coin).addresses {
                        if a.lowercased() == address.lowercased() {
                            has = true
                            break
                        }
                    }
                    
                    return has ? HDA(0x0552DC) : COLOR.title
                }
            } else if AnyAddress.isValid(string: address, coin: .ethereum) {
                return wallet.accounts(forCoin: CoinService.current.ethereum).addresses.map {$0.lowercased()}.contains(address.lowercased()) ? HDA(0x0552DC) : COLOR.title
            }
            
            guard let coin = self.coin else {
                return COLOR.title
            }
            return wallet.accounts(forCoin: coin).addresses.map {$0.lowercased()}.contains(address) ? HDA(0x0552DC) : COLOR.title
        }
        
        
        func feeContent(money: String) -> String {
            let unit = tTpye == .btc ? txInfo.unit :  "ETH"
            return TR("SendToken.Fee.Total$$", money.thousandth(ThisAPP.CurrencyDecimal), unit)
        }
        
        var tTpye: TemplateType {
            if (txInfo.crossToChainModel != nil)  { return .crossChain }
            
            if isCrossChain() { return .crossChain}
            
            return txInfo.unit.uppercased() == "BTC" ? .btc : .eth
        }
        
        var infoType: FxTransaction.TxType {
            if txInfo.methodId.length > 0 {
                let method = txInfo.methodId.replacingOccurrences(of: "0x", with: "")
                var txType = FxTransaction.TxType(rawValue: method) ?? .transfer
                if txType == .ethereumToFx || txType == .ethereumToPay {
                    if let chainID = txInfo.crossChain?.chainId, let chain = Node.ChainType(rawValue: Int(chainID)) {
                        txType = chain.isFxCoreNet ? .ethereumToFx : .ethereumToPay
                    }
                }
                
                if txType == .transfer {
                    if let methodId = getMethodID(txInfo.methodId) {
                        if methodId == .FX_TO_ETH || methodId == .SendToEth || methodId == .FX_TO_ETH_2 {
                            txType = .fxToEthereum
                        } else {
                            txType = .ethereumToFx
                        }
                    }
                }
                
                return  txType
            } else {
                return  FxTransaction.TxType(rawValue: txInfo.txType) ?? .ethereumToPay
            } 
        }
        
        
        var isTransIn: Bool { return TokenInfoTxInfo.Types(rawValue: txInfo.type) ==  .transIn }
        
        func showFee() -> Bool {
            if self.txInfo.transferType == FxTransaction.TxType.transfer.description ||
                self.txInfo.transferType == FxTransaction.TxType.sell_To_Uniswap.description ||
                self.txInfo.isUnKnow()
            {
                return isTransIn ?  false : true
            } else if self.txInfo.transferType == FxTransaction.TxType.withdrawDelegatorReward.description ||
                        self.txInfo.transferType == FxTransaction.TxType.undelegate.description {
                return true
            }
            else {
                return  true
            }
        }
        
        func isLocalData() -> Bool {
            if let _ = txInfo.ethereum {
                return false
            }
            return true
        }
        
        private func getMethodID(_ methodID: String) -> FxTransaction.MethodId? {
            let methodId = txInfo.methodId.replacingOccurrences(of: "0x", with: "").components(separatedBy: ".").last ?? ""
            return FxTransaction.MethodId(rawValue: methodId)
        }
        
        func isCrossChain() -> Bool {
            if let _ = getMethodID(txInfo.methodId) {
                return true
            }
            if (txInfo.crossToChainModel != nil)  { return true }
            return false
        }
        
        var feeUnit: String {
            if txInfo.chainType == .ethereum || txInfo.chainType == .ethereum_kovan {
                return "ETH"
            }
            return txInfo.unit.displayCoinSymbol
        }
        
        var height: CGFloat {
            var h: CGFloat = 0
            
            if isCrossChain() {
                if showFee() {
                    
                    if txInfo.showBridageFee() {
                        return (324 + 27).auto()
                    } else {
                        return 324.auto()
                    }
                } else {
                    return  (324 - 27).auto()
                }
            }
            
            switch tTpye {
            case .eth:
                h =   showFee() ? (129 + 19 + 14).auto() : (105 + 19 + 14).auto()
                break
            case .btc:
                if let btc = txInfo.bitcoin {
                    h =  CGFloat(btc.items.count) * 38.auto() + 80.auto()
                } else {
                    h =  CGFloat( 38.auto() + 80.auto() )
                }
                break
            case .crossChain:
                h = 324.auto()
                break
            }
            return h
        }
    }
}
