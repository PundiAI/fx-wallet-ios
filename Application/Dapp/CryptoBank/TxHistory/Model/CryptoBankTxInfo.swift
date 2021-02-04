//
//  CryptoBankTxModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/5.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import SwiftyJSON

class CryptoBankTxInfo {
    
    enum Types: Int64 {
        case invalid = 0
        case deposit = 1
        case withdraw = 2
    }
    
    var type: Types = .invalid
    
    var txHash = ""
    var amount = ""
    var address = ""
    var timestamp: Int64 = 0
    
    var coinId = ""
    var walletId = ""
    var coin: Coin? {
        didSet {
            if coinId == "" {
                coinId = coin?.id ?? ""
            }
        }
    }
    
    var symbol: String {
        
        if let coin = coin {
            if type == .deposit { return coin.token }
            if type == .withdraw { return coin.aToken?.symbol ?? "" }
        } else if coinId.isNotEmpty {
            let symbol = coinId.components(separatedBy: "_").first ?? ""
            if type == .deposit { return symbol.uppercased() }
            if type == .withdraw { return "a\(symbol.uppercased())" }
        }
        return ""
    }
    
    func syncIfNeed() {
        guard coin == nil, coinId.isNotEmpty else { return }
        
        coin = CoinService.current.coin(forId: coinId)
    }
}
