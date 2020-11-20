import FunctionX
import SwiftyJSON
import WKKit
import XWebKit
import XWebView
class DappJSStorage: WKJSAction {
    private static var storage: [String: [String: Any]] = [:]
    private static func keyValues(forProject project: String) -> [String: Any] {
        return storage[project] ?? [:]
    }

    private static func setKeyValues(forProject project: String, _ kv: [String: Any]) {
        guard kv.count > 0 else { return }
        var temp = keyValues(forProject: project)
        for (k, v) in kv {
            temp[k] = v
        }
        storage[project] = temp
    }

    public static func clear(project: String) { storage[project] = nil }
    public static func clearAll() { storage = [:] }
    convenience init(project: String) {
        self.init()
        self.project = project
    }

    override public func support() -> [String] {
        return ["setValues", "getValues"].map { (_it) -> String in
            "\(getPrefix())\(_it)"
        }
    }

    private func projectName() -> String {
        return project ?? "default"
    }

    @objc func setValues(_ keyValues: [String: Any], _ callback: XWVScriptObject) {
        DappJSStorage.setKeyValues(forProject: projectName(), keyValues)
        callback.success()
    }

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
