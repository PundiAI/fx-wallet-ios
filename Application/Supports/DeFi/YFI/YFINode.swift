//
//  YFINode.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/3.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Web3
import BigInt
import XChains
import RxSwift
import TrustWalletCore

extension YFI {
    
    fileprivate var APR: String { "0x9CaD8AB10daA9AF1a9D2B878541f41b697268eEC" }
    
    var DAI: String { isMain ? "0x6B175474E89094C44Da98b954EedeAC495271d0F" : "0x6B175474E89094C44Da98b954EedeAC495271d0F" }
}

//授权dai: https://etherscan.io/tx/0xdb37034a583f2f3e2751f23b18dd21e21ecef2d0a927ff8db14e1da041abdebf
//存款dai: https://etherscan.io/tx/0xc0d9db1bbfabf706b24ecf5cb2de7f50784d70960dbc0a0aaaf388a9edef619b
//提现dai：https://etherscan.io/tx/0xbc54a9d357cd4ca3e15f8aa6533254baf762d5d6df5dd65d41f07e22b0736601
public final class YFI: DeFi {
    
    lazy var earnAPR: EarnAPR = contract(APR)
    
    private var tokenMap: [String: Token] = [:]
    func yToken(_ contract: String) -> Token {

        var result = tokenMap[contract.lowercased()]
        if result == nil {
            result = self.contract(contract)
            tokenMap[contract.lowercased()] = result
        }
        return result!
    }
}

extension YFI {
    class Token: ERC20Node {
        
        func deposit(amount: BigUInt, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "deposit")
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
        
        func withdraw(amount: BigUInt, gasLimit: BigUInt, gasPrice: BigUInt, privateKey: String) -> Observable<EthereumData> {
            
            let abi = EthereumAbiEncoder.buildFunction(name: "withdraw")
            _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
            let abiData = EthereumAbiEncoder.encode(func_in: abi!)
            return sendTx(to: ethereumAddress, value: 0, data: abiData, gasLimit: gasLimit, gasPrice: gasPrice, privateKey: privateKey)
        }
    }
}

extension YFI {
    class EarnAPR: EthereumContractNode {
        
        //https://etherscan.io/address/0x9cad8ab10daa9af1a9d2b878541f41b697268eec#readContract
        private lazy var tokens = ["BAT", "DAI", "ETH", "KNC", "LINK", "MKR", "REP", "SNX", "SUSD", "USDC", "USDT", "WBTC", "ZRX"]
        
        func apr(of erc20Symbol: String) -> Observable<[String: Any]> {
            
            let symbol = erc20Symbol.uppercased()
            guard tokens.contains(items: symbol) else {
                return .error(NSError(msg: "no apr of \(symbol)"))
            }
            
            return apr("get\(symbol)")
        }
        
        private func apr(_ function: String) -> Observable<[String: Any]> {
            
            let abiData = EthereumAbiEncoder.encode(func_in: EthereumAbiEncoder.buildFunction(name: function)!)
            let outputs = [SolidityFunctionParameter(name: "uniapr", type: .uint256),
                           SolidityFunctionParameter(name: "capr", type: .uint256),
                           SolidityFunctionParameter(name: "unicapr", type: .uint256),
                           SolidityFunctionParameter(name: "iapr", type: .uint256),
                           SolidityFunctionParameter(name: "uniiapr", type: .uint256),
                           SolidityFunctionParameter(name: "aapr", type: .uint256),
                           SolidityFunctionParameter(name: "uniaapr", type: .uint256),
                           SolidityFunctionParameter(name: "dapr", type: .uint256)]
            return call(contract: address, function: abiData, outputs: outputs)
        }
    }
}
