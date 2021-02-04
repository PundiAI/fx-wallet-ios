//
//  DeFi.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/3.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Web3
import XChains
import RxSwift
import SwiftyJSON
import TrustWalletCore

public class DeFi {
    
    public let chainId: Int
    public let endpoint: String
    public init(endpoint: String, chainId: Int) {
        
        self.chainId = chainId
        self.endpoint = endpoint
    }
    
    var isMain: Bool { chainId == 1 }
    var chainType: Node.ChainType { isMain ? .ethereum : .ethereum_kovan }
    var eth: Coin { CoinService.current.coin(forId: Coin.ethereum.id, chain: chainType) ?? CoinService.current.ethereum }
    
    private(set) lazy var node = EthereumNode(endpoint: endpoint, chainId: chainId)
    lazy var maxApproveAmount = BigUInt("115792089237316195423570985008687907853269984665640564039457584007913129639935")
    
    func contract<T: EthereumContractNode>(_ address: String) -> T {
        return T.init(endpoint: endpoint, chainId: chainId, contract: address)
    }
    
    static private var allowanceMap: [String: String] = [:]
    func update(allowance: String, owner: String, spender: String, tokenContract: String) {
        let key = "\(owner)_\(spender)_\(tokenContract)".lowercased()
        DeFi.allowanceMap[key] = allowance
    }
    
    func allowance(owner: String, spender: String, tokenContract: String) -> Observable<String> {
        
        let key = "\(owner)_\(spender)_\(tokenContract)".lowercased()
        if let cache = DeFi.allowanceMap[key] { return .just(cache) }
        
        return node.allowance(owner: owner, spender: spender, tokenContract: tokenContract)
            .do(onNext: { DeFi.allowanceMap[key] = $0 })
    }
    
    func buildApproveTx(erc20 contract:String, owner: String, spender: String, amount: BigUInt? = nil) -> EthereumTransaction? {
        guard let ownerAddress = EthereumAddress(hexString: owner),
              let spenderAddress = EthereumAddress(hexString: spender),
              let erc20Contract = EthereumAddress(hexString: contract) else {
            return nil
        }
        
        let amount = amount ?? maxApproveAmount
        let abi = EthereumAbiEncoder.buildFunction(name: "approve")
        _ = abi?.addParamAddress(val: Data(try! spenderAddress.makeBytes()), isOutput: false)
        _ = abi?.addParamUInt256(val: amount.data, isOutput: false)
        let abiData = EthereumAbiEncoder.encode(func_in: abi!)
        return EthereumTransaction(gasPrice: nil, gas: nil, from: ownerAddress, to: erc20Contract, value: EthereumQuantity(quantity: 0), data: EthereumData(bytes: abiData.bytes))
    }
    
    func estimatedGas(of tx: EthereumTransaction?) -> Observable<BigUInt> {
        guard let tx = tx else { return .error(WKError(.default, "invalid EthereumTransaction")) }
        
        return node.estimatedGasOfTx(from: tx.from?.hex(eip55: false) ?? "", to: tx.to?.hex(eip55: false) ?? "", value: tx.value?.quantity ?? 0, data: Data(tx.data.bytes))
    }
}


extension DeFi {
    
    static private var _tokensJson: [ServerENV: JSON] = [:]
    static var tokensJson: [ServerENV: JSON] {
        if _tokensJson.isEmpty,
           let s = "defi".jsonContent {
            
            let json = JSON(parseJSON: s)
            let main = json["main"]
            let kovan = json["kovan"]
            _tokensJson[.dev] = kovan
            _tokensJson[.uat] = main
            _tokensJson[.release] = main
        }
        return _tokensJson
    }
}
