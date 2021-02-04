//
//  DappJSStorage.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/22.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import XWebKit
import XWebView
import FunctionX
import SwiftyJSON

class DappJSStorage: WKJSAction {
    
    static private var storage: [String: [String: Any]] = [:]
    static private func keyValues(forProject project: String) -> [String: Any] {
        return storage[project] ?? [:]
    }
    
    static private func setKeyValues(forProject project: String, _ kv: [String: Any]) {
        guard kv.count > 0 else { return }
        
        var temp = keyValues(forProject: project)
        for (k, v) in kv {
            temp[k] = v
        }
        storage[project] = temp
    }
    
    static public func clear(project: String) { storage[project] = nil }
    static public func clearAll() { storage = [:] }
    
    convenience init(project: String) {
        self.init()
        self.project = project
    }
    
    override public func support() -> [String] {
        return ["setValues", "getValues"].map({ (_it) -> String in
            return "\(getPrefix())\(_it)"
        })
    }
    
    private func projectName() -> String {
        return self.project ?? "default"
    }

    @objc func setValues(_ keyValues: [String: Any], _ callback: XWVScriptObject) {
        DappJSStorage.setKeyValues(forProject: projectName(), keyValues)
        callback.success()
    }

    // 获取缓存数据
    @objc func getValues(_ parmas: [String: Any], _ callback: XWVScriptObject) {
        guard let keys = parmas["keys"] as? [String] else {
            callback.error(code: .unrecognizedParams)
            return
        }
        
        let storage = DappJSStorage.keyValues(forProject: projectName())
        var result: [String: Any] = [:]
        for key in keys {
            result[key] = storage[key] ?? ""
        }
        callback.success(data: result)
    }
    
}
