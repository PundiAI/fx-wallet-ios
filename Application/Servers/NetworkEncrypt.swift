//
//  NetworkCrypto.swift
//  XWallet
//
//  Created by Pundix54 on 2020/10/20.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import OpenUDID
import Alamofire
import FunctionX
import SwiftyJSON
import CryptoSwift
import SystemServices
import RxSwift

open class WalletResponseParser: APIResponseParser {
    var rsa: JSONRSAEncoding?
    var aes: JSONAESEncoding?
    init(aes: Bool) {
        super.init()
        if aes {
            self.aes = JSONAESEncoding()
        } else {
            self.rsa = JSONRSAEncoding()
        }
    }
    
    open override func parse(_ data: AFDataResponse<Data>) -> APIResponse {
        
        var response = APIResponse()
        switch data.result {
        
        case .failure(let error):
            response.error = error as NSError
            
        case .success(let value):
            
            let data = aes?.decode(value) ?? rsa?.decode(value)
            
            if let json = try? JSON(data: data ?? value) {
                response = parse(json)
            } else {
                response.error = NSError(domain: "json decode failed", code: -1, userInfo: nil)
            }
        }
        
        return response
    }
}

// MARK: - 配置网络请求加密-解密
struct JSONRSAEncoding: ParameterEncoding {
    static let enable: Bool = false
    let options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)
    func encode(_ urlRequest: Alamofire.URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        guard let parameters = parameters else { return urlRequest }
        var data = try JSONSerialization.data(withJSONObject: parameters, options: options)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let _data = WKRSA().encrypt(data) {
            data = _data
        }
        
        urlRequest.httpBody = data
        return urlRequest
    }
    
    func decode(_ data: Data) -> Data? {
        return WKRSA().decrypt(data)
    }
}

struct JSONAESEncoding: ParameterEncoding {
    let options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)
    func encode(_ urlRequest: Alamofire.URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        guard let parameters = parameters else { return urlRequest }
        var data = try JSONSerialization.data(withJSONObject: parameters, options: options)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        guard let keyString = NetworkEncrypt.aesSecret?.getCryptKeyString()  else {
            return urlRequest
        }
        
        let key:[UInt8] = [UInt8](keyString)
        data = try WKAES().encrypt(key: key, data: data)
        urlRequest.httpBody = data
        
        return urlRequest
    }
    
    func decode(_ data: Data) -> Data? {
        guard let keyString = NetworkEncrypt.aesSecret?.getCryptKeyString() else {
            return data
        }
        do {
            let key:[UInt8] = [UInt8](keyString)
            let datas = try WKAES().decrypt(key: key, data: data)
            return datas
        } catch let error {
            print("Decrypted data error++++++ \(error)")
        }
        return data
    }
}


extension String {
    func getCryptKeyString() -> Data? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return data
    }
    
    func aesEncrypt(key: String) throws -> String {
        let data = self.data(using: .utf8)!.sha256()
        let keyString = key.getCryptKeyString()!
        let key:[UInt8] = [UInt8](keyString)
        let encData = try WKAES().encrypt(key: key, data: data)
        let base64String: String = encData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        let result = String(base64String)
        return result
    }
    
    func rsaEncrypt() -> String {
        let data = self.data(using: .utf8)!.sha256()
        guard let signature =  WKRSA().encrypt(data)?.base64EncodedString() else {
            return ""
        }
        return signature
    }
}

class NetworkEncrypt: NSObject, APIHook {
    var enable:Bool = true
    
    init(enable:Bool) {
        super.init()
        self.enable = enable
    }
    
    func encoding(forUrl url: String) -> ParameterEncoding? {
        if enable == false {return nil}
        
        if url.contains("apiPos/trade/bestTrade") { return nil }
        if needAllEncrypt(forUrl: url) {
            return JSONRSAEncoding()
        } else {
            return JSONAESEncoding()
        }
    }
    
    func additionalHeaders(forUrl url: String) -> HTTPHeaders? {
        if enable == false {return nil}
        
        var headers: [String: String] = ["v": "1", "language": "en"]
        headers["deviceNum"] = OpenUDID.value()
        if let encNum = NetworkEncrypt.encNum {
            headers["encNum"] = encNum
        }
        return HTTPHeaders(headers)
    }
    
    func additionalParameters(forUrl url: String, parameters: Parameters?) -> Parameters? {
        if enable == false {return nil}
        
        let services: SystemServices = SystemServices.shared()
        if needEncrypt(forUrl: url) {
            guard let wallet = XWallet.currentWallet?.wk,
                  let secret = wallet.secret,
                  let userId = wallet.userId else {
                return nil
            }
            
            let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
            let nonce = NSNumber(value: timestamp).doubleValue
            
            var parameters = parameters ?? [:]
            parameters["userId"] = userId
            parameters["nonce"] = "\(nonce)".md5()
            parameters["timestamp"] = String(timestamp)
            parameters["version"] = services.applicationVersion
            
            do {
                let queryString = String(signParams(object: parameters).dropLast(1))
                let sign = try queryString.aesEncrypt(key: secret)
                parameters["sign"] = sign 
                return parameters
            } catch let error {
                WKLog.Error("签名失败 \(error)")
                return nil
            }
        } else if needAllEncrypt(forUrl: url)  {
            var _parameters:Parameters = Parameters()
            let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
            let nonce = NSNumber(value: timestamp).doubleValue
            _parameters["nonce"] = "\(nonce)".md5()
            _parameters["timestamp"] = String(timestamp)
            _parameters["secret"] = parameters?["secret"] as? String
            let queryString = String( signParams(object: _parameters).dropLast(1))
            let sign   = queryString.rsaEncrypt()
            _parameters["sign"] = sign
            return _parameters
        }
        return nil
    }
    
    func request(forUrl url: String, parameters: Parameters?, headers: HTTPHeaders?) -> DataRequest? {
        return nil
    }
    
    func responseParser(forUrl url: String) -> APIResponseParser? {
        if enable == false {return nil}
        
        if url.contains("apiPos/trade/bestTrade") { return nil }
        if needAllEncrypt(forUrl: url) {
            return WalletResponseParser(aes: false)
        } else {
            return WalletResponseParser(aes: true)
        }
    }
    
    func shouldSend(request: APIRequest) -> Bool {
        return true
    }
    
    func shouldDispatch(response: APIResponse) -> Bool {
        return  true
    }
}

extension NetworkEncrypt {
    private func needEncrypt(forUrl url: String) -> Bool {
        let filterURLs = [ "auth/createSignatureParam", "user/addressVerify", "user/createNickName", "encrypt/generate"]
        let case1 = url.contains("/commonXwalletApi/api/")
        let case2 = filterURLs.filter { url.contains($0) }.count == 0
        return case1 && case2
    }
    
    private func signParams(object: Any) -> String {
        switch object {
        case let params as Dictionary<String, Any>:
            let list:NSMutableString = NSMutableString()
            let keys = params.keys.sorted()
            keys.forEach { (key) in
                if let value = params[key] {
                    let result = signParams(object: value)
                    list.append("\(key)=")
                    list.append(result)
                }
            }
            return list as String
        case let items as [Any]:
            let list:NSMutableString = NSMutableString()
            list.append("[")
            items.forEach { (item) in
                let result = signParams(object: item)
                list.append(result)
            }
            list.deleteCharacters(in: NSRange(location: list.length-1, length: 1))
            list.append("]&")
            return list as String
        default:
            return "\(object)&"
        }
    }
}


extension NetworkEncrypt {
    
    private func needAllEncrypt(forUrl url: String) -> Bool {
        let case1 = url.contains("/api/v1/encrypt/generate")
        return case1
    }
    
    private func signature(params: [String: Any]) -> String {
        let result = params.sorted {$0.0 < $1.0}
        var pitem: [String] = [String]()
        for (key, value) in result {
            if let _value = value as? String {
                pitem.append("\(key)=\(_value)")
            } else {
                pitem.append("\(key)=\(String(describing: value))")
            }
        }
        let query = pitem.joined(separator: "&")
        
        guard let signature =  WKRSA().encrypt(query.data(using: .utf8)!.sha256().base64EncodedData())?.base64EncodedString() else {
            return ""
        }
        return signature
    }
}


extension NetworkEncrypt {
    
    static private var db: UserDefaults { .standard }
    
    static var aesSecretKey: String { "fx.aesSecret" }
    static var aesSecret: String? {
        set { db.set(newValue, forKey: NetworkEncrypt.aesSecretKey) }
        get { db.string(forKey: NetworkEncrypt.aesSecretKey) }
    }
    
    static var encNumKey: String { "fx.encNum" }
    static var encNum: String? {
        set { db.set(newValue, forKey: NetworkEncrypt.encNumKey) }
        get { db.string(forKey: NetworkEncrypt.encNumKey) }
    }
    
    static func clear() {
        db.removeObject(forKey: NetworkEncrypt.aesSecretKey)
        db.removeObject(forKey: NetworkEncrypt.encNumKey)
    }
}


extension FxAPIManager {
    func fetchEncrypt(secret: Data) -> Observable<JSON> {
        return rx.post("/commonXwalletApi/api/v1/encrypt/generate", parameters: ["secret": secret.base64EncodedString()])
    }
}

extension NetworkEncrypt {
    func fetchEncrypt() -> Observable<Bool>  {
        if enable {
            
            let secret = String(Date().timeIntervalSince1970).data(using: .utf8)!.sha256()
            return APIManager.fx.fetchEncrypt(secret: secret).flatMap({ (json) -> Observable<Bool> in
                
                let encNum = json["encNum"].stringValue
                if let serverSecret = Data(base64Encoded: json["secret"].stringValue),
                   serverSecret.count == 32 {
                 
                    let clientKey = secret.bytes
                    let serverKey = serverSecret.bytes
                    var aesKey: [UInt8] = []
                    for idx in 0...31 {
                        aesKey.append(clientKey[idx] ^ serverKey[idx])
                    }
                    
                    NetworkEncrypt.encNum = encNum
                    NetworkEncrypt.aesSecret = Data(aesKey).base64EncodedString()
                }
                return .just(true)
            })

        }else {
            return .just(true)
        }
        
    }
}
