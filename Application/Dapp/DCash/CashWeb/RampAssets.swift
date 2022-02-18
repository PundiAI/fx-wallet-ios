//
//  RampAssets.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/29.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import WKKit
import Alamofire

class RampAssets : NSObject {
    static let shared = RampAssets()
    
    private var cachKey:String { "fxWallet-Ramp-Tokens" }
    
    private lazy var localContent:[JSON] = {
        guard let s = "RampAssets".jsonContent else { return [] }
        return JSON(parseJSON: s)["assets"].arrayValue
    }()
    
    override init() {
        super.init()
        FxAPIManager.fx.fetchRampTokenList()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
            if json["assets"].arrayValue.count > 0 , let object = json.rawString() {
                UserDefaults.standard.setValue(object, forKey: self.cachKey)
                UserDefaults.standard.synchronize()
            }
        }).disposed(by: defaultBag)
    }

    private var dataSouce:[JSON] {
        if let object = UserDefaults.standard.value(forKey: self.cachKey) as? String { 
            return JSON(parseJSON: object)["assets"].arrayValue
        }else {
            return localContent
        }
    }
    
    private var items: [Coin] {
        var _items = dataSouce.filter { (item) -> Bool in
            
            let type = item["type"].stringValue
            var display = item["hidden"].boolValue == false && ["ETH","BTC","ERC20"].contains(type)
            if display {
                
                let coinService = CoinService.current
                if type == "ERC20", item["address"].string != nil {
                    display = coinService.coin(forSymbol: item["symbol"].stringValue, chain: .ethereum) != nil
                }
            }
            return display
        }.map { (item) -> Coin in
            let name = item["name"].stringValue
            let symbol = item["symbol"].stringValue
            let contract = item["address"].stringValue
            let decimal = item["decimals"].intValue
            let type = item["type"].stringValue
            
            let imgUrl = CoinService.current.coins.find { $0.symbol == symbol }.map { (coin) -> String in
                return coin.imgUrl
            } ?? item["logoUrl"].stringValue
            
            switch type {
            case "BTC":
                return Coin(id: 1, chain: .bitcoin, type: 0, name: name,
                            symbol: symbol, decimal: decimal, contract: "", symbolId: 0, imgUrl: imgUrl)
            default:
                return Coin(id: 1, chain: .ethereum, type: 60, name: name,
                            symbol: symbol, decimal: decimal, contract: contract, symbolId: 0, imgUrl: imgUrl)
            } 
        }
        
        _items.reverse()
        var result: [Coin] = []
        for c in _items {
            if c.symbol.uppercased() == "ETH" {
                result.insert(c, at: 0)
            } else if c.symbol.uppercased() == "BTC" {
                let index = max(0, min(1, result.count - 1))
                result.insert(c, at: index)
            } else {
                result.append(c)
            }
        }
        return result
    }
     
    var recommendedTokens: [Coin] { 
        let all = items
        let end = min(2, all.count - 1)
        return end > 0 ? Array(all[0...end]) : []
    }
    
    var assets:[Coin] { items }
}


extension FxAPIManager {
    func fetchRampTokenList() ->Observable<JSON> {
        return Observable.create { (observer) -> Disposable in
            AF.request(RampConfig.assetApiUrl)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseString(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        if let content = response.value {
                            observer.onNext(JSON(parseJSON: content))
                            observer.onCompleted()
                        }else {
                            observer.onError(NSError(0, msg: "Error") )
                        }
                    case let .failure(error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { }
        }
    }
}
