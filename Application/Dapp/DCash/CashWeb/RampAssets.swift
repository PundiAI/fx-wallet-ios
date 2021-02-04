//
//  RampAssets.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/29.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import SwiftyJSON
import WKKit

class RampAssets {
    static let shared = RampAssets()
    private lazy var items: [Coin] = {
        guard let s = "RampAssets".jsonContent else { return [] }
        return JSON(parseJSON: s)["assets"].arrayValue.filter { (item) -> Bool in
            return item["hidden"].boolValue == false && (item["address"].string != nil || item["symbol"].stringValue == "ETH")
        }.map { (item) -> Coin in
            let name = item["name"].stringValue
            let symbol = item["symbol"].stringValue
            let contract = item["address"].stringValue
            let decimal = item["decimals"].intValue
            return Coin(id: -1, chain: .ethereum, type: 60, name: name,
                        symbol: symbol, decimal: decimal, contract: contract, symbolId: 0, imgUrl: item["logoUrl"].stringValue)
        }
    }()
    
    var recommendedTokens: [Coin] {
        
        let all = items
        let end = min(2, all.count - 1)
        return end > 0 ? Array(all[0...end]) : []
    }
    
    var assets:[Coin] { items }
}
