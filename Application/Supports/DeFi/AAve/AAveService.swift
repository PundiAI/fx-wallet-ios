//
//  AAveModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import SwiftyJSON

class AAveService {
    
//    static private var references: [ServerENV: AAveService] = [:]
//    static var current: AAveService { service(forEnv: .current) }
//    static func service(forEnv e: ServerENV) -> AAveService {
//
//        var result = references[e]
//        if result == nil {
//            result = AAveService(e)
//            references[e] = result!
//        }
//        return result!
//    }
//
//    let env: ServerENV
//    init(_ env: ServerENV) {
//        self.env = env
//    }
//
//    var tokens: [Coin] { indexIfNeed(); return items }
//    private var map: [String: Coin] = [:]
//    private var items: [Coin] = []
//    private var rawItems: [(String, String)] = []
//
//    private var aMap: [String: Coin] = [:]
//    private var rawAItems: [(String, String)] = []
//
//    func clear() {
//        map.removeAll()
//        items.removeAll()
//        rawItems.removeAll()
//
//        aMap.removeAll()
//        rawAItems.removeAll()
//    }
//
//    private(set) var aWETH: Coin?
//    func aToken(forErc20 contract: String) -> Coin? { indexIfNeed(); return aMap[contract.lowercased()] }
//
//    func syncIfNeed() {
//        if aWETH == nil { syncWETHAction.execute() }
//        if rawItems.count == 0 { syncErc20Action.execute() }
//    }
//
//    private func indexIfNeed() {
//        guard rawItems.count > 0, rawAItems.count > 0 else { return }
//
//        let coinService = CoinService.service(forEnv: env)
//        for (contract, symbol) in rawItems {
//            guard symbol != "WETH",
//                  let aTokenInfo = rawAItems.first(where: { $0.1.hasSuffix(symbol) }),
//                  let token = coinService.erc20(forContract: contract) else { continue }
//
//            _ = index(token: token, aTokenInfo: aTokenInfo)
//        }
//    }
//
//    private func index(token: Coin, aTokenInfo: (String, String), tokenInfo: (String, String)? = nil) -> Coin {
//
//        var aTokenJson = token.json
//        aTokenJson["name"].string = "Aave interest bearing \(token.token)"
//        aTokenJson["unit"].string = aTokenInfo.1
//        aTokenJson["contractAddress"].string = aTokenInfo.0
//        if let tokenInfo = tokenInfo { aTokenJson["tag"].string = tokenInfo.0 }
//        let aToken = Coin(json: aTokenJson)
//
//        if map[token.id] == nil {
//            map[token.id] = token
//            if token.isETH {
//                items.insert(token, at: 0)
//            } else {
//                items.append(token)
//            }
//        }
//
//        let contract = token.contract.lowercased()
//        if contract.isNotEmpty {
//            aMap[contract] = aToken
//        }
//        return aToken
//    }
//
//    private lazy var syncErc20Action = APIAction { (_) -> Observable<Any> in
//
//        let dataProvider = AAve.current.dataProvider
//        let request = Observable.combineLatest(dataProvider.getAllReservesTokens(), dataProvider.getAllATokens()).do(onNext: { [weak self](tokens, aTokens) in
//            guard let this = self else { return }
//
//            this.rawItems = tokens
//            this.rawAItems = aTokens
//            this.indexIfNeed()
//            XWallet.Event.send(.AAveTokensUpdate)
//        })
//        return request.map{ _ in true }
//    }
//
//    private lazy var syncWETHAction = APIAction { (_) -> Observable<Any> in
//
//        let wETHGateway = AAve.current.wETHGateway
//        let request = Observable.combineLatest(wETHGateway.WETH, wETHGateway.aWETH).do(onNext: { [weak self](WETH, aWETH) in
//            guard let this = self else { return }
//
//            this.aWETH = this.index(token: CoinService.current.ethereum, aTokenInfo: (aWETH, "aWETH"), tokenInfo: (WETH, "WETH"))
//            XWallet.Event.send(.AAveTokensUpdate)
//        })
//        return request.map{ _ in true }
//    }
}

//extension Coin {
//    
//    var supportAave: Bool { aToken != nil }
//    var aToken: Coin? {
//        if self.isETH { return AAveService.current.aWETH }
//        return AAveService.current.aToken(forErc20: contract)
//    }
//    
//    var WETHContract: String? {
//        if isETH { return aToken?.json["tag"].string }
//        return nil
//    }
//}
