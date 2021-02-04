//
//  Ramp.config.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/1/13.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Foundation
import WKKit

class RampConfig {
    static var host: String {
        switch ServerENV.current {
        case .dev: return "https://buy.ramp.network/"
        case .uat: return "https://buy.ramp.network/"
        case .release: return "https://buy.ramp.network/"
        }
    }
}
