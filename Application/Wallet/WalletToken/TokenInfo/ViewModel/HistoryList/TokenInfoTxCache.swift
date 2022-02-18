////
////  TokenInfoTxCache.swift
////  fxWallet
////
////  Created by 梅杰 on 2021/3/22.
////  Copyright © 2021 Andy.Chan 6K. All rights reserved.
////
//
//import SQLite
//import RxSwift
//
//import WKKit
//import SwiftyJSON
//import Web3
//
//private let type = DBColumn<Int64>("txType")
//
//private let coinId = DBColumn<String>("coinId")
//private let walletId = DBColumn<String>("walletId")
//
//private let txHash = DBColumn<String>("txHash")
//private let amount = DBColumn<String>("amount")
//private let address = DBColumn<String>("address")
//
//private let timestamp = DBColumn<Int64>("dtimestamp")
//private let isPending = DBColumn<Bool>("isPending")
//
//private let pid = DBColumn<String>("pid")
//private let chainId = DBColumn<Int64>("chainId")
//
//
//
////"id" : 8,
////"amount" : 0.5,
////"transactionHash" : "0x74eb9ee5824da069b7d0f7ffdf6d24f4cb2048fce4a0cf71e0e054cc7e922c0f",
////"type" : 1,
////"blockDt" : 1617162932000,
////"chainId" : 20,
////"address" : "0x77f2022532009c5eb4c6c70f395deaaa793481bc",
////"unit" : "ETH"
//
////MARK: TokenInfoTxCache
//class TokenInfoTxCache: DBTable {
//    
//    static let shared = TokenInfoTxCache(in: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/functionX_Tx.sqlite3")
//        
//    
//    override var name: String { "TokenInfoTxInfo" }
//    
//    override init(in dbPath: String) {
//        super.init(in: dbPath)
//        guard let db = connection else { return }
//        
//        do {
//            if self.version == 0 {
//                self.version = 1
//                try db.run(table.create(temporary: false, ifNotExists: true) { t in
//                    t.column(type.expression)
//                    t.column(coinId.expression)
//                    t.column(walletId.expression)
//                    t.column(timestamp.expression)
//                    t.column(address.expression)
//                    t.column(amount.expression)
//                    t.column(isPending.expression)
//                    t.column(pid.expression)
//                    t.column(chainId.expression)
//                    t.column(txHash.expression)
//                    t.primaryKey(type.expression, txHash.expression)
//                })
//            }
//            
//        } catch {
//            print("create table(\(name)) error:", error)
//        }
//    }
//    
//    func insertOrReplace(_ items: [TokenInfoTxInfo]) -> Observable<Bool> {
//        let inserts: [DBOperation] = items.map{ item in
//            let insert = self.table.insert(or: .replace,
//                                           type.expression <- item.type.rawValue,
//                                           coinId.expression <- item.coinId,
//                                           walletId.expression <- item.walletId,
//                                           timestamp.expression <- item.timestamp,
//                                           address.expression <- item.address,
//                                           amount.expression <- item.amount,
//                                           txHash.expression <- item.txHash,
//                                           isPending.expression <- item.isPending,
//                                           pid.expression <- item.currencyId,
//                                           chainId.expression <- Int64(item.chainType.rawValue)
//                                           )
//            return DBOperation(insert)
//        }
//        return commit(operations: inserts)
//    }
//    
//    func deleteAll(ofWallet wid: String) -> Observable<Bool> {
//
//        let filter = self.table.filter(walletId.expression == wid)
//        let operation = DBOperation(filter.delete())
//        return commit(operations: [operation])
//    }
//
//    func selectAll(ofWallet wid: String, page: Int, pageSize: Int) -> Observable<[TokenInfoTxInfo]> {
//        guard let db = connection else { return Observable.just([]) }
//
//        return Observable.create {[weak self] (subscriber) -> Disposable in
//            guard let this = self else { return Disposables.create() }
//
//            this.operationQueue.async {
//                do {
//
//                    let query = this.table
//                        .filter(walletId.expression == wid && isPending.expression == true)
//                        .order(timestamp.expression.desc)
//                        .limit(pageSize, offset: page * pageSize)
//                    
//                    let sql = query.asSQL().replacingOccurrences(of: "(_:_:)", with: "")
//                    let statement = try db.prepare(sql)
//
//                    var items: [TokenInfoTxInfo] = []
//                    for row in statement {
//                        let item = TokenInfoTxInfo()
//                        item.walletId = wid
//                        
//                        for (idx, name) in statement.columnNames.enumerated() {
//
//                            let v = row[idx]
//                            switch name {
//                            case type.name:
//                                item.type = TokenInfoTxInfo.Types(rawValue: type.value(v) ?? 0) ?? .invalid
//                            case coinId.name:
//                                item.coinId = coinId.value(v) ?? ""
//                            case timestamp.name:
//                                item.timestamp = timestamp.value(v) ?? 0
//                            case address.name:
//                                item.address = address.value(v) ?? ""
//                            case amount.name:
//                                item.amount = amount.value(v) ?? ""
//                            case txHash.name:
//                                item.txHash = txHash.value(v) ?? ""
//                            case isPending.name:
//                                item.isPending = isPending.value(v) ?? false
//                            case pid.name:
//                                item.currencyId = pid.value(v) ?? ""
//                            case chainId.name:
//                                item.chainType = Node.ChainType(rawValue: Int(chainId.value(v) ?? 0)) ?? .unknown
//                            default:continue
//                            }
//                        }
//                        item.syncIfNeed()
//                        items.append(item)
//                    }
//                    
//                    subscriber.onNext(items)
//                    subscriber.onCompleted()
//                } catch {
//                    subscriber.onNext([])
//                    subscriber.onCompleted()
//                }
//            }
//            return Disposables.create()
//        }
//    }
//    
//    
//    func selectAll(ofWallet wid: String) -> Observable<[TokenInfoTxInfo]>  {
//        guard let db = connection else { return Observable.just([]) }
//
//        return Observable.create {[weak self] (subscriber) -> Disposable in
//            guard let this = self else { return Disposables.create() }
//
//            this.operationQueue.async {
//                do {
//
////                    let query = this.table.filter(isPending.expression == false)
////                        .order(timestamp.expression.desc)
//                    let query = this.table
//                        .order(timestamp.expression.desc)
//                    
//                    let sql = query.asSQL().replacingOccurrences(of: "(_:_:)", with: "")
//                    let statement = try db.prepare(sql)
//
//                    var items: [TokenInfoTxInfo] = []
//                    for row in statement {
//                        let item = TokenInfoTxInfo()
//                        item.walletId = wid
//                        
//                        for (idx, name) in statement.columnNames.enumerated() {
//
//                            let v = row[idx]
//                            switch name {
//                            case type.name:
//                                item.type = TokenInfoTxInfo.Types(rawValue: type.value(v) ?? 0) ?? .invalid
//                            case coinId.name:
//                                item.coinId = coinId.value(v) ?? ""
//                            case timestamp.name:
//                                item.timestamp = timestamp.value(v) ?? 0
//                            case address.name:
//                                item.address = address.value(v) ?? ""
//                            case amount.name:
//                                item.amount = amount.value(v) ?? ""
//                            case txHash.name:
//                                item.txHash = txHash.value(v) ?? ""
//                            default:continue
//                            }
//                        }
//                        item.syncIfNeed()
//                        items.append(item)
//                    }
//                    
//                    subscriber.onNext(items)
//                    subscriber.onCompleted()
//                } catch {
//                    subscriber.onNext([])
//                    subscriber.onCompleted()
//                }
//            }
//            return Disposables.create()
//        }
//    }
//    
//    func pendingDone(ofWallet wid: String, hx: String ) -> Observable<Bool> {
//        let filter = self.table.filter(walletId.expression == wid && txHash.expression == hx)
//        let operation = DBOperation(filter.update(isPending.expression <- true))
//        return commit(operations: [operation])
//    }
//}
//
//enum RetryError: Error {
//    case errorNumber
//}
//
//struct TestRetryWhen {
//    
//    static let shared = TestRetryWhen()
//    
//    init() {
////        TokenInfoTxCache.shared.selectAll(ofWallet: <#T##String#>)
//    }
//    
//    private let bag = DisposeBag()
//    private static let retryETHDelay: Double = 3   // 多少秒重试一次
//    private static let retryBTCDelay: Double = 10   // 多少秒重试一次
//    
//    private let list:Dictionary<String,Observable<String>> = [:]
//    
//    func test() {
//        
//        let coin = Coin.ethereum
//        let token = TokenInfoTxInfo()
//        token.coin = coin
//        add(token)
//    }
//    
//    func addHxlist(tx: String, coin: Coin) {
//        
//        if coin.isETH || coin.isERC20 {
//            startRun(rxJson: ethSearch(tx: tx), tx: tx)
//        }
//         
//        if coin.isBTC {
//            startRun(rxJson: btcSearch(tx: "BTC Hash"), tx: tx)
//        }
//    }
//    
//    
//    func add(_ tokenInfo: TokenInfoTxInfo) {
//            
//        guard let coin = tokenInfo.coin else {
//            return
//        }
//        
//        if coin.isBTC {
//            startRun(rxJson: btcSearch(tx: "BTC Hash"), tx: tokenInfo.txHash)
//        }
//        
//        if coin.isETH || coin.isERC20 {
//            startRun(rxJson: ethSearch(tx: tokenInfo.txHash), tx: tokenInfo.txHash)
//        }
//    }
//    
//    func startRun(rxJson: Observable<JSON>, tx: String) {
//        rxJson.observeOn(MainScheduler.asyncInstance).flatMap { (rs) -> Observable<Bool> in
//            print("><><>>>>>>>>>", rs)
//            if rs.boolValue == true {
//                return  Observable.just(true)
//            } else {
//                return Observable.error(NSError(domain: "0", code: 0, userInfo: ["allowance":2]))
//            }
//        }.retryWhen({ (rxError) -> Observable<Int> in
//            return rxError.enumerated().flatMap({ (index, element) -> Observable<Int> in
//                print("交易状态查询",index)
////                if index >= 5 {
////                    let allowance = (element as NSError).userInfo
////                    return Observable.error(NSError(domain: TR("Swap.Error.Approve.Retry"), code: 0, userInfo: allowance))
////                }
//                return Observable.interval(2, scheduler: MainScheduler.instance)
//            })
//        })
//        .catchError({ (error) -> Observable<Bool> in
//            return Observable.just(false)
//        }).subscribe { (r) in
//            if let state = r.element {
//               // to do  发出通知
//                TokenInfoTxCache.shared.pendingDone(ofWallet: wallet?.id ?? "" , hx: tx).subscribe { (rs) in
//                    print("更新",rs)
//                }
//////              WKEvent.App.Send(event: WKEventType.TxSuccessNotes, info: tx)
////                t(hid: "")?.onNext("1")
//                
//            }
//        }.disposed(by: bag)
//    }
//    
//    func ethSearch(tx: String) -> Observable<JSON> {
//        let web3 = Web3(rpcURL: "https://kovan.infura.io/v3/6de321e61ef4469eb776fc59b622831d")
//        let data = EthereumData(bytes: Data(hex: tx).bytes)
//        return Observable.create { observer in
//            web3.eth.getTransactionReceipt(transactionHash:  data) { (res) in
//                guard let value  = res.result else {
//                    observer.onError(res.error ?? NSError(msg: "rpc requst failed"))
//                    return
//                }
//                observer.onNext(JSON.init(stringLiteral: value?.status?.quantity.description ?? ""))
//                observer.onCompleted()
//            }
//            return Disposables.create {}
//        }
//    }
//    
//    func btcSearch(tx: String) -> Observable<JSON> {
//        print("btcSearch")
//        return Observable.just(JSON.init(booleanLiteral: true))
//    }
//    
//    var wallet: WKWallet? {
//        guard let wallet = XWallet.sharedKeyStore.currentWallet?.wk else { return nil}
//        return wallet
//    }
//    
//    func save(result: JSON, of tx: FxTransaction) {
//        guard let wallet = XWallet.sharedKeyStore.currentWallet?.wk else { return }
//        let info = TokenInfoTxInfo()
//        info.walletId = wallet.id
//        info.coin = tx.coin
//        info.txHash = result["hash"].stringValue.addHexPrefix()
//        info.amount = tx.decimalAmount
//        info.address = tx.from.lowercased()
//        info.type = .transOut
//        info.chainType =  tx.coin.chainType
//        info.timestamp = result["time"].int64Value / 1000
//        info.isPending = false
//        
//        _ = TokenInfoTxCache.shared.insertOrReplace([info]).observeOn(MainScheduler.instance).subscribe()
//        
//        if  wallet.accounts(forCoin: tx.coin).addresses.contains(tx.to) {
//            let info = TokenInfoTxInfo()
//            info.walletId = wallet.id
//            info.coin = tx.coin
//            info.txHash = result["hash"].stringValue.addHexPrefix()
//            info.amount = tx.decimalAmount
//            info.address = tx.to.lowercased()
//            info.type = .transIn
//            info.chainType =  tx.coin.chainType
//            info.timestamp = result["time"].int64Value / 1000
//            info.isPending = false
//            _ = TokenInfoTxCache.shared.insertOrReplace([info]).observeOn(MainScheduler.instance).subscribe({ (rs) in
//                print("插入数据", rs)
//            })
//        }
//    }
//}
