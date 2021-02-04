//
//  FxWalletConnectSession.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//


import RxSwift
import RxCocoa
import SwiftyJSON
import TrustWalletCore

class FxWalletConnectSession {

    static let shared = FxWalletConnectSession()
    
    struct Context {
        let url: String
        let privateKey: PrivateKey
        
        var publicKey: PublicKey { return privateKey.getPublicKeySecp256k1(compressed: true) }
        var address: String { return CosmosAddress(hrp: .cosmos, publicKey: publicKey)?.description ?? "" }
    }
    
    private(set) var context: Context!
    fileprivate var peerMeta: WCPeerMeta?
    fileprivate var interactor: WCInteractor?
    fileprivate var currentRequestId: Int64 = 0
    
    let error = BehaviorRelay<Error?>(value: nil)
    let isConneting = BehaviorRelay<Bool>(value: false)
    let isConnected = BehaviorRelay<Bool>(value: false)
    
    func run(_ context: Context) {
        if let old = self.context,
            old.url != context.url || old.privateKey.data != context.privateKey.data {
            interactor?.killSession().cauterize()
            interactor?.disconnect()
        }
        self.context = context
        if interactor?.state == .connected { return }
        
        connect()
    }
    
    //MARK: Bind
    fileprivate func bind(interactor: WCInteractor) {
        self.interactor = interactor
        
        weak var welf = self
        interactor.disableSSLCertValidation()
        interactor.onError = { welf?.error.accept($0) }
        interactor.onDisconnect = { welf?.error.accept($0) }
        
        let account = ["from_address": context.address,
                       "publicKey": context.publicKey.data.hexString].encodedString
        interactor.onSessionRequest = { (id, peerParam) in
            welf?.peerMeta = peerParam.peerMeta
            
            interactor.approveSession(accounts: [account], chainId: Int(id)).cauterize()
        }
        
        interactor.onCustomRequest = { (topic, request) in
            
            let json = JSON(request)
            if let method = json["method"].string {
                
                welf?.currentRequestId = json["id"].int64Value
                
                var parameter = JSON([:])
                if let paramsString = json["params"].arrayValue.firstObject()?.string {
                    parameter = JSON(parseJSON: paramsString)
                }

                welf?.handleMethod(method, json, parameter)
            }
        }
        
        interactor.didUpdateState = { state in
            welf?.isConneting.accept(state == .connecting)
            welf?.isConnected.accept(state == .connected)
        }
    }
    
    //MARK: Action
    
    private func handleMethod(_ method: String, _ json: JSON, _ parameter: JSON) {
        guard let topController = Router.manager.topViewController else { return }
        
        let authView = WalletConnectAuthView()
        authView.eventHandler = { allow in
            if !allow {
                self.response(code: 10001, msg: "", data: "")
            } else {
                
                switch method {
                case "encode-msg":
                    self.encodeMsg(json, parameter: parameter)
                case "decode-msg":
                    self.decodeMsg(json, parameter: parameter)
                case "register-name":
                    self.register(json, parameter: parameter)
                case "name-authorization":
                    self.authorization(json, parameter: parameter)
                default: break
                }
            }
        }
        authView.show(inView: topController.view)
    }
    
    private func authorization(_ json: JSON, parameter: JSON) {
        
        let msg = Fx.AuthorizationMessage()
        msg.address = self.context.address
        msg.sequence = parameter["sequence"].stringValue
        msg.accountNumber = parameter["account_Number"].stringValue
        msg.authorizationName = parameter["name"].stringValue
        msg.authorizationChainId = parameter["chain_id"].stringValue

        let signedMsg = ECC.ecdsaCompactsign(data: msg.serializedData(), privateKey: self.context.privateKey.data)
        self.response(data: ["sign": signedMsg])
    }
    
    private func encodeMsg(_ json: JSON, parameter: JSON) {
        
        guard let encrypt = try? ECC.eciesEncrypt(parameter["msg"].stringValue, privateKey: context.privateKey.data.hexString, publicKey: parameter["toPubKey"].stringValue) else {
            response(code: 10000, msg: "encrypt failure", data: "")
            return
        }
        
        let msg = Fx.SendSMSMessage()
        msg.chainId = parameter["chain_id"].stringValue
        msg.content = encrypt.mac + encrypt.iv + encrypt.value
        msg.sequence = parameter["sequence"].stringValue
        msg.accountNumber = parameter["account_Number"].stringValue
        msg.toPublicKeyBase64 = Data(hex: parameter["toPubKey"].stringValue).base64EncodedString()
        msg.fromPublicKeyBase64 = context.publicKey.data.base64EncodedString()
        msg.fee = parameter["fee"]
        msg.transferAmount = parameter["amount"]
        
        let signedMsg = ECC.ecdsaCompactsign(data: msg.serializedData(), privateKey: context.privateKey.data)
        response(data: ["msg": msg.content, "sign": signedMsg])
    }
    
    private func decodeMsg(_ json: JSON, parameter: JSON) {
        
        let myPublicKey = context.publicKey
        var result: [[String: Any]] = []
        for item in parameter["tx"].arrayValue {
            
            let tx = item["tx"].stringValue
            guard let data = Data(base64Encoded: tx) else { continue }
            
            var json: [String: Any] = [:]
            let txMsg = Fx.TransferMessage(transactionData: data)
            if let sendSms = txMsg.sendSms {
                
                json["hash"] = item["hash"].stringValue
                json["height"] = item["height"].stringValue
                json["to_address"] = txMsg.toAddress
                json["from_address"] = txMsg.fromAddress
                if sendSms.content.count >= 96 {
                    
                    let msg = sendSms.content
                    let ivHex = msg.substring(range: NSRange(location: 64, length: 32))
                    let macHex = msg.substring(to: 63)
                    let encryptedHex = msg.substring(from: 64 + 32)
                    
                    var ephemeralPK: PublicKey?
                    if myPublicKey.data == sendSms.fromPublicKey?.compressed.data {
                        ephemeralPK = sendSms.toPublicKey
                    } else if myPublicKey.data == sendSms.toPublicKey?.compressed.data {
                        ephemeralPK = sendSms.fromPublicKey
                    }
                    
                    if let publicKeyHex = ephemeralPK?.uncompressed.data.hexString,
                        let decrypted = try? ECC.eciesDecrypt(ECC.Result(value: encryptedHex, iv: ivHex, mac: macHex, ephemeralPK: publicKeyHex), privateKey: context.privateKey.data.hexString) {
                        json["msg"] = decrypted
                    }
                    json["fee"] = sendSms.fee
                    json["amount"] = sendSms.amount
                }
            }
            result.append(json)
        }
        response(data: result)
    }

    private func register(_ result: JSON, parameter: JSON) {
        
        let smsRegisterParams = parameter["sms"]
        let userRegisterParams = parameter["hub"]

        let smsRegisterMsg = Fx.SMSRegisterMessage()
        smsRegisterMsg.sequence = smsRegisterParams["sequence"].stringValue
        smsRegisterMsg.fromAddress = smsRegisterParams["from_address"].stringValue
        smsRegisterMsg.registerName = smsRegisterParams["name"].stringValue
        smsRegisterMsg.accountNumber = smsRegisterParams["account_Number"].stringValue
        let signedSmsRegisterMsg = ECC.ecdsaCompactsign(data: smsRegisterMsg.serializedData(), privateKey: context.privateKey.data)

        let userRegisterMsg = Fx.UserRegisterMessage()
        userRegisterMsg.sequence = userRegisterParams["sequence"].stringValue
        userRegisterMsg.userAddress = userRegisterParams["from_address"].stringValue
        userRegisterMsg.registerName = userRegisterParams["name"].stringValue
        userRegisterMsg.accountNumber = userRegisterParams["account_Number"].stringValue
        let signedUserRegisterMsg = ECC.ecdsaCompactsign(data: userRegisterMsg.serializedData(), privateKey: context.privateKey.data)

        response(data: ["smsSign": signedSmsRegisterMsg, "hubSign": signedUserRegisterMsg])
    }
}

//MARK: Utils
extension FxWalletConnectSession {
    
    var clientId: String {
        
        let id: String
        if let cacheId = UserDefaults.standard.string(forKey: "fx.wc.clientId") {
            id = cacheId
        } else {
            id = UUID().uuidString
            UserDefaults.standard.set(id, forKey: "fx.wc.clientId")
        }
        return id
    }
    
    fileprivate func connect() {
        guard let session = WCSession.from(string: context.url) else { return }
        
        let clientMeta = WCPeerMeta(name: "", url: "")
        let interactor = WCInteractor(session: session, meta: clientMeta, clientId: clientId)
        bind(interactor: interactor)
        
        interactor.connect().cauterize()
    }
    
    fileprivate func response(code: Int = 200, msg: String = "", data: Any) {
        
        let result: [String: Any] = ["code": code, "msg": msg, "data": data]
        let resultJson = JSON(result).rawString() ?? ""
        interactor?.approveRequest(id: currentRequestId, result: resultJson).cauterize()
    }
}
