//
//  SmsUser.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/11.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import SwiftyJSON
import DateToolsSwift
import TrustWalletCore

//MARK: SmsCoin
class SmsCoin {
    
    public var denom = ""
    public var amount = "0"
    public init(amount: String = "0", denom: String = "fxc") {
        self.denom = denom
        self.amount = amount
    }
    convenience init(json: JSON) {
        self.init(amount: json["amount"].stringValue, denom: json["denom"].stringValue)
    }
    
    static var `default`: SmsCoin { SmsCoin(denom: FxTransaction.token) }
    
    var unit: String { return denom.uppercased() }
}





//MARK: SmsUser
class SmsUser {
    
    var name = ""
    var address = ""
    var publicKey = Data()
    
    var chatRoomId = ""
    var createTime: Double = 0
    var lastSeenTime: Double = 0
    
    var coins: [SmsCoin] = []
    var fxc: SmsCoin? { coin(for: .hub) }
    var msgc: SmsCoin? { coin(for: .sms) }
    var payc: SmsCoin? { coin(for: .order) }
    
    func coin(for chain: FxChain) -> SmsCoin? {
        for coin in coins {
            if coin.denom == chain.token { return coin }
        }
        return nil
    }
    
    static func instance(fromChatList json: JSON) -> SmsUser {
        let v = SmsUser()
        v.name = json["to_name"].stringValue
        v.address = json["to_address"].stringValue
        v.publicKey = Data(base64Encoded: json["to_pub_key", "value"].stringValue) ?? Data()
        v.chatRoomId = json["group_id"].stringValue
        v.createTime = json["last_time"].doubleValue
        return v
    }
    
    static func instance(fromQuery json: JSON) -> SmsUser {
        let v = SmsUser()
        v.name = json["name"].stringValue
        v.coins = json["coins"].arrayValue.map{ SmsCoin(json: $0) }
        v.address = json["address"].stringValue
        v.publicKey = Data(base64Encoded: json["public_key", "value"].stringValue) ?? Data()
        return v
    }
    
    func amount(ofDenom denom: String) -> String {
        for coin in coins {
            if coin.denom.lowercased() == denom.lowercased() { return coin.amount }
        }
        return "0"
    }
}






//MARK: SmsMessage
class SmsMessage {
    
    enum Types {
        case sendText
        case sendGift
        case receiveText
        case receiveGift
    }
    
    enum Status: Int {
        case sending = 0
        case failed = 1
        case successed = 2
    }
    
    static var empty: SmsMessage { SmsMessage() }
    static func sortHeight(by txHeight: UInt64) -> UInt64 {
        return txHeight * 100
    }
    
    var type = Types.sendText
    var isSender: Bool { type == .sendText || type == .sendGift }
    var isReceiver: Bool { !isSender }
    func deriveType(by senderAddress: String) {
        if message.fromAddress == senderAddress {
            type = message.transferTokens.count > 0 ? .sendGift : .sendText
        } else {
            type = message.transferTokens.count > 0 ? .receiveGift : .receiveText
        }
    }
    
    var receiveName = ""
    
    private var _status = Status.sending
    var status: Status {
        get { _status }
        set {
            if isSuccessed { return }
            _status = newValue
        }
    }
    var isFailed: Bool { _status == .failed }
    var isSending: Bool { _status == .sending }
    var isSuccessed: Bool { _status == .successed }
    
    var txHash = ""
    var txGroupId = ""
    var txHeight: UInt64 = 0
    
    var preTxHeight: UInt64 = 0
    var nextTxHeight: UInt64 = 0
    var hasNext: Bool { return nextTxHeight > 0 && nextTxHeight > txHeight }
    
    var sendingHeight: UInt64 = 0
    var sendingSequence: Int64 = 0
    
    var sortHeight: UInt64 {
        return isSuccessed ? SmsMessage.sortHeight(by: txHeight) : sendingHeight
    }
    
    var id: UInt64 {
        return isSuccessed ? txHeight : sendingHeight
    }
    
    var message = TransactionMessage.SmsSendMsg()
    
    var confirmTime = "" {
        didSet {
            guard confirmTime.isNotEmpty else { return  }
            
            availableTimestamp = Date(dateString: confirmTime, format: "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: TimeZone(abbreviation: "GMT")!).timeIntervalSince1970
        }
    }
    
    var isToday: Bool { Date().timeIntervalSince1970 - availableTimestamp <= 24 * 60 * 60 }
    var GMTTime: String { return Date(timeIntervalSince1970: availableTimestamp).format(with: "z YYYY-MM-dd HH:mm:ss") }
    var availableTime: String { Date(timeIntervalSince1970: availableTimestamp).format(with: "YYYY-MM-dd HH:mm:ss") }
    var availableTimestamp: Double = 0
    func estimateConfirmTime(_ force: Bool = false) {
        guard confirmTime.isEmpty || force else { return }
        
        let now = Date().addingTimeInterval(1)
        confirmTime = now.format(with: "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: TimeZone(abbreviation: "GMT")!)
    }
}




//MARK: Parser
class SmsMessageParser {
    
    let privateKey: PrivateKey
    init(privateKey: PrivateKey) {
        self.privateKey = privateKey
    }
    
    func sms(fromTx txInfo: JSON) -> SmsMessage? {
        guard let smsMsg = parse(tx: txInfo["tx"].stringValue) else {
            return nil
        }
        
        let sms = SmsMessage()
        sms.status = .successed
        sms.txHash = txInfo["hash"].stringValue
        sms.message = smsMsg
        sms.txHeight = txInfo["height"].uInt64Value
        return sms
    }
    
    func sms(fromBlock blockInfo: JSON) -> SmsMessage? {
        
        for tx in blockInfo["block", "data", "txs"].arrayValue {
            guard let smsMsg = parse(tx: tx.stringValue) else { continue }
            
            let sms = SmsMessage()
            sms.status = .successed
//            sms.txHash = blockInfo["block_meta", "header", "last_commit_hash"].stringValue
            sms.message = smsMsg
            sms.txHeight = blockInfo["block_meta", "header", "height"].uInt64Value
            sms.confirmTime = blockInfo["block_meta", "header", "time"].stringValue
            return sms
        }
        return nil
    }
    
    func parse(tx: String) -> TransactionMessage.SmsSendMsg? {
        guard let data = Data(base64Encoded: tx) else { return nil }
        
        let txMsg = TransactionMessage(data: data)
        guard let smsSend = txMsg.smsSend, smsSend.content.count >= 96 else {
            return nil
        }
        
        let privateKey = self.privateKey
        let myPublicKey = privateKey.getPublicKeySecp256k1(compressed: true)
        
        let msg = smsSend.content
        let ivHex = msg.substring(range: NSRange(location: 64, length: 32))
        let macHex = msg.substring(to: 63)
        let encryptedHex = msg.substring(from: 64 + 32)
        
        var ephemeralPK: PublicKey?
        if myPublicKey.data == smsSend.toPublicKey {
            ephemeralPK = PublicKey(data: smsSend.fromPublicKey, type: .secp256k1)
        } else if myPublicKey.data == smsSend.fromPublicKey {
            ephemeralPK = PublicKey(data: smsSend.toPublicKey, type: .secp256k1)
        }
        
        if let publicKeyHex = ephemeralPK?.uncompressed.data.hexString,
            let decrypted = try? ECC.eciesDecrypt(ECC.Result(value: encryptedHex, iv: ivHex, mac: macHex, ephemeralPK: publicKeyHex), privateKey: privateKey.data.hexString) {
            smsSend.content = decrypted
        }
        
        return smsSend
    }
}
