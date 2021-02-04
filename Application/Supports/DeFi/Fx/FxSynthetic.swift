//
//  FxSynthetic.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/7.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Web3
import BigInt
import XChains
import RxSwift
import TrustWalletCore

//lazy var fx = FxSynthetic(endpoint: "http://192.168.20.88:8545", chainId: 40912)
//private func xxx() {
//
//    let privateKey = "0x3741e28e26d1df113bffff063d4121d1559f9efa87cf0110aa3d0be1cf742018"
//    let address = "0x77F2022532009c5EB4c6C70f395DEAaA793481Bc"
//
//    let gas = BigUInt(4000000)
//    let gasPrice = BigUInt("22".gwei)!
//
//    let amount = BigUInt("1".wei)!
//    let amountUS = BigUInt("10".mul10(6))!
//
////        let token = fx.USDT
////        let request = fx.node.approve(erc20: token, spender: fx.issuer.address, amount: BigUInt("100000".wei)!, gasPrice: BigUInt("22".gwei)!, privateKey: privateKey).flatMap{_ in
////            return self.fx.issuer.allowance(owner: address, spender: self.fx.issuer.address, tokenContract: token)
////        }
//
////        let request = fx.node.balance(of: address, tokenContract: fx.USDT)
////        let request = fx.issuer.availableCollaterals()
////        let request = fx.issuer.allCollateralRatios()
////        let request = fx.issuer.allCollateral(of: address)
////        let request = fx.issuer.debt(of: address)
////        let request = fx.issuer.lastIssueEvent(of: address)
////        let request = fx.issuer.canBurnSynths(of: address)
//
////        let request = fx.issuer.collateralInAndIssueMax(erc20: fx.USDT, amount: amountUS, gasLimit: gas, gasPrice: gasPrice, privateKey: privateKey)
////        let request = fx.issuer.burnSynths(amount: amountUS, gasLimit: gas, gasPrice: gasPrice, privateKey: privateKey)
//
////        let request = fx.issuer.exchange(from: "sUSD", to: "sETH", amount: amountUS, gasLimit: gas, gasPrice: gasPrice, privateKey: privateKey)
//
//
////        let request = fx.exchangeRates.rate(of: "sUSD")
////        let request = fx.exchangeRates.rate(of: ["sUSD", "sETH"])
////        let request = fx.exchangeRates.effectiveValue(from: "sUSD", to: "sETH", amount: amountUS)
//
////        let request = fx.feePool.claim(gasLimit: gas, gasPrice: gasPrice, privateKey: privateKey)
////        let request = fx.feePool.isFeesClaimable(of: address)
////        let request = fx.feePool.availableFees(of: address)
////        let request = fx.feePool.lastWithdrawal(of: address)
//
////        let request = fx.rewardEscrow.nextVestingEntry(of: address)
//    let request = fx.rewardEscrow.vest(gasLimit: gas, gasPrice: gasPrice, privateKey: privateKey)
//
//    self.hud?.waiting()
//    request.observeOn(MainScheduler.instance)
//        .subscribe { (result) in
//            print("xxx", result.encodedString)
//            self.hud?.hide()
//
//            let t: Any = result
//            if let hash = t as? EthereumData {
//
//                print("xxx receipt", hash.hex())
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//
//                    self.fx.node.web3.eth.getTransactionReceipt(transactionHash: hash) { (res) in
//
//                        if let response = res.result {
//                            print("xxxTx success", response?.status?.quantity == 1)
//                            print(response?.encodedString)
//                        }
//                    }
//                }
//            }
//    } onError: { (e) in
//        print("xxxError", e.localizedDescription)
//        self.hud?.hide()
//    } onCompleted: {
//
//    } onDisposed: {
//
//    }
//
//}

extension FxSynthetic {
    private var Issuer: String { isMain ? "0x0d49AfE1A192a20dB67163A49B356Ad178a8c6a8" : "0x0d49AfE1A192a20dB67163A49B356Ad178a8c6a8" }
    private var ExchangeRatesAddress: String { isMain ? "0xa561a0BbD03c03E26358De6df1b2e11801Bf2730" : "0xa561a0BbD03c03E26358De6df1b2e11801Bf2730" }
    private var FeePoolAddress: String { isMain ? "0x6A702c27b19FA63502d3fB51e452988a3AC11cF4" : "0x6A702c27b19FA63502d3fB51e452988a3AC11cF4" }
    private var RewardEscrowAddress: String { isMain ? "0xBc143742E55f5324E28b3B59D7f24308352DbdB7" : "0xBc143742E55f5324E28b3B59D7f24308352DbdB7" }
    
    var FxBank: String { isMain ? "0x6A702c27b19FA63502d3fB51e452988a3AC11cF4" : "0x6A702c27b19FA63502d3fB51e452988a3AC11cF4" }
    
    
    
    var USDT: String { isMain ? "0xeC79CDD8f27E417fA5B98EB99d79c6A43DDA3d15" : "0xeC79CDD8f27E417fA5B98EB99d79c6A43DDA3d15" }
    var sUSD: String { isMain ? "0x632A8aD533254Ec202A5bc5dB6734403d6Df61D3" : "0x632A8aD533254Ec202A5bc5dB6734403d6Df61D3" }
    
    var DAI: String { isMain ? "0xDE48Fe209E0147Af3c6A7a1141A0c8b4be26a5B6" : "0xDE48Fe209E0147Af3c6A7a1141A0c8b4be26a5B6" }
}

public final class FxSynthetic: DeFi {
    
    lazy var issuer: IssuerByMultiCollateral = contract(Issuer)
    lazy var feePool: FeePool = contract(FeePoolAddress)
    lazy var rewardEscrow: RewardEscrow = contract(RewardEscrowAddress)
    lazy var exchangeRates: ExchangeRates = contract(ExchangeRatesAddress)
}


extension FxSynthetic {
    class IssuerByMultiCollateral: EthereumContractNode {
        
        func availableCollaterals() -> Observable<[EthereumAddress]> {
            return call(contract: address, function: "availableCollaterals", output: .array(type: .address, length: nil))
        }
        
        func allCollateralRatios() -> Observable<[BigUInt]> {
            return call(contract: address, function: "allCollateralRatios", output: .array(type: .uint256, length: nil))
        }
        
        func allCollateral(of address: String) -> Observable<[BigUInt]> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "allCollateral")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .array(type: .uint256, length: nil))
        }
        
        func debt(of address: String) -> Observable<BigUInt> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "debtBalanceOf")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .uint256)
        }
        
        func lastIssueEvent(of address: String) -> Observable<BigUInt> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "lastIssueEvent")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .uint256)
        }
        
        func collateralInAndIssueMax(erc20 contract: String, amount: BigUInt, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            guard let _ = EthereumAddress(hexString: contract) else {
                return .error(NSError(msg: "erc20ContractAddress is invalid"))
            }
            
            let abi = EthereumAbiEncoder.buildFunction(name: "collateralInAndIssueMax")
            _ = abi?.addParamAddress(val: Data(hex: contract), isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
        
        func canBurnSynths(of address: String) -> Observable<Bool> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "canBurnSynths")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .bool)
        }
        
        func burnSynths(amount: BigUInt, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            guard let ethPrivateKey = try? EthereumPrivateKey(hexPrivateKey: privateKey) else {
                return .error(NSError(msg: "privateKey is invalid"))
            }
            
            let abi = EthereumAbiEncoder.buildFunction(name: "burnSynths")
            _ = abi?.addParamAddress(val: Data(try! ethPrivateKey.address.makeBytes()), isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
        
        func exchange(from sourceSymbol: String, to destinationSymbol: String, amount: BigUInt, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "exchange")
            _ = abi?.addParamBytesFix(count_in: 32, val: sourceSymbol.data(using: .utf8)!, isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            _ = abi?.addParamBytesFix(count_in: 32, val: destinationSymbol.data(using: .utf8)!, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
    }
}

extension FxSynthetic {
    class ExchangeRates: EthereumContractNode {
        
        func rate(of tokenSymbol: String) -> Observable<BigUInt> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "rateForCurrency")
            _ = abi?.addParamBytesFix(count_in: 32, val: tokenSymbol.data(using: .utf8)!, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: address, function: abiData, output: .uint256)
        }
        
        func rate(of symbols: [String]) -> Observable<[BigUInt]> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "ratesForCurrencies")
            let idx = abi?.addParamArray(isOutput: false)
            for s in symbols { _ = abi?.addInArrayParamBytesFix(arrayIdx: idx!, count_in: 32, val: s.data(using: .utf8)!) }
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: address, function: abiData, output: .array(type: .uint256, length: nil))
        }
        
        func effectiveValue(from sourceSymbol: String, to destinationSymbol: String, amount: BigUInt) -> Observable<BigUInt> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "effectiveValue")
            _ = abi?.addParamBytesFix(count_in: 32, val: sourceSymbol.data(using: .utf8)!, isOutput: false)
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            _ = abi?.addParamBytesFix(count_in: 32, val: destinationSymbol.data(using: .utf8)!, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: address, function: abiData, output: .uint256)
        }
    }
}

extension FxSynthetic {
    class FeePool: EthereumContractNode {
        
        func claim(gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "claimFees")
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
        
        func isFeesClaimable(of address: String) -> Observable<Bool> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "isFeesClaimable")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .bool)
        }
        
        func availableFees(of address: String) -> Observable<[BigUInt]> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "feesAvailable")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .array(type: .uint256, length: nil))
        }
        
        func lastWithdrawal(of address: String) -> Observable<BigUInt> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "getLastFeeWithdrawal")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .uint256)
        }
    }
}

extension FxSynthetic {
    class RewardEscrow: EthereumContractNode {
        
        func vest(gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "vest")
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
        
        func nextVestingEntry(of address: String) -> Observable<[BigUInt]> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "getNextVestingEntry")
            _ = abi?.addParamAddress(val: Data(hex: address), isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return call(contract: self.address, function: abiData, output: .array(type: .uint256, length: nil))
        }
    }
}
