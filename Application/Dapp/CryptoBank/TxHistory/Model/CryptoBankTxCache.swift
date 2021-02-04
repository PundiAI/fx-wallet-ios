//
//  CryptoBankTxCache.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/5.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//


import SQLite
import RxSwift

private let type = DBColumn<Int64>("txType")

private let coinId = DBColumn<String>("coinId")
private let walletId = DBColumn<String>("walletId")

private let txHash = DBColumn<String>("txHash")
private let amount = DBColumn<String>("amount")
private let address = DBColumn<String>("address")
private let timestamp = DBColumn<Int64>("dtimestamp")


//MARK: CryptoBankTxCache
class CryptoBankTxCache: DBTable {
    
    static let shared = CryptoBankTxCache(in: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/functionX_AAveTx.sqlite3")
        
    
    override var name: String { "CryptoBankTxInfo" }
    
    override init(in dbPath: String) {
        super.init(in: dbPath)
        guard let db = connection else { return }
        
        do {
            if self.version == 0 {
                self.version = 1
                try db.run(table.create(temporary: false, ifNotExists: true) { t in
                    t.column(type.expression)
                    t.column(coinId.expression)
                    t.column(walletId.expression)
                    t.column(timestamp.expression)
                    t.column(address.expression)
                    t.column(amount.expression)
                    t.column(txHash.expression, primaryKey: true)
                })
            }
        } catch {
            print("create table(\(name)) error:", error)
        }
    }
    
    func insertOrReplace(_ items: [CryptoBankTxInfo]) -> Observable<Bool> {
        let inserts: [DBOperation] = items.map{ item in
            let insert = self.table.insert(or: .replace,
                                           type.expression <- item.type.rawValue,
                                           coinId.expression <- item.coinId,
                                           walletId.expression <- item.walletId,
                                           timestamp.expression <- item.timestamp,
                                           address.expression <- item.address,
                                           amount.expression <- item.amount,
                                           txHash.expression <- item.txHash
                                           )
            return DBOperation(insert)
        }
        return commit(operations: inserts)
    }
    
    func deleteAll(ofWallet wid: String) -> Observable<Bool> {

        let filter = self.table.filter(walletId.expression == wid)
        let operation = DBOperation(filter.delete())
        return commit(operations: [operation])
    }

    func selectAll(ofWallet wid: String, page: Int, pageSize: Int) -> Observable<[CryptoBankTxInfo]> {
        guard let db = connection else { return Observable.just([]) }

        return Observable.create {[weak self] (subscriber) -> Disposable in
            guard let this = self else { return Disposables.create() }

            this.operationQueue.async {
                do {

                    let query = this.table
                        .filter(walletId.expression == wid)
                        .order(timestamp.expression.desc)
                        .limit(pageSize, offset: page * pageSize)
                    
                    let sql = query.asSQL().replacingOccurrences(of: "(_:_:)", with: "")
                    let statement = try db.prepare(sql)

                    var items: [CryptoBankTxInfo] = []
                    for row in statement {
                        let item = CryptoBankTxInfo()
                        item.walletId = wid
                        
                        for (idx, name) in statement.columnNames.enumerated() {

                            let v = row[idx]
                            switch name {
                            case type.name:
                                item.type = CryptoBankTxInfo.Types(rawValue: type.value(v) ?? 0) ?? .invalid
                            case coinId.name:
                                item.coinId = coinId.value(v) ?? ""
                            case timestamp.name:
                                item.timestamp = timestamp.value(v) ?? 0
                            case address.name:
                                item.address = address.value(v) ?? ""
                            case amount.name:
                                item.amount = amount.value(v) ?? ""
                            case txHash.name:
                                item.txHash = txHash.value(v) ?? ""
                            default:continue
                            }
                        }
                        item.syncIfNeed()
                        items.append(item)
                    }
                    
                    subscriber.onNext(items)
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
