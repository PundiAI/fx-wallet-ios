import FunctionX
import RxSwift
import SQLite
import SwiftyJSON
import WKKit
private let DBPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/functionX.sqlite3"
private let selfAddress = DBColumn<String>("selfAddress")
private let chatRoomId = DBColumn<String>("chatRoomId")
private let contactPK = DBColumn<Data>("contactPK")
private let contactName = DBColumn<String>("contactName")
private let contactAddress = DBColumn<String>("contactAddress")
private let contactPrimaryKey = DBColumn<String>("contactPrimaryKey")
private let lastChatMsg = DBColumn<String>("lastChatMsg")
private let lastChatMsgTime = DBColumn<Int64>("lastCaatMsgTime")

class SmsContactListCache: DBTable {
    static let shared = SmsContactListCache(in: DBPath)
    override var name: String { "SmsContact" }
    override init(in dbPath: String) {
        super.init(in: dbPath)
        guard let db = connection else { return }
        do {
            try db.run(table.create(temporary: false, ifNotExists: true) { t in
                t.column(selfAddress.expression)
                t.column(chatRoomId.expression)
                t.column(contactPK.expression)
                t.column(contactName.expression)
                t.column(contactAddress.expression)
                t.column(contactPrimaryKey.expression, primaryKey: true)
            })
        } catch {
            print("create table(\(name)) error:", error)
        }
    }

    func insertOrReplace(_ contactList: [SmsUser], ofUser userAddress: String) -> Observable<Bool> {
        let inserts: [DBOperation] = contactList.map { contact in
            let primaryKey = (userAddress + contact.address).md5()
            let insert = self.table.insert(or: .replace,
                                           contactPrimaryKey.expression <- primaryKey,
                                           selfAddress.expression <- userAddress,
                                           chatRoomId.expression <- contact.chatRoomId,
                                           contactPK.expression <- contact.publicKey,
                                           contactName.expression <- contact.name,
                                           contactAddress.expression <- contact.address)
            return DBOperation(insert)
        }
        return commit(operations: inserts)
    }

    func selectAll(ofUser userAddress: String) -> Observable<[SmsUser]> {
        guard let db = connection else { return Observable.just([]) }
        return Observable.create { [weak self] (subscriber) -> Disposable in
            guard let this = self else { return Disposables.create() }
            this.operationQueue.async {
                do {
                    let query = this.table
                        .filter(selfAddress.expression == userAddress)
                    let sql = query.asSQL().replacingOccurrences(of: "(_:_:)", with: "")
                    let statement = try db.prepare(sql)
                    var users: [SmsUser] = []
                    for row in statement {
                        let user = SmsUser()
                        for (idx, name) in statement.columnNames.enumerated() {
                            let v = row[idx]
                            switch name {
                            case chatRoomId.name:
                                user.chatRoomId = chatRoomId.value(v) ?? ""
                            case contactPK.name:
                                user.publicKey = contactPK.value(v) ?? Data()
                            case contactName.name:
                                user.name = contactName.value(v) ?? ""
                            case contactAddress.name:
                                user.address = contactAddress.value(v) ?? ""
                            default: continue
                            }
                        }
                        users.append(user)
                    }
                    subscriber.onNext(users)
                    subscriber.onCompleted()
                } catch {
                    subscriber.onNext([])
                    subscriber.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

private let status = DBColumn<Int64>("status")
private let sortHeight = DBColumn<Int64>("sortHeight")
private let confirmTime = DBColumn<String>("confirmTime")
private let txHash = DBColumn<String>("txHash")
private let txHeight = DBColumn<Int64>("txHeight")
private let txGroupId = DBColumn<String>("txGroupId")
private let preTxHeight = DBColumn<Int64>("preTxHeight")
private let nextTxHeight = DBColumn<Int64>("nextTxHeight")
private let txMsg = DBColumn<String>("txMsg")
private let txToPK = DBColumn<Data>("txToPK")
private let txFromPK = DBColumn<Data>("txFromPK")
private let txTokens = DBColumn<String>("txTokens")
private let txRawMsg = DBColumn<String>("txRawMsg")

class SmsMessageCache: DBTable {
    static let shared = SmsMessageCache(in: DBPath)
    override var name: String { "smsMessage" }
    override init(in dbPath: String) {
        super.init(in: dbPath)
        guard let db = connection else { return }
        do {
            try db.run(table.create(temporary: false, ifNotExists: true) { t in
                t.column(status.expression)
                t.column(sortHeight.expression, primaryKey: true)
                t.column(confirmTime.expression)
                t.column(txHash.expression)
                t.column(txHeight.expression)
                t.column(txGroupId.expression)
                t.column(preTxHeight.expression)
                t.column(nextTxHeight.expression)
                t.column(txMsg.expression)
                t.column(txToPK.expression)
                t.column(txFromPK.expression)
                t.column(txTokens.expression)
                t.column(txRawMsg.expression)
            })
        } catch {
            print("create table(\(name)) error:", error)
        }
    }

    func delete(_ messages: [SmsMessage]) -> Observable<Bool> {
        var deletes: [DBOperation] = []
        for msg in messages {
            let item = table.filter(txGroupId.expression == msg.txGroupId && sortHeight.expression == Int64(msg.sortHeight))
            deletes.append(DBOperation(item.delete()))
        }
        return commit(operations: deletes)
    }

    func insertOrReplace(_ messages: [SmsMessage]) -> Observable<Bool> {
        let inserts: [DBOperation] = messages.map { msg in
            let tokens = msg.message.transferTokens.map { $0.json }
            var msgTokens = "[]"
            if let data = try? JSONSerialization.data(withJSONObject: tokens, options: [.sortedKeys]) {
                msgTokens = String(data: data, encoding: .utf8) ?? "[]"
            }
            let insert = self.table.insert(or: .replace,
                                           status.expression <- Int64(msg.status.rawValue),
                                           sortHeight.expression <- Int64(msg.sortHeight),
                                           confirmTime.expression <- msg.confirmTime,
                                           txHash.expression <- msg.txHash,
                                           txHeight.expression <- Int64(msg.txHeight),
                                           preTxHeight.expression <- Int64(msg.preTxHeight),
                                           nextTxHeight.expression <- Int64(msg.nextTxHeight),
                                           txGroupId.expression <- msg.txGroupId,
                                           txMsg.expression <- msg.message.content,
                                           txToPK.expression <- msg.message.toPublicKey,
                                           txFromPK.expression <- msg.message.fromPublicKey,
                                           txTokens.expression <- msgTokens,
                                           txRawMsg.expression <- msg.message.encryptedContent)
            return DBOperation(insert)
        }
        return commit(operations: inserts)
    }

    func select(ofGroupId groupId: String, fromHeight height: UInt64, direction _: Bool = false, pageSize: Int = 20) -> Observable<[SmsMessage]> {
        guard let db = connection else { return Observable.just([]) }
        return Observable.create { [weak self] (subscriber) -> Disposable in
            guard let this = self else { return Disposables.create() }
            this.operationQueue.async {
                do {
                    let query = this.table
                        .filter(txGroupId.expression == groupId && sortHeight.expression < Int64(height))
                        .order(sortHeight.expression.desc)
                        .limit(pageSize)
                    let sql = query.asSQL().replacingOccurrences(of: "(_:_:)", with: "")
                    let statement = try db.prepare(sql)
                    var messages: [SmsMessage] = []
                    for row in statement {
                        let sms = SmsMessage()
                        var sortHeightT: UInt64 = 0
                        for (idx, name) in statement.columnNames.enumerated() {
                            let v = row[idx]
                            switch name {
                            case status.name:
                                sms.status = SmsMessage.Status(rawValue: Int(status.value(v) ?? 0)) ?? .successed
                            case confirmTime.name:
                                sms.confirmTime = confirmTime.value(v) ?? ""
                            case sortHeight.name:
                                sortHeightT = UInt64(sortHeight.value(v) ?? 0)
                            case txHash.name:
                                sms.txHash = txHash.value(v) ?? ""
                            case txHeight.name:
                                sms.txHeight = UInt64(txHeight.value(v) ?? 0)
                            case preTxHeight.name:
                                sms.preTxHeight = UInt64(preTxHeight.value(v) ?? 0)
                            case nextTxHeight.name:
                                sms.nextTxHeight = UInt64(nextTxHeight.value(v) ?? 0)
                            case txGroupId.name:
                                sms.txGroupId = txGroupId.value(v) ?? ""
                            case txMsg.name:
                                sms.message.content = txMsg.value(v) ?? ""
                            case txToPK.name:
                                sms.message.toPublicKey = txToPK.value(v) ?? Data()
                            case txFromPK.name:
                                sms.message.fromPublicKey = txFromPK.value(v) ?? Data()
                            case txRawMsg.name:
                                sms.message.encryptedContent = txRawMsg.value(v) ?? ""
                            case txTokens.name:
                                let tokens = JSON(parseJSON: txTokens.value(v) ?? "[]")
                                sms.message.transferTokens = tokens.arrayValue.map { TransactionMessage.Coin(amount: $0["amount"].stringValue, denom: $0["denom"].stringValue) }
                            default: continue
                            }
                        }
                        if sms.txHeight == 0 { sms.status = .failed }
                        if !sms.isSuccessed { sms.sendingHeight = sortHeightT }
                        sms.message.deriveAddress()
                        messages.append(sms)
                    }
                    subscriber.onNext(messages)
                    subscriber.onCompleted()
                } catch {
                    subscriber.onNext([])
                    subscriber.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
