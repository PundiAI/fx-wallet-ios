//
//  CryptoBankHomeDelegateCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/25.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class DelegateCellViewModel {
        
        init(wallet: WKWallet) {
            self.wallet = wallet
            
            self.coin = CoinService.current.fxCore
        }
        
        let coin: Coin
        let wallet: WKWallet
        var height: CGFloat = (24 + 248).auto()
        
        lazy var apy = BehaviorRelay<String>(value: apyCache)
        
        var display:Bool {
            get { ThisAPP.AuthPath.fxPundixDelegateDisplay }
        }
        
        func refresh() {
            fetchAPY.execute()
        }
        
        func showDetail() {
            
            let descHeight = TR("FXDelegator.Desc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let titleHeight = 82.auto() + descHeight
            self.height = 24.auto() + titleHeight + 148.auto()
        }
        
        private lazy var fetchAPY = FrequentlyAction<String>{ _ in
            
            return APIManager.fx.fetchActiveValidators().map{[weak self] result in
                
                var apy = ""
                for json in result.arrayValue {
                    let v = Validator(json: json)
                    if v.rewards.f > apy.f {
                        apy = v.rewards
                    }
                }
                
                if apy.isNotEmpty, apy != self?.apy.value {
                    self?.apy.accept(apy)
                    self?.apyCache = apy
                }
                return apy
            }
        }
        
        private var apyCache: String {
            set { UserDefaults.standard.setValue(newValue, forKey: "fx.delegateAPY.M") }
            get { UserDefaults.standard.string(forKey: "fx.delegateAPY.M") ?? unknownAmount }
        }
    }
}
