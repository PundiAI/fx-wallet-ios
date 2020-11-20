import BigInt
import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import UIKit
import Web3
import WKKit
import XChains
extension NSError {
    convenience init(_ code: Int = -1, msg: String, userInfo: [String: Any]? = nil) {
        self.init(domain: msg, code: code, userInfo: userInfo)
    }

    static var unknown: NSError { return NSError(msg: "unknown error") }
}

extension BigUInt {
    public var data: Data {
        var bytes: [UInt8] = []
        for byte in makeBytes() {
            if byte == 0, bytes.isEmpty { continue }
            bytes.append(byte)
        }
        return Data(bytes)
    }
}

public class SwapPairManager {
    class TokenPair {
        var json: JSON = [:]
        var pid: String = ""
        var chainId: String = ""
        var subscript0: String = ""
        var token0: String = ""
        var token1: String = ""
        var pair: String = ""
        var status: String = ""
        var dt: String = ""
        var update_dt: String = ""
        convenience init(json: JSON) {
            self.init()
            self.json = json
            pid = json["pid"].stringValue
            chainId = json["chainId"].stringValue
            subscript0 = json["subscript"].stringValue
            token0 = json["token0"].stringValue
            token1 = json["token1"].stringValue
            pair = json["pair"].stringValue
            status = json["status"].stringValue
            dt = json["dt"].stringValue
            update_dt = json["update_dt"].stringValue
        }
    }

    public static let shared = SwapPairManager()
    var allPairs: [TokenPair] { items }
    private lazy var items: [TokenPair] = {
        guard let s = "token_pair".jsonContent else { return [] }
        var result = [TokenPair]()
        guard let array = JSON(parseJSON: s)["RECORDS"].array else { return [] }
        for json in array {
            let tokenPair = TokenPair(json: json)
            result.append(tokenPair)
        }
        return result
    }()

    func getPairs(fromToken: String, toToken: String) -> [String] {
        if fromToken == "0xd0a1e359811322d97991e03f863a0c30c2cf029c" || toToken == "0xd0a1e359811322d97991e03f863a0c30c2cf029c" {
            return [fromToken, toToken]
        }
        let rs = allPairs.find { (pair) -> Bool in
            (pair.token0 == fromToken && pair.token1 == toToken)
                || (pair.token0 == toToken && pair.token1 == fromToken)
        }
        var _rs = [String]()
        if let a = rs {
            return [fromToken, toToken]
        } else {
            let tempA = allPairs.filter { $0.token0.lowercased() == fromToken.lowercased() || $0.token1.lowercased() == fromToken.lowercased() }
            let tempB = allPairs.filter { $0.token1.lowercased() == toToken.lowercased() || $0.token0.lowercased() == toToken.lowercased() }

            for temp0 in tempA {
                for temp1 in tempB {
                    if temp0.token1.lowercased() == temp1.token1.lowercased() {
                        _rs.append(temp0.token0)
                        _rs.append(temp0.token1)
                        _rs.append(temp1.token0)
                        break
                    }
                }
            }
        }
        return _rs
    }
}

extension UNISwapEthereumNode {
    public func allowance(_ owner: String, _ tokenContract: String) -> Observable<String> {
        return allowance(owner: owner, spender: erc20Contracts2.hex(eip55: true), tokenContract: tokenContract)
    }

    func getSymbol(_ contract: String) -> Observable<String> {
        guard let erc20Contracts = EthereumAddress(hexString: contract) else {
            return .error(NSError(msg: "address is invalid"))
        }
        let abi = EthereumAbiEncoder.buildFunction(name: "symbol")
        let abiData = EthereumAbiEncoder.encode(func_in: abi!)
        let call = EthereumCall(from: erc20Contracts, to: erc20Contracts, data: EthereumData(bytes: abiData.bytes))
        return Observable.create { (subscriber) -> Disposable in
            self.web3.eth.call(call: call, block: .latest) { res in
                if let result = res.result {
                    let outputs = [SolidityFunctionParameter(name: "rs", type: .string)]
                    let dictionary = try? ABI.decodeParameters(outputs, from: result.hex())
                    print("getSymbol  \(dictionary?["rs"])")
                    guard let value = dictionary?["rs"] as? String else {
                        subscriber.onError(NSError(domain: "data error", code: -500_002, userInfo: nil))
                        return
                    }
                    subscriber.onNext(value)
                    subscriber.onCompleted()
                } else {
                    print("getSymbol", res.error)
                    subscriber.onError(res.error ?? NSError(domain: "getAmountsOut failed", code: -500_001, userInfo: nil))
                }
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }

    public func estimatedGasOfTx2(from fromAddress: String, to toAddress: String, value: BigUInt, data: Data = Data()) -> Observable<BigUInt> {
        guard let fromETHAddress = EthereumAddress(hexString: fromAddress) else {
            return .error(NSError(msg: "fromAddress is invalid"))
        }
        guard let toETHAddress = EthereumAddress(hexString: toAddress) else {
            return .error(NSError(msg: "toAddress is invalid"))
        }
        return Observable<BigUInt>.create { (subscriber) -> Disposable in
            self.web3.eth.estimateGas(call: EthereumCall(from: fromETHAddress, to: toETHAddress, gas: nil, gasPrice: nil, value: EthereumQuantity(quantity: value), data: EthereumData(bytes: data.bytes))) { res in
                guard let gas = res.result else {
                    subscriber.onError(NSError(msg: "sync nonce failed"))
                    return
                }
                subscriber.onNext(gas.quantity)
                subscriber.onCompleted()
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }

    func approveForSwap(contact contactAddress: String, spend amount: BigUInt) -> (Data, Error?) {
        do {
            let contractETHAddress = try EthereumAddress(hex: contactAddress, eip55: true)
            let contractAddressBytes = Data(try contractETHAddress.makeBytes())
            let abi = EthereumAbiEncoder.buildFunction(name: "approve")
            _ = abi?.addParamAddress(val: contractAddressBytes, isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            return (EthereumAbiEncoder.encode(func_in: abi!), nil)
        } catch {
            return (Data(), error)
        }
    }

    func getApproveFee(accountAddress: String, token: String) -> Observable<(String, String)> {
        let swapContract = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
        let (abi, abiErr) = approveForSwap(contact: swapContract, spend: BigUInt(bytes: UINT64_MAX.makeBytes()))
        if let error = abiErr { return Observable.error(error) }
        let value = EthereumQuantity(quantity: 0).quantity
        var estimatedGas = Observable<String>.just("21000")
        estimatedGas = estimatedGasOfTx(from: accountAddress, to: token, value: value, data: abi)
            .map { String($0) }
        return Observable.combineLatest(estimatedGas, gasPrice().map { String($0) })
    }

    func getSwapFee(erc20 contracts: [String], to: String, spender: String, amount: BigUInt, amo: BigUInt, privateKey: String) -> Observable<(String, String)> {
        guard let ethPrivateKey = try? EthereumPrivateKey(hexPrivateKey: privateKey) else {
            return .error(NSError(domain: "privateKey is invalid", code: -500_001, userInfo: nil))
        }
        let time = (NSDate().timeIntervalSince1970 + 15 * 60) * 1000
        let deadline = BigUInt(time)
        let abi = EthereumAbiEncoder.buildFunction(name: "swapExactETHForTokens")
        _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
        let idx = abi!.addParamArray(isOutput: false)
        for address in contracts {
            abi?.addInArrayParamAddress(arrayIdx: idx, val: Data(hex: address))
        }
        _ = abi?.addParamAddress(val: Data(hex: to), isOutput: false)
        _ = abi?.addParamUInt256(val: deadline.data, isOutput: false)
        let abiData = EthereumAbiEncoder.encode(func_in: abi!)
        print("\(abiData.hexString)")
        var estimatedGas = Observable<String>.just("21000")
        let from = ethPrivateKey.address.hex(eip55: true)
        estimatedGas = estimatedGasOfTx2(from: from, to: spender, value: amo, data: abiData)
            .map { String($0) }
        return Observable.combineLatest(estimatedGas, gasPrice().map { String($0) })
    }

    func getAmountsOut(amountOut: String, fromToken: Coin, toToken: Coin) -> Observable<String> {
        var fromContract = fromToken.contract
        var toContract = toToken.contract

        if fromToken.isETH {
            fromContract = SwapViewController.WETHContract
        }
        if toToken.isETH {
            toContract = SwapViewController.WETHContract
        }
        let abi = EthereumAbiEncoder.buildFunction(name: "getAmountsOut")
        abi?.addParamUInt256(val: BigUInt(amountOut)!.data, isOutput: false)
        let idx = abi!.addParamArray(isOutput: false)
        let values = SwapPairManager.shared.getPairs(fromToken: fromContract, toToken: toContract)
        for address in values {
            abi?.addInArrayParamAddress(arrayIdx: idx, val: Data(hex: address))
        }
        print("pair", values)
        let abiData = EthereumAbiEncoder.encode(func_in: abi!)
        let call = EthereumCall(from: erc20Contracts2, to: erc20Contracts2, data: EthereumData(bytes: abiData.bytes))
        return Observable.create { (subscriber) -> Disposable in
            self.web3.eth.call(call: call, block: .latest) { res in
                if let result = res.result {
                    let outputs = [SolidityFunctionParameter(name: "rs", type: .array(type: .uint256, length: nil))]
                    let dictionary = try? ABI.decodeParameters(outputs, from: result.hex())
                    guard let dict = dictionary?["rs"] as? [Any], let rant = dict.lastObject() as? BigUInt else {
                        subscriber.onError(NSError(domain: "data error", code: -500_002, userInfo: nil))
                        return
                    }

                    subscriber.onNext(String(rant))
                    subscriber.onCompleted()
                } else {
                    print("getAmountsOut", res.error)
                    subscriber.onError(res.error ?? NSError(domain: "getAmountsOut failed", code: -500_001, userInfo: nil))
                }
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }

    func getAmountsIn(amountIn: String, fromToken: Coin, toToken: Coin) -> Observable<String> {
        var fromContract = fromToken.contract
        var toContract = toToken.contract

        if fromToken.isETH {
            fromContract = SwapViewController.WETHContract
        }
        if toToken.isETH {
            toContract = SwapViewController.WETHContract
        }
        let abi = EthereumAbiEncoder.buildFunction(name: "getAmountsIn")
        abi?.addParamUInt256(val: BigUInt(amountIn)!.data, isOutput: false)
        let idx = abi!.addParamArray(isOutput: false)
        let values = SwapPairManager.shared.getPairs(fromToken: fromContract, toToken: toContract)
        for address in values {
            abi?.addInArrayParamAddress(arrayIdx: idx, val: Data(hex: address))
        }
        let abiData = EthereumAbiEncoder.encode(func_in: abi!)
        let call = EthereumCall(from: erc20Contracts2, to: erc20Contracts2, data: EthereumData(bytes: abiData.bytes))
        return Observable.create { (subscriber) -> Disposable in
            self.web3.eth.call(call: call, block: .latest) { res in
                if let result = res.result {
                    let outputs = [SolidityFunctionParameter(name: "rs", type: .array(type: .uint256, length: nil))]
                    let dictionary = try? ABI.decodeParameters(outputs, from: result.hex())
                    guard let dict = dictionary?["rs"] as? [Any], let rant = dict.firstObject() as? BigUInt else {
                        subscriber.onError(NSError(domain: "data error", code: -500_002, userInfo: nil))
                        return
                    }

                    subscriber.onNext(String(rant))
                    subscriber.onCompleted()
                } else {
                    print("getAmountsIn", res.error)
                    subscriber.onError(res.error ?? NSError(domain: "getAmountsOut failed", code: -500_001, userInfo: nil))
                }
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }
}
