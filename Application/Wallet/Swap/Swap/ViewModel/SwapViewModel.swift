
import BigInt
import FunctionX
import RxCocoa
import RxSwift
import SwiftyJSON
import TrustWalletCore
import Web3
import WKKit
import XChains
typealias SwapModel = SwapViewController.SwapViewModel
typealias AmountsModel = SwapViewController.AmountsModel
extension SwapViewController {
    enum AmountsType: Int {
        case `in`
        case out
        case null
    }

    struct AmountsValue {
        let token: Coin
        let value: String
        var bigValue: BigInt {
            let bValue = value.mul10(token.decimal)
            return BigInt(bValue) ?? BigInt(0)
        }

        func bigValue(for text: String) -> BigInt {
            let bValue = text.mul10(token.decimal)
            return BigInt(bValue) ?? BigInt(0)
        }

        init(_ token: Coin, _ value: String) {
            self.token = token
            self.value = value
        }
    }

    struct AmountsInputModel: CustomStringConvertible {
        let account: Keypair
        let token: Coin
        let inputValue: String
        let inputBigValue: String
        init(_ account: Keypair, _ token: Coin, _ input: String, _ inputBigValue: String) {
            self.account = account
            self.token = token
            inputValue = input
            self.inputBigValue = inputBigValue
        }

        var inputformatValue: String {
            let scl = inputBigValue.div10(token.decimal).isLessThan(decimal: "1") ? 8 : 2
            return inputBigValue.div10(token.decimal, scl)
        }

        var description: String {
            return "{ account:-, token:\(token.symbol), input:\(inputValue), inputBigValue:\(inputBigValue) }"
        }
    }

    struct AmountsModel: CustomStringConvertible {
        var amountsType: AmountsType = .out
        let from: AmountsInputModel
        let to: AmountsInputModel
        let path: [String]
        var amo: String = ""
        var amount: String = ""
        var maxOrMin: String = ""
        var priceImpact: String = ""
        var liquidityfee: String = ""
        init(_ type: AmountsType, _ from: AmountsInputModel, _ to: AmountsInputModel, _ path: [String]) {
            amountsType = type
            self.from = from
            self.to = to
            self.path = path
        }

        var amountsInput: AmountsInputModel {
            switch amountsType {
            case .in:
                return from
            default:
                return to
            }
        }

        var minValue: String {
            let result_mul = inputBigValue.mul(String(1 - 0.005), 0)
            let scl = result_mul.div10(to.token.decimal).isLessThan(decimal: "1") ? 8 : 2
            let minValue = result_mul.div10(to.token.decimal, scl)
            return minValue
        }

        var maxValue: String {
            let result_mul = inputBigValue.mul(String(1 + 0.005), 0)
            let scl = result_mul.div10(from.token.decimal).isLessThan(decimal: "1") ? 8 : 2
            let minValue = result_mul.div10(from.token.decimal, scl)
            return minValue
        }

        var inputValue: String {
            return amountsInput.inputValue
        }

        var inputFormatValue: String {
            let scl = inputBigValue.div10(amountsInput.token.decimal).isLessThan(decimal: "1") ? 8 : 2
            let value = inputBigValue.div10(amountsInput.token.decimal, scl)
            return value
        }

        var inputBigValue: String {
            return amountsInput.inputBigValue
        }

        var description: String {
            return "{ type: \(amountsType), from:\(from), to:\(to), paths:\(path) }"
        }
    }

    public static var WETHContract: String {
        switch ServerENV.current {
        case .dev: return "0xd0a1e359811322d97991e03f863a0c30c2cf029c"
        case .uat: return "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
        case .release: return ""
        }
    }

    fileprivate static var Endpoint: String {
        switch ServerENV.current {
        case .dev: return "https:
        case .uat: return "https:
        case .release: return ""
        }
    }

    fileprivate static var ChainId: Int {
        switch ServerENV.current {
        case .dev: return 42
        case .uat: return 1
        case .release: return 1
        }
    }

    class Rate {
        var json: JSON = [:]
        var unit: String = ""
        var dt: String = ""
        var toUnit: String = ""
        var exchange: String = ""
        var rate: String = ""
        var exchangeImageUrl = ""
        convenience init(json: JSON) {
            self.init()
            self.json = json
            unit = json["unit"].stringValue
            dt = json["dt"].stringValue
            toUnit = json["toUnit"].stringValue
            exchange = json["exchange"].stringValue
            rate = json["rate"].stringValue
            exchangeImageUrl = json["exchangeImageUrl"].stringValue
        }

        var title: String { exchange }
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
        }

        init(_ wallet: WKWallet) {
            self.wallet = wallet
            let coin = self.wallet.preferredCoin
            let account = wallet.accounts(forCoin: coin).recommend
            fromV.accept(TokenModel(token: self.wallet.preferredCoin, account: account))
            bind()
        }

        var fromV = BehaviorRelay<TokenModel?>(value: nil)
        var toV = BehaviorRelay<TokenModel?>(value: nil)
        var tokens = BehaviorRelay<(TokenModel?, TokenModel?)?>(value: nil)
        let node = UNISwapEthereumNode(endpoint: SwapViewController.Endpoint, chainId: SwapViewController.ChainId)
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
        var startFrom: Bool = true
        var refreshProveState = BehaviorRelay<Bool>(value: false)
        lazy var balanceAmount = BehaviorRelay<(String, String)>(value: ("", ""))
        func select(_ token: Coin, account: Keypair) {
            print("account.address :  \(account.address)")
            fromV.accept(TokenModel(token: token, account: account))
        }

        func selectTo(_ token: Coin, account: Keypair) {
            toV.accept(TokenModel(token: token, account: account))
        }

        private func bind() {}
    }
}

extension SwapViewController.SwapViewModel {
    func checkNeedApprove(for token: Coin, account: Keypair) -> Observable<Bool> {
        if token.isETH {
            return Observable.just(false)
        } else {
            return node.allowance(account.address, token.contract).map { (t) -> Bool in
                t == "0"
            }
        }
    }

    func getRateList(from: Coin, to: Coin) -> Observable<[SwapViewController.Rate]> {
        return FxAPIManager.fx.swapMultiExchangeRate(from: from.symbolId, to: to.symbolId)
            .map { (result) -> [SwapViewController.Rate] in
                result.arrayValue.map { (json) -> SwapViewController.Rate in
                    SwapViewController.Rate(json: json)
                }
            }
    }
}

extension SwapViewController.SwapViewModel {
    func buildEthTx(_ transaction: EthereumTransaction, fromCoin: Coin, wallet: Wallet) -> Observable<FxTransaction> {
        let tx = FxTransaction()
        let coin = Coin.ethereum
        let node = EthereumNode(endpoint: coin.node.url, chainId: coin.node.chainId.i)
        let fetchGasPrice: Observable<EthereumQuantity>
        let fetchGasLimit: Observable<EthereumQuantity>
        fetchGasPrice = APIManager.fx.estimateGasPrice().flatMap { (slow, normal, fast) -> Observable<EthereumQuantity> in
            tx.slowGasPrice = slow["fee"].stringValue
            tx.slowGasPriceTime = slow["time"].stringValue
            tx.normalGasPrice = normal["fee"].stringValue
            tx.normalGasPriceTime = normal["time"].stringValue
            tx.fastGasPrice = fast["fee"].stringValue
            tx.fastGasPriceTime = fast["time"].stringValue
            return .just(EthereumQuantity(quantity: BigUInt(normal["fee"].stringValue) ?? 0))
        }
        let from = (transaction.from?.hex(eip55: true))!
        let to = (transaction.to?.hex(eip55: true))!
        let data = Data(transaction.data.bytes)
        fetchGasLimit = node.estimatedGasOfTx(from: from,
                                              to: to,
                                              value: transaction.value?.quantity ?? 0,
                                              data: data)
            .map { EthereumQuantity(quantity: $0) }
        var balance = Observable<String>.just(wallet.wk.balance(of: from, coin: fromCoin).value.value)
        if fromCoin.isERC20 {
            balance = node.balance(of: from)
        }
        return Observable.combineLatest(fetchGasPrice, fetchGasLimit, balance).map { t -> FxTransaction in
            let (gasPrice, gasLimit, balance) = t
            var ethTx = transaction
            ethTx.gas = gasLimit
            ethTx.gasPrice = gasPrice
            tx.sync(ethTx)
            tx.coin = fromCoin
            tx.set(amount: transaction.value?.quantity.description ?? "", denom: fromCoin.symbol)
            tx.balance = balance
            return tx
        }
    }

    func approveAbi(accountAddress: String, token: String, maxAmount: String? = nil) -> EthereumTransaction? {
        let swapContract = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
        var amount = BigUInt("115792089237316195423570985008687907853269984665640564039457584007913129639935")
        if let _maxAmount = maxAmount {
            amount = BigUInt(_maxAmount)!
        }
        let (abi, abiErr) = node.approveForSwap(contact: swapContract, spend: amount)
        if let error = abiErr {
            print("approveAbi : \(error)")
            return nil
        }
        let value = EthereumQuantity(quantity: 0)
        guard let account = EthereumAddress(hexString: accountAddress) else {
            return nil
        }
        guard let tokenAddress = EthereumAddress(hexString: token) else {
            return nil
        }
        let tx = EthereumTransaction(gasPrice: nil,
                                     gas: nil,
                                     from: account,
                                     to: tokenAddress,
                                     value: value,
                                     data: EthereumData(bytes: abi.bytes))
        return tx
    }
}
