//
//  AddressNames.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX

extension UserDefaults {
    
    func remark(ofAddress address: String) -> String? {
        if let result = UserDefaults.standard.string(forKey: "remark_\(address)") {
            return result.isNotEmpty ? result : nil
        }
        return nil
    }
    
    func set(remark: String, ofAddress address: String) {
        UserDefaults.standard.set(remark, forKey: "remark_\(address)")
    }
    
    func nameOnHUB(ofAddress address: String) -> String? {
        return UserDefaults.standard.string(forKey: "nameOnHUB_\(address)")
    }
    
    func set(nameOnHUB name: String, ofAddress address: String) {
        UserDefaults.standard.set(name, forKey: "nameOnHUB_\(address)")
    }
    
    func nameOnSMS(ofAddress address: String) -> String? {
        return UserDefaults.standard.string(forKey: "nameOnSMS_\(address)")
    }
    
    func set(nameOnSMS name: String, ofAddress address: String) {
        UserDefaults.standard.set(name, forKey: "nameOnSMS_\(address)")
    }
}
