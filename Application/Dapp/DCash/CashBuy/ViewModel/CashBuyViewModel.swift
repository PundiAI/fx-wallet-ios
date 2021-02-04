//
//  File.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import WKKit
import RxSwift
import RxCocoa

class CashBuyViewModel {
    init(coin: Coin) {
        self.coin = coin
    }
    let coin: Coin
    
    lazy var addressOb = BehaviorRelay<Keypair?>(value: nil)
    lazy var inputTxOb = BehaviorRelay<String?>(value: nil)
    lazy var agreeOb = BehaviorRelay<Bool>(value: false)
}
