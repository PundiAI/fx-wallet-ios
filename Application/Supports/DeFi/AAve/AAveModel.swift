//
//  AAveModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import BigInt
import RxSwift
import SwiftyJSON

typealias AAveReserveDataValue = AAveReserveDataCache.Value
final class AAveReserveData: GlobalObservedObject<AAveReserveDataValue> {
    
    static let empty = ExchangeRate(from: "", to: "")
    
    static private var references: [String: AAveReserveData] = [:]
    static func data(of token: Coin) -> AAveReserveData {

        let contract = token.isETH ? token.WETHContract ?? "" : token.contract
        return data(of: contract)
    }
    
    static func data(of erc20Contract: String) -> AAveReserveData {

        let key = erc20Contract.lowercased()
        var result: AAveReserveData! = self.references[key]
        if result == nil {
            result = AAveReserveData(contract: erc20Contract)
            self.references[key] = result
        }
        return result
    }

    init(contract: String) {
        self.contract = contract
        super.init()
    }
    
    let contract: String
    override var id: String { contract.lowercased() }
    
    override func cache() -> AAveReserveDataValue { AAveReserveDataCache.shared.cache(forKey: id) }
    override func request() -> Observable<JSON> { AAve.current.dataProvider.getReserveData(of: contract).map{ JSON($0) } }
    
    override func hasUpdate(_ json: JSON) -> Bool { return true }
    override func update(_ json: JSON) -> AAveReserveDataValue {
        let result = super.update(json)
        AAveReserveDataCache.shared.syncIfNeed()
        return result
    }
}


final class AAveReserveDataCache: SimpleCache<AAveReserveDataValue> {
    
    class Value: CacheValue {

        private(set) var value: String = ""
        
        private(set) var availableLiquidity: String = "0"
        private(set) var totalStableDebt: String = "0"
        private(set) var totalVariableDebt: String = "0"
        private(set) var liquidityRate: String = "0"
        private(set) var variableBorrowRate: String = "0"
        private(set) var stableBorrowRate: String = "0"
        private(set) var averageStableBorrowRate: String = "0"
        private(set) var liquidityIndex: String = "0"
        private(set) var variableBorrowIndex: String = "0"

        var maxAge: TimeInterval { 60 }
        private(set) var updateTime: TimeInterval = 0

        required init() {}
        func update(_ json: JSON) -> Self {

            let v = json.dictionaryObject ?? [:]
            self.availableLiquidity = v.uint256(forKey: "availableLiquidity")?.description ?? "0"
            self.totalStableDebt = v.uint256(forKey: "totalStableDebt")?.description ?? "0"
            self.totalVariableDebt = v.uint256(forKey: "totalVariableDebt")?.description ?? "0"
            self.liquidityRate = v.uint256(forKey: "liquidityRate")?.description ?? "0"
            self.variableBorrowRate = v.uint256(forKey: "variableBorrowRate")?.description ?? "0"
            self.stableBorrowRate = v.uint256(forKey: "stableBorrowRate")?.description ?? "0"
            self.averageStableBorrowRate = v.uint256(forKey: "averageStableBorrowRate")?.description ?? "0"
            self.liquidityIndex = v.uint256(forKey: "liquidityIndex")?.description ?? "0"
            self.variableBorrowIndex = v.uint256(forKey: "variableBorrowIndex")?.description ?? "0"
            self.updateTime = Date().timeIntervalSince1970
            
            self.value = self.availableLiquidity
            return self
        }
    }
    
    static let shared = AAveReserveDataCache()
    
    override var syncInterval: TimeInterval { 40 }
    override var cacheKey: String { "fx.AAveReserveData" }
}
