//
//  FxServerENV.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/8.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation

enum ServerENV: Int {
    case dev
    case uat
    case release
    
//    static var current: ServerENV { .dev }
    static var current: ServerENV { .uat }
//    static var current: ServerENV { .release }
    
    var rawString: String {
        switch self {
        case .dev: return "dev"
        case .uat: return "uat"
        case .release: return "release"
        }
    }
}

extension ServerENV {
    var isDev: Bool { self == .dev }
    var isUat: Bool { self == .uat }
    var isRelease: Bool { self == .release }
}
