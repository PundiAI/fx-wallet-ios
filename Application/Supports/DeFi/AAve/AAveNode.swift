//
//  AAveNode.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/2.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Web3
import WKKit
import BigInt
import XChains
import RxSwift
import TrustWalletCore

extension AAve {
    
    fileprivate var LendingPoolAddressesProvider: String { isMain ? "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5" : "0x88757f2f99175387ab4c6a4b3067c77a695b0349" }
    fileprivate var ProtocolDataProvider: String { isMain ? "0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d" : "0x3c73A5E5785cAC854D468F727c606C07488a29D6" }
    fileprivate var WETHGatewayAddress: String { isMain ? "0xDcD33426BA191383f1c9B431A342498fdac73488" : "0xf8aC10E65F2073460aAD5f28E1EABE807DC287CF" }
}

extension AAve {
    
    static var current: AAve { service(forChain: NodeManager.shared.currentEthereumNode.chainType) }
    
    static private var references: [Node.ChainType: AAve] = [:]
    static func service(forChain chain: Node.ChainType) -> AAve {

        let nm = NodeManager.shared
        let node = nm.node(forChain: .ethereum, type: chain) ?? nm.currentEthereumNode
        var result = references[chain]
        if result == nil {
            result = AAve(endpoint: node.url, chainId: node.chainId.i)
            references[chain] = result!
        }
        return result!
    }
}


public final class AAve: DeFi {
    
    private(set) var lendingPoolAddress: String?
    var lendingPool: Observable<LendingPool> {
        if let address = self.lendingPoolAddress { return .just(contract(address)) }
        
        return call("getLendingPool").map{
            
            let address = $0.hex(eip55: false)
            self.lendingPoolAddress = address
            return self.contract(address)
        }
    }
    
    lazy var wETHGateway: WETHGateway = contract(WETHGatewayAddress)
    lazy var dataProvider: DataProvider = contract(ProtocolDataProvider)
    
    var tokens: [Coin] { indexIfNeed(); return items }
    var recommendedTokens: [Coin] {
        
        let all = tokens
        let end = min(2, all.count - 1)
        return end > 0 ? Array(all[0...end]) : []
    }
    
    private var map: [String: Coin] = [:]
    private var items: [Coin] = []
    private var rawItems: [(String, String)] = []
    
    private var aMap: [String: Coin] = [:]
    private var rawAItems: [(String, String)] = []
    
    private(set) var aWETH: Coin?
    func aToken(forErc20 contract: String) -> Coin? { indexIfNeed(); return aMap[contract.lowercased()] }
    
    func syncIfNeed() {
        if aWETH == nil { syncWETHAction.execute() }
        if rawItems.count == 0 { syncErc20Action.execute() }
    }

    private func indexIfNeed() {
        guard rawItems.count > 0, rawAItems.count > 0 else { return }
        let coinService = CoinService.current
        for (contract, symbol) in rawItems {
            guard symbol != "WETH",
                  let aTokenInfo = rawAItems.first(where: { $0.1.hasSuffix(symbol) }),
                  let token = coinService.erc20(forContract: contract, chain: chainType) else { continue }
            
            _ = index(token: token, aTokenInfo: aTokenInfo)
        }
    }
    
    private func index(token: Coin, aTokenInfo: (String, String), tokenInfo: (String, String)? = nil) -> Coin {
        
        var aTokenJson = token.json
        aTokenJson["name"].string = "Aave interest bearing \(token.token)"
        aTokenJson["unit"].string = aTokenInfo.1
        aTokenJson["contractAddress"].string = aTokenInfo.0
        if let tokenInfo = tokenInfo { aTokenJson["tag"].string = tokenInfo.0 }
        let aToken = Coin(json: aTokenJson)
        
        if map[token.id] == nil {
            map[token.id] = token
            if token.isETH {
                items.insert(token, at: 0)
            } else {
                items.append(token)
            }
        }
        
        let contract = token.contract.lowercased()
        if contract.isNotEmpty {
            aMap[contract] = aToken
        }
        return aToken
    }
    
    private lazy var syncErc20Action = APIAction { (_) -> Observable<Any> in
        
        let request = Observable.combineLatest(self.dataProvider.getAllReservesTokens(), self.dataProvider.getAllATokens()).do(onNext: { [weak self](tokens, aTokens) in
            guard let this = self else { return }
            
            this.rawItems = tokens
            this.rawAItems = aTokens
            this.indexIfNeed()
            XWallet.Event.send(.AAveTokensUpdate)
        })
        return request.map{ _ in true }
    }
    
    private lazy var syncWETHAction = APIAction { (_) -> Observable<Any> in
        
        let request = Observable.combineLatest(self.wETHGateway.WETH, self.wETHGateway.aWETH).do(onNext: { [weak self](WETH, aWETH) in
            guard let this = self else { return }
            
            this.aWETH = this.index(token: this.eth, aTokenInfo: (aWETH, "aWETH"), tokenInfo: (WETH, "WETH"))
            XWallet.Event.send(.AAveTokensUpdate)
        })
        return request.map{ _ in true }
    }
    
    
    private func call(_ f: String) -> Observable<EthereumAddress> {
        node.call(contract: LendingPoolAddressesProvider, function: f, output: .address)
    }
}


extension AAve {
    class LendingPool: EthereumContractNode {
        
        func buildDepositTx(erc20 contract:String, sender: String, receiver: String? = nil, amount: BigUInt, referralCode: UInt16 = 0) -> EthereumTransaction? {
            
            let receiver = receiver ?? sender
            guard let senderAddress = EthereumAddress(hexString: sender),
                  let _ = EthereumAddress(hexString: receiver),
                  let _ = EthereumAddress(hexString: contract) else {
                return nil
            }
            
            let abi = EthereumAbiEncoder.buildFunction(name: "deposit")
            _ = abi?.addParamAddress(val: Data(hex: contract), isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            _ = abi?.addParamAddress(val: Data(hex: receiver), isOutput: false)
            _ = abi?.addParamUInt16(val: referralCode, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return EthereumTransaction(gasPrice: nil, gas: nil, from: senderAddress, to: ethereumAddress, value: 0, data: EthereumData(bytes: abiData.bytes))
        }
        
        func deposit(erc20 contract:String, amount: BigUInt, referralCode: UInt16 = 0, onBehalfOf receiver: String, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            guard let _ = EthereumAddress(hexString: contract) else {
                return .error(NSError(msg: "erc20ContractAddress is invalid"))
            }
            
            guard let _ = EthereumAddress(hexString: receiver) else {
                return .error(NSError(msg: "receiverAddress is invalid"))
            }
            
            let abi = EthereumAbiEncoder.buildFunction(name: "deposit")
            _ = abi?.addParamAddress(val: Data(hex: contract), isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            _ = abi?.addParamAddress(val: Data(hex: receiver), isOutput: false)
            _ = abi?.addParamUInt16(val: referralCode, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
        
        func buildWithdrawTx(erc20 contract:String, sender: String, receiver: String? = nil, amount: BigUInt, entire: Bool = false) -> EthereumTransaction? {
            let receiver = receiver ?? sender
            guard let senderAddress = EthereumAddress(hexString: sender),
                  let _ = EthereumAddress(hexString: receiver),
                  let _ = EthereumAddress(hexString: contract) else {
                return nil
            }
            
            let amountData = entire ? Data(hex: "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") : amount.data
            let abi = EthereumAbiEncoder.buildFunction(name: "withdraw")
            _ = abi?.addParamAddress(val: Data(hex: contract), isOutput: false)
            _ = abi?.addParamUInt256(val: amountData, isOutput: false)
            _ = abi?.addParamAddress(val: Data(hex: receiver), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return EthereumTransaction(gasPrice: nil, gas: nil, from: senderAddress, to: ethereumAddress, value: 0, data: EthereumData(bytes: abiData.bytes))
        }
        
        func withdraw(erc20 contract:String, amount: BigUInt, to receiver: String, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            guard let _ = EthereumAddress(hexString: contract) else {
                return .error(NSError(msg: "erc20ContractAddress is invalid"))
            }
            
            guard let _ = EthereumAddress(hexString: receiver) else {
                return .error(NSError(msg: "receiverAddress is invalid"))
            }
            
            let abi = EthereumAbiEncoder.buildFunction(name: "withdraw")
            _ = abi?.addParamAddress(val: Data(hex: contract), isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            _ = abi?.addParamAddress(val: Data(hex: receiver), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
    }
}

extension AAve {
    class WETHGateway: EthereumContractNode {
        
        private(set) var aWETHAddress: String?
        var aWETH: Observable<String> {
            if let address = self.aWETHAddress { return .just(address) }
            
            let request: Observable<EthereumAddress> = call(contract: self.address, function: "getAWETHAddress", output: .address)
            return request.map{ value in
                self.aWETHAddress = value.hex(eip55: false)
                return self.aWETHAddress!
            }
        }
        
        private(set) var WETHAddress: String?
        var WETH: Observable<String> {
            if let address = self.WETHAddress { return .just(address) }
            
            let request: Observable<EthereumAddress> = call(contract: self.address, function: "getWETHAddress", output: .address)
            return request.map{ value in
                self.WETHAddress = value.hex(eip55: false)
                return self.WETHAddress!
            }
        }
        
        func buildDepositTx(sender: String, receiver: String? = nil, amount: BigUInt, referralCode: UInt16 = 0) -> EthereumTransaction? {
            
            let receiver = receiver ?? sender
            guard let senderAddress = EthereumAddress(hexString: sender),
                  let _ = EthereumAddress(hexString: receiver) else {
                return nil
            }
            
            let abi = EthereumAbiEncoder.buildFunction(name: "depositETH")
            _ = abi?.addParamAddress(val: Data(hex: receiver), isOutput: false)
            _ = abi?.addParamUInt16(val: referralCode, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return EthereumTransaction(gasPrice: nil, gas: nil, from: senderAddress, to: ethereumAddress, value: EthereumQuantity(quantity: amount), data: EthereumData(bytes: abiData.bytes))
        }
        
        func buildWithdrawTx(sender: String, receiver: String? = nil, amount: BigUInt, entire: Bool = false) -> EthereumTransaction? {
            let receiver = receiver ?? sender
            guard let senderAddress = EthereumAddress(hexString: sender),
                  let _ = EthereumAddress(hexString: receiver) else {
                return nil
            }
            
            let amountData = entire ? Data(hex: "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") : amount.data
            let abi = EthereumAbiEncoder.buildFunction(name: "withdrawETH")
            _ = abi?.addParamUInt256(val: amountData, isOutput: false)
            _ = abi?.addParamAddress(val: Data(hex: receiver), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return EthereumTransaction(gasPrice: nil, gas: nil, from: senderAddress, to: ethereumAddress, value: 0, data: EthereumData(bytes: abiData.bytes))
        }
    }
}

extension AAve {
    class DataProvider: EthereumContractNode {
        
        func getReserveData(of erc20: String) -> Observable<[String: Any]> {
            guard let _ = EthereumAddress(hexString: erc20) else {
                return .error(NSError(msg: "erc20ContractAddress is invalid"))
            }

            let abi = EthereumAbiEncoder.buildFunction(name: "getReserveData")
            _ = abi?.addParamAddress(val: Data(hex: erc20), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            let outputs = [SolidityFunctionParameter(name: "availableLiquidity", type: .uint256),
                           SolidityFunctionParameter(name: "totalStableDebt", type: .uint256),
                           SolidityFunctionParameter(name: "totalVariableDebt", type: .uint256),
                           SolidityFunctionParameter(name: "liquidityRate", type: .uint256),
                           SolidityFunctionParameter(name: "variableBorrowRate", type: .uint256),
                           SolidityFunctionParameter(name: "stableBorrowRate", type: .uint256),
                           SolidityFunctionParameter(name: "averageStableBorrowRate", type: .uint256),
                           SolidityFunctionParameter(name: "liquidityIndex", type: .uint256),
                           SolidityFunctionParameter(name: "variableBorrowIndex", type: .uint256)]
            return self.call(contract: address, function: abiData, outputs: outputs)
        }
        
        func getAllReservesTokens() -> Observable<[(String, String)]> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "getAllReservesTokens")
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return self.call(contract: address, function: abiData) { self.decodeTokens($0.hex()) }
        }
        
        func getAllATokens() -> Observable<[(String, String)]> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "getAllATokens")
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return self.call(contract: address, function: abiData) { self.decodeTokens($0.hex()) }
        }
        
        private func decodeTokens(_ hex: String) -> [(String, String)]? {
            
            let hex = hex.replacingOccurrences(of: "0x", with: "")
                
            let padLength = 64
            let padEndIdx = padLength - 1
            let doublePadLength = padLength * 2
            
            let source = hex.substring(from: doublePadLength)
            let listLength = Int(hex.substring(range: NSMakeRange(padLength, padLength)), radix: 16) ?? 0
            guard listLength > 0 else { return nil }
            
            var result: [(String, String)] = []
            for i in 0..<listLength {
                
                let startHex = source.substring(range: NSMakeRange(i * padLength, padLength))
                guard let startIdx = Int(startHex, radix: 16) else { continue }
                
                let objHex = source.substring(from: startIdx * 2)
                
                let addressHex = objHex.substring(range: NSMakeRange(padLength, padLength))
                let address = "0x\(addressHex.substring(from: padLength - 40))"
                
                let symbolHex = objHex.substring(range: NSMakeRange(doublePadLength, doublePadLength))
                if let length = Int(symbolHex.substring(to: padEndIdx), radix: 16) {
                    
                    let valueHex = symbolHex.substring(from: padLength).substring(to: length * 2 - 1)
                    let symbol = String(data: Data(hex: valueHex), encoding: .utf8) ?? ""
                    result.append((address, symbol))
                }
            }
            return result
        }
    }
}






//MARK: AAve.Coin
extension Coin {
    
    var supportAave: Bool { aToken != nil }
    var aToken: Coin? {
        if self.isETH { return AAve.current.aWETH }
        return AAve.current.aToken(forErc20: contract)
    }
    
    var WETHContract: String? {
        if isETH { return aToken?.json["tag"].string }
        return nil
    }
}
