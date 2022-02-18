//
//  TokenInfoSocialListViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension TokenInfoSocialListBinder {
    
    class ViewModel: WKListViewModel<CellViewModel> {
        
        let coin: Coin
        let wallet: WKWallet
        
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
            super.init()
            
            self.refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return .empty() }
                
                return APIManager.fx.thirdPartyList(of: this.coin.currencyId).flatMap{ result -> Observable<[CellViewModel]> in
                    this.items = result.map{ CellViewModel($0) }
                    return .just(this.items)
                }
            }
        }
    }
}


extension TokenInfoSocialListBinder {
    
    class CellViewModel  {
        
        var img: String?
        var url: String?
        var title = ""
        var subtitle = ""
        var rawValue: [String: Any] = [:]
        
        let height: CGFloat = 72.auto()
        init(_ json: JSON) {
            
            self.rawValue = json.dictionaryObject ?? [:]
            img = json["icon"].stringValue
            url = json["url"].string
            title = json["title"].stringValue
            subtitle = json["description"].stringValue
        }
    }
}
