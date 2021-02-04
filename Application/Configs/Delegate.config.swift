//
//  Delegate.config.swift
//  fxWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Foundation
import WKKit

class DelegateConfig {
    static var apiHost: String {
        switch ServerENV.current {
        case .dev: return "https://v68sbvamoqe4-test.blockchain.functionx.io/explorer/fx-explorer-fxcore/apiBlockExplorer"
        case .uat: return "https://v68sbvamoqe4-test.blockchain.functionx.io/explorer/fx-explorer-fxcore/apiBlockExplorer"
        case .release: return "https://v68sbvamoqe4-test.blockchain.functionx.io/explorer/fx-explorer-fxcore/apiBlockExplorer"
        }
    }
}
