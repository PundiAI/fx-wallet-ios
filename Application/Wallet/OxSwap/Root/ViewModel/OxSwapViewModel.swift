//
//
//  XWallet
//
//  Created by May on 2020/12/22.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa


import Web3
import BigInt
import FunctionX
import XChains
import TrustWalletCore
import SwiftyJSON


typealias OxAmountsModel = OxSwapViewController.AmountsModel
typealias OxSwapModel = OxSwapViewController.OxSwapViewModel

typealias OxLoadState = OxSwapViewController.OxSwapViewModel.LoadState

typealias TokenModel = OxSwapViewController.TokenModel
typealias ApprovedListModel = OxSwapViewController.ApprovedListModel
typealias ApprovedModel = OxSwapViewController.ApprovedModel

extension OxSwapViewController {
    
    class TokenModel {
        let account: Keypair?
        var token: Coin?
        
        init(token: Coin?, account: Keypair?) {
            self.account = account
            self.token = token
        }
    }
    
    class ApprovedModel: NSObject {
        var token: String = ""
        var amount: String = "0"
        var txHash: String = ""
        var coin: Coin
        init(token: String, amount: String, txHash: String, coin: Coin) {
            self.amount = amount
            self.token = token
            self.txHash = txHash
            self.coin = coin
        }
    }
    
    class ApprovedListModel {
        
        var items: [ApprovedModel] = []
        
        func add(item: ApprovedModel) {
            if let _item = items.find(condition: { $0.token == item.token}) {
                _item.amount = item.amount
                _item.txHash = item.txHash
            } else {
                items.append(item)
            }
        }
        
        func get(_ token: String) -> ApprovedModel? {
            return items.find(condition: {$0.token == token})
        }
        
        func remove(_ token: String) {
            if let item = items.find(condition: {$0.token == token}) {
                items.remove(element: item)
            }
        }
        
    }
    
}

extension OxSwapViewController {
    
    
    enum AmountsType : Int {
        case `in`
        case out
        case null
    }
    
    struct AmountsValue {
        let token:Coin
        let value:String
        
        var bigValue:BigInt {
            let bValue = value.mul10(token.decimal)
            return BigInt(bValue) ?? BigInt(0)
        }
        
        func bigValue(for text:String) -> BigInt {
            let bValue = text.mul10(token.decimal)
            return BigInt(bValue) ?? BigInt(0)
        }
        
        init(_ token:Coin, _ value:String) {
            self.token = token
            self.value = value
        }
    }
    
    struct AmountsInputModel : CustomStringConvertible {
        let account:Keypair
        let token:Coin
        let inputValue:String
        let inputBigValue:String
        
        init(_ account:Keypair, _ token:Coin, _ input:String, _ inputBigValue:String) {
            self.account = account
            self.token = token
            self.inputValue = input
            self.inputBigValue = inputBigValue
        }
        
        var inputformatValue: String {
            let scl = inputBigValue.div10(token.decimal).isLessThan(decimal: "1") ?  8 : 2
            return inputBigValue.div10(token.decimal, scl)
        }
        
        var description: String {
            return "{ account:-, token:\(token.symbol), input:\(inputValue), inputBigValue:\(inputBigValue) }"
        }
    }
    
    struct AmountsModel : CustomStringConvertible {
        var amountsType:AmountsType = .out
        let from:AmountsInputModel
        let to:AmountsInputModel
        let path:[String]
        
        var amo:String = ""
        var amount:String = ""
        var maxOrMin: String = ""
        var priceImpact: String = ""
        var liquidityfee: String = ""
        
        var price: Price?
        var quote: Quote?
        
        var slippagePercentage: String = "0.01"
        
        init(_ type:AmountsType, _ from:AmountsInputModel, _ to:AmountsInputModel, _ path:[String]) {
            self.amountsType = type
            self.from = from
            self.to = to
            self.path = path
        }
        
        var rantMsg: String {
            guard let _price = self.price?.price else {
                return ""
            }
            let scl = _price.isLessThan(decimal: "1") ?  8 : 2
            let price = _price.thousandth(decimal: scl)
            
            if amountsType == .in {
                return "1 \(to.token.symbol) = \(price) \(from.token.symbol)"
            }
            return "1 \(from.token.symbol) = \(price) \(to.token.symbol)"
        }
        
        var amountsInput:AmountsInputModel {
            switch amountsType {
            case .in:
                return from
            default:
                return to
            }
        }
        
        var minValue:String {
            let result_mul = inputBigValue.mul(String(1 - 0.005), 0)
            let scl = result_mul.div10(to.token.decimal).isLessThan(decimal: "1") ?  8 : 2
            let minValue = result_mul.div10(to.token.decimal, scl)
            return minValue
        }
        
        var maxValue:String {
            let result_mul = inputBigValue.mul(String(1 + 0.005), 0)
            let scl = result_mul.div10(from.token.decimal).isLessThan(decimal: "1") ?  8 : 2
            let minValue = result_mul.div10(from.token.decimal, scl)
            return minValue
        }
        
        var inputValue:String {
            return amountsInput.inputValue
        }
        
        var inputFormatValue:String { 
            let scl = inputBigValue.div10(amountsInput.token.decimal).isLessThan(decimal: "1") ?  8 : 2
            let value = inputBigValue.div10(amountsInput.token.decimal, scl)
            return value
        }
        
        var inputBigValue:String {
            return amountsInput.inputBigValue
        }
        
        var description: String {
            return "{ type: \(amountsType), from:\(from), to:\(to), paths:\(path) }"
        }
    }
    
    
    class OxSwapViewModel {
        
        
        enum ApproveState {
            case first
            case normal
            case refresh
            case completed
            case disable
            case onEnough
            case slidingPoint
        }
        
        enum LoadState {
            case normal
            case refresh
            case completed
        }
        
        init(_ wallet: WKWallet, current: (Coin, Keypair)?) {
            self.wallet = wallet
            self.current = current
            
            if let _current = current {
                self.fromV.accept(TokenModel(token: _current.0, account: _current.1))
            } else {
                let coin = self.wallet.preferredCoin
                let account = wallet.accounts(forCoin: coin).recommend
                self.fromV.accept(TokenModel(token: self.wallet.preferredCoin, account: account))
            }
            bind()
        }
        
        let current: (Coin, Keypair)?
        
        var fromV = BehaviorRelay<TokenModel?>(value: nil)
        var toV = BehaviorRelay<TokenModel?>(value: nil)
        
        
        var tokens = BehaviorRelay<(TokenModel?,TokenModel?)?>(value: nil)
        
        let node = UNISwapEthereumNode(endpoint: UniswapV2.endpoint, chainId: UniswapV2.ChainId)
        
        let wallet: WKWallet
        
        
        lazy var price = BehaviorRelay<String>(value: "")
        
        
        lazy var needApprove = BehaviorRelay<Bool>(value: false)
        
        lazy var approveState = BehaviorRelay<ApproveState>(value: .normal)
        
        lazy var tempexchangeRate = BehaviorRelay<Bool>(value: false)
        
        private var refreshBag = DisposeBag()
        
        
        lazy var changeAmount = BehaviorRelay<String>(value: "")
        lazy var covnertAmount = BehaviorRelay<String>(value: "")
        
        
        lazy var maxEthAmount = BehaviorRelay<String>(value: "")
        
        lazy var approvedList = BehaviorRelay<ApprovedListModel>(value: ApprovedListModel())
        
        var amountOut: String = ""
        var amountInt: String = ""
        
        let amount = BehaviorRelay<BigUInt?>(value: nil)
        let amo = BehaviorRelay<BigUInt?>(value: nil)
        
        var  startFrom: Bool = true
        
        var  refreshProveState = BehaviorRelay<Bool>(value: false)
        
        lazy var balanceAmount = BehaviorRelay<(String, String)>(value: ("", ""))
        
        
        func select(_ token: Coin, account: Keypair) {
            self.fromV.accept(TokenModel(token: token, account: account))
        }
        
        func selectTo(_ token: Coin, account: Keypair) {
            self.toV.accept(TokenModel(token: token, account: account))
        }
        
        private func bind() {
        }
    }
}



extension OxSwapViewController.OxSwapViewModel{
    
    func tokensList(from:Coin, to:Coin) -> Observable<[OxToken]> {
        return FxAPIManager.fx.oxTokenList()
    }
}




typealias PriceModel = OxSwapViewController.OxSwapViewModel.PriceModel

extension OxSwapViewController.OxSwapViewModel {
    
    class PriceModel {
        var fromAmount: String = ""
        var toAmount: String = ""
        var fromToken: String = ""
        var toToken: String = ""
        var timestamp: TimeInterval = 0
        
        var price: String = ""
        
        var model: OxAmountsModel!
        
        init(fromAmount: String, toAmount: String, fromToken: String, toToken: String, price: String, model: OxAmountsModel, timestamp: TimeInterval = NSDate().timeIntervalSince1970) {
            self.fromAmount = fromAmount
            self.toAmount = toAmount
            self.fromToken = fromToken
            self.toToken = toToken
            self.timestamp = timestamp
            self.price = price
            self.model = model
        }
        
        var msg: String {
            if model.amountsType == .in {
                return "1 \(toToken) = \(price) \(fromToken)"
            }
            return "1 \(fromToken) = \(price) \(toToken)"
        }
    }
    
    
    class PriceModels {
        var items: [PriceModel] = [PriceModel]()
        
        func getFromPriceModel(fromToken: String, toToken: String, fromAmount: String) -> PriceModel? {
            
            let currentTime = NSDate().timeIntervalSince1970
            
            let _item = items.find { (item) -> Bool in
                let expired = Int(currentTime - item.timestamp) < 10
                if  item.fromAmount == fromAmount && item.fromToken == fromToken && item.toToken == toToken && expired {
                    return true
                } else {
                    return false
                }
            }
            return _item
        }
        
        
        func addPriceModel(model: PriceModel) {
            if let _item = items.find(condition: { (item) -> Bool in
                if  item.fromAmount == model.fromAmount && item.fromToken == model.fromToken && item.toToken == model.toToken {
                    
                    return true
                    
                } else {
                    return false
                }
            }) {
                _item.timestamp = model.timestamp
            } else {
                
                items.append(model)
            }
        }
        
    }
    
    static var priceModelsCache: PriceModels = PriceModels()
}
