//
//
//  XWallet
//
//  Created by May on 2020/10/13.
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


typealias SwapModel = SwapViewController.SwapViewModel

typealias AmountsModel = SwapViewController.AmountsModel


extension SwapViewController {
    
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
        
        init(_ type:AmountsType, _ from:AmountsInputModel, _ to:AmountsInputModel, _ path:[String]) {
            self.amountsType = type
            self.from = from
            self.to = to
            self.path = path
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
    
    class Rate {
        
        var json: JSON = [:]
        var unit:String = ""
        var dt:String = ""
        var toUnit:String = ""
        var exchange:String = ""
        var rate:String = ""
        var exchangeImageUrl = ""
        
        convenience init(json: JSON) {
            self.init()
            self.json = json
            self.unit = json["unit"].stringValue
            self.dt = json["dt"].stringValue
            self.toUnit = json["toUnit"].stringValue
            self.exchange = json["exchange"].stringValue
            self.rate = json["rate"].stringValue
            self.exchangeImageUrl = json["exchangeImageUrl"].stringValue
        }
        
        var title: String { self.exchange }
        var subTitle: String { "\(unit)/\(toUnit)" }
    }
    
    class SwapViewModel {
        
        
        enum ApproveState {
            case normal
            case refresh
            case completed
            case disable
            case onEnough
            case slidingPoint
//            Sliding point too high
        }
        
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            let coin = self.wallet.preferredCoin
            let account = wallet.accounts(forCoin: coin).recommend
            self.fromV.accept(TokenModel(token: self.wallet.preferredCoin, account: account))
            bind()
        }
        
        var fromV = BehaviorRelay<TokenModel?>(value: nil)
        var toV = BehaviorRelay<TokenModel?>(value: nil)
        
        
        var tokens = BehaviorRelay<(TokenModel?,TokenModel?)?>(value: nil)
        
        let node = UNISwapEthereumNode(endpoint: UniswapV2.endpoint, chainId: UniswapV2.ChainId)
        
        let wallet: WKWallet
        
        lazy var fold = BehaviorRelay<Bool>(value: false)
        
        lazy var price = BehaviorRelay<String>(value: "")
        
        lazy var maxSold = BehaviorRelay<String>(value: "--")
        lazy var minimumRecived = BehaviorRelay<String>(value: "--")
        
        lazy var priceImpact = BehaviorRelay<NSAttributedString>(value: NSAttributedString(string: "--"))
        lazy var fee = BehaviorRelay<String>(value: "--")
        
        
        lazy var needApprove = BehaviorRelay<Bool>(value: false)
        
        lazy var approveState = BehaviorRelay<ApproveState>(value: .normal)
        
        lazy var tempexchangeRate = BehaviorRelay<Bool>(value: false)
        
        private var refreshBag = DisposeBag()
        
        lazy var swapAvailable = BehaviorRelay<Bool>(value: false)
        
        lazy var changeAmount = BehaviorRelay<String>(value: "")
        lazy var covnertAmount = BehaviorRelay<String>(value: "")
        
        
        lazy var rateList = BehaviorRelay<[Rate]>(value: [])
        
        lazy var routeList = BehaviorRelay<[RouterModel]>(value: [])
        
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

extension SwapViewController.SwapViewModel{

    func getRateList(from:Coin, to:Coin) -> Observable<[SwapViewController.Rate]> {
        return FxAPIManager.fx.swapMultiExchangeRate(from: from.symbolId, to: to.symbolId)
            .map { (result) -> [SwapViewController.Rate] in
            return result.arrayValue.map { (json) -> SwapViewController.Rate in
                return SwapViewController.Rate(json: json)
            }
        }
    } 
}
