//
//  Swap.config.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/1/13.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Foundation


class OxConfig {
    
    static var endpoint: String { NodeManager.shared.currentEthereumNode.url }
    
    static var ChainId: Int { NodeManager.shared.currentEthereumNode.chainId.i }
    
    static var apiHost: String {
        
        if NodeManager.shared.currentEthereumNode.isTestnet {
            return "https://kovan.api.0x.org/"
        } else {
            return "https://api.0x.org/"
        }
    }
}
