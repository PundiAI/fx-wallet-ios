//
//  SmsService.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX
import SwiftyJSON
import TrustWalletCore

private var SharedSMSSocket: FxWebSocketClient { FunctionX.shared.sms.websocket }

class SmsServiceManager {
    
    fileprivate static var services: [String: SmsService] = [:]
    static func service(forWallet wallet: FxWallet) -> SmsService {
        
        var service = services[wallet.address]
        if service == nil {
            
            service = SmsService(wallet: wallet)
            services[wallet.address] = service!
        }
        
        return service!
    }
    
    static func service(forWallet wallet: FxWallet, receiver: SmsUser) -> SmsMessageService {
        return service(forWallet: wallet).messageService(with: receiver)
    }
}






//MARK: SmsService
typealias SMSChatListCellViewModel = ChatListViewController.CellViewModel
class SmsService {
    
    init(wallet: FxWallet) {
        self.fx = FunctionX(wallet: wallet)
        bindSocket()
    }
    
    let fx: FunctionX
    var wallet: FxWallet { fx.sms.wallet! }
    var address: String { wallet.address }
    
    private var socketBag = DisposeBag()
    private var defaultBag = DisposeBag()
    private lazy var smsParser = SmsMessageParser(privateKey: wallet.privateKey)
    
    private(set) var name = ""
    private(set) lazy var fetchName: APIAction<String> = {
    
        let address = self.address
        let s: Observable<String>
        if let name = UserDefaults.nameOnSMS(ofAddress: address) {
            s = Observable.just(name)
            self.name = name
        } else {
            s = fx.sms.name(ofAddress: address)
                .do(onNext: { [weak self] (n) in
                    self?.name = n
                    UserDefaults.set(nameOnSMS: n, ofAddress: address)
                })
        }
        return APIAction(s)
    }()
    
    private lazy var cache = SmsContactListCache.shared
    private var contactMap: [String: SMSChatListCellViewModel] = [:]
    private var contactList: [SMSChatListCellViewModel] = []
    private(set) var didUpdate = PublishSubject<Bool>()
    
    private var receivedMsgs: [String: SmsMessage] = [:]
    private var receivedNewMsgs: [String: SmsMessage] = [:]
    
    private var messageServices: [String: SmsMessageService] = [:]
    fileprivate func messageService(with receiver: SmsUser) -> SmsMessageService {
        
        let groupId = receiver.chatRoomId
        var service = messageServices[groupId]
        if service == nil {
            service = SmsMessageService(receiver: receiver, wallet: self.wallet)
            messageServices[groupId] = service!
            bind(service!)
        }
        return service!
    }
    
    func latestContactList() -> [SMSChatListCellViewModel] { return contactList }
    func preload() -> Observable<[SMSChatListCellViewModel]> {
        guard contactList.isEmpty else { return Observable.just(contactList) }
        
        return self.cache.selectAll(ofUser: self.address).map{ [weak self] caches in
            self?.filterMerge(caches, isFromCache: true)
            return self?.contactList ?? []
        }
    }
    
    //MARK: Main
    private func bind(_ service: SmsMessageService) {
        
        weak var welf = self
        service.didSend.subscribe(onNext: { (sms) in
            welf?.receivedMsgs[sms.message.toAddress] = sms
            welf?.dispatchAllSms(true)
        }).disposed(by: defaultBag)
        
        
        service.isOnline.skip(1).subscribe(onNext: { (isOnline) in
            guard let this = welf else { return }
            if !isOnline,
                let item = this.contactMap[service.receiver.address],
                let lastMsg = service.latestSuccessMsg() {
                item.readToEnd(lastMsg)
            }
        }).disposed(by: defaultBag)
    }
    
    @discardableResult
    private func filterMerge(_ users: [SmsUser], isFromCache: Bool = false) -> [SmsUser] {
        
        var newContact: [SmsUser] = []
        for user in users {
            if contactMap[user.address] == nil {
                newContact.append(user)
            }
        }
        if !isFromCache, newContact.isNotEmpty {
            _ = self.cache.insertOrReplace(newContact, ofUser: self.address).subscribe()
        }
        
        for (idx, user) in newContact.enumerated() {
            
            let item = SMSChatListCellViewModel(user)
            contactList.insert(item, at: idx)
            contactMap[user.address] = item
        }
        
        fetchLatestSmsIfNeed()
        dispatchAllSms()
        let needSort = sort()
        
        onUpdate(needSort || newContact.isNotEmpty)
        return newContact
    }
    
    //MARK: HTTP
    lazy var refreshContactList: APIAction<[SMSChatListCellViewModel]> = Action { [weak self](_) -> Observable<[SMSChatListCellViewModel]> in
        guard let this = self else { return Observable.empty() }

        return this.fx.sms.contactList(ofAddress: this.wallet.address).map { users in
            
            this.filterMerge(users.map{ SmsUser.instance(fromChatList: $0) })
            return this.contactList
        }
    }
    
    private func fetchLatestSmsIfNeed() {
        guard contactList.count > 0 else { return }
        
        weak var welf = self
        let locations: [SmsChatLocation] = contactList.map {
            SmsChatLocation(groupId: $0.rawValue.chatRoomId, lastMsgHeight: $0.latestSms?.txHeight ?? 0)
        }
        
        let fetchLatestSms = fx.sms.newMsgCount(ofLocations: locations)
            .flatMap{ items -> Observable<[UInt64]> in
                
                var heights: [UInt64] = []
                for item in items {
                    
                    if item["last_block"].uInt64Value > 0 {
                        heights.append(item["last_block"].uInt64Value)
                    }
                }
                return heights.isNotEmpty ? Observable.just(heights) : Observable.error(WKError.noData)
        }
        .flatMap{ result -> Observable<[JSON]> in
            guard let this = welf else { return Observable.empty() }

            let tasks: [Observable<JSON>] = result.map { this.fetchBlock(at: $0) }
            return Observable.combineLatest(tasks)
        }
        
        fetchLatestSms.subscribe(onNext: { (v) in
            welf?.sort(true)
        }).disposed(by: defaultBag)
    }
    
    private func fetchBlock(at height: UInt64) -> Observable<JSON> {
        let myAddress = wallet.address
        return fx.sms.block(at: height)
            .do(onNext: { [weak self] (result) in
                guard let this = self,
                    let sms = this.smsParser.sms(fromBlock: result) else { return }
                
                let key = sms.message.fromAddress == myAddress ? sms.message.toAddress : sms.message.fromAddress
                this.receivedMsgs[key] = sms
                this.contactMap[key]?.accept(sms)
        })
    }
    
    //MARK: Websocket
    func online() {
//        bindSocket()
    }
    
    func offline() {
        
//        self.socketBag = DisposeBag()
//        _ = SharedSMSSocket.unsubscribe(FxWSPredicate(receiveSms: wallet.address)).subscribe()
    }
    
    private func bindSocket() {
        
        let bag = socketBag
        let socket = SharedSMSSocket
        let address = wallet.address
        
        weak var welf = self
        socket.isConnected
            .filter{$0}
            .subscribe(onNext: { (_) in
            
                let predicate = FxWSPredicate(receiveSms: address)
                socket.subscribe(predicate).subscribe().disposed(by: bag)
        }).disposed(by: bag)
        
        socket.notification.subscribe(onNext: { (notif) in
            guard let this = welf,
                let sms = this.smsParser.sms(fromTx: notif.data["value", "TxResult"]),
                sms.message.toAddress == address else { return }
            
            sms.txHash = notif.rawValue?["result", "events", "tx.hash", 0].stringValue ?? ""
            sms.estimateConfirmTime()
            this.dispatchSmsIfNeed(sms)
        }).disposed(by: bag)
        
        socket.connect()
    }
    
    //MARK: dispatch SMS
    private func dispatchSmsIfNeed(_ sms: SmsMessage) {
        
        let senderAddress = sms.message.fromAddress
        receivedMsgs[senderAddress] = sms
        receivedNewMsgs[senderAddress] = sms
        if contactMap[senderAddress] == nil {
            self.refreshContactList.execute()
        } else {
            dispatchAllSms()
        }
    }
    
    private func dispatchAllSms(_ forceSort: Bool = false) {
        
        let needSort = forceSort || receivedNewMsgs.count > 0
        for (senderAddress, sms) in receivedMsgs {
            
            let updateTime = contactMap[senderAddress]?.latestSms?.availableTimestamp ?? 0
            if updateTime != sms.availableTimestamp {
                contactMap[senderAddress]?.accept(sms)
            }
        }
        
        for (senderAddress, sms) in receivedNewMsgs {
            if let sender = contactMap[senderAddress] {
                messageService(with: sender.rawValue).didReceive(sms: sms)
            }
        }
        receivedNewMsgs.removeAll()
        
        if needSort { self.sort(true) }
    }
    
    //MARK: Utils
    
    private func onUpdate(_ flag: Bool) {
        guard flag else { return }
        didUpdate.onNext(true)
    }
    
    @discardableResult
    private func sort(_ sendEvent: Bool = false) -> Bool {
        
        let shouldSort = contactList.last?.latestSms?.availableTimestamp != nil
        if shouldSort {
            
            let sorted = contactList.sorted { ($0.latestSms?.availableTimestamp ?? 0) >= ($1.latestSms?.availableTimestamp ?? 0) }
            contactList = sorted
            onUpdate(sendEvent)
        }
        return shouldSort
    }
}















//MARK: SmsMessageService
typealias SMSChatCellViewModel = ChatViewController.CellViewModel
class SmsMessageService {
    
    class PageRecorder {
        
        let id: String
        init(_ id: String) {
            self.id = id
            self.minHeight = UserDefaults.standard.object(forKey: minHeightKey) as? UInt64
        }
        
        fileprivate var pageSize = 20
        fileprivate var maxHeight: UInt64 = 0
        
        private var minHeightKey: String { "smsMinHeight_\(id)" }
        fileprivate var minHeight: UInt64? {
            didSet {
                if let height = minHeight, height > 0 {
                    UserDefaults.standard.set(height, forKey: minHeightKey)
                }
            }
        }
        
        fileprivate var nextSortHeight: UInt64 = 0
        fileprivate var nextTxHeight: UInt64 = 0
        
        var hasMore: Bool {
            guard let min = minHeight else { return true }
            
            return nextSortHeight != SmsMessage.sortHeight(by: min)
        }
    }
    
    init(receiver: SmsUser, wallet: FxWallet) {
        self.fx = FunctionX(wallet: wallet)
        self.receiver = receiver
        bindWillSend()
    }
    
    let fx: FunctionX
    let receiver: SmsUser
    
    var roomId: String { receiver.chatRoomId }
    var wallet: FxWallet { fx.sms.wallet! }
    
    private lazy var parser = SmsMessageParser(privateKey: wallet.privateKey)
    private lazy var pager = PageRecorder(roomId)
    var pageSize: Int {
        set { pager.pageSize = newValue }
        get { return pager.pageSize }
    }
    
    private let lock = DispatchSemaphore(value: 1)
    private lazy var cache = SmsMessageCache.shared
    private var messages: [SMSChatCellViewModel] = []
    private var sendingMessages: [UInt64: SMSChatCellViewModel] = [:]
    
    let bag = DisposeBag()
    let didSend = PublishSubject<SmsMessage>()
    let didUpdate = PublishSubject<([SMSChatCellViewModel]?, [SMSChatCellViewModel]?)>()
    
    let isOnline = BehaviorRelay<Bool>(value: false)
    
    func offline() {
        
        atomic {
            if self.messages.count > 50 {
                self.messages = self.latest(50)
            }
        }
        isOnline.accept(false)
    }
    
    //MARK: Send/Delete/Receive Message
    func send(sms content: String, transferTokens: [TransactionMessage.Coin] = []) -> Observable<JSON> {
        
        let rawMsg = SmsMessage()
        rawMsg.type = transferTokens.count == 0 ? .sendText : .sendGift
        rawMsg.status = .sending
        rawMsg.txGroupId = roomId
        rawMsg.receiveName = receiver.name
        rawMsg.sendingHeight = (messages.last?.sortHeight ?? 0) + 1
        rawMsg.sendingSequence = wallet.sequence
        rawMsg.message.content = content
        rawMsg.message.toAddress = receiver.address
        rawMsg.message.fromAddress = wallet.address
        rawMsg.message.toPublicKey = receiver.publicKey
        rawMsg.message.fromPublicKey = wallet.publicKey.compressed.data
        rawMsg.message.transferTokens = transferTokens
        rawMsg.estimateConfirmTime()
        
        let sms = SMSChatCellViewModel.instance(rawMsg)
        weak var welf = self
        return fx.sms.sendSms(toPK: receiver.publicKey, content: content, transferTokens: transferTokens, fee: "1", gas: 80000)
            .do(onNext: { welf?.didSend(sms: sms, $0) },
                onError: { _ in welf?.didSend(sms: sms, nil) },
                onSubscribe: {
                    
                    welf?.sendingMessages[rawMsg.sendingHeight] = sms
                    welf?.filterMerge([sms])
                    welf?.didUpdate.onNext(([sms], nil))
            })
    }
    
    func resend(sms: SMSChatCellViewModel) -> Observable<JSON> {
        sms.update(status: .sending)
        sms.rawValue.sendingSequence = wallet.sequence
        
        weak var welf = self
        let message = sms.rawValue.message
        return fx.sms.sendSms(toPK: receiver.publicKey, content: message.content, transferTokens: message.transferTokens, fee: "1", gas: 80000)
            .do(onNext: { welf?.didSend(sms: sms, isResend:true, $0) },
                onError: { _ in welf?.didSend(sms: sms, isResend:true ,nil) })
    }
    
    private func bindWillSend() {
        
        fx.sms.willBroadcastTx.subscribe(onNext: { [weak self](t) in
            guard let this = self else { return }
            
            if this.sendingMessages.count == 1 {
                this.sendingMessages.first?.value.rawValue.message.encryptedContent = t.tx.smsSend?.encryptedContent ?? ""
            } else {
                
                for (_, sms) in this.sendingMessages {
                    if sms.rawValue.sendingSequence == t.sequence {
                        sms.rawValue.message.encryptedContent = t.tx.smsSend?.encryptedContent ?? ""
                        break
                    }
                }
            }
        }).disposed(by: bag)
    }
    
    private func didSend(sms: SMSChatCellViewModel, isResend: Bool = false, _ result: JSON?) {
        sendingMessages[sms.rawValue.sendingHeight] = nil
        
        //save only the send failed items for render
        sms.rawValue.estimateConfirmTime(true)
        if result == nil {
            
            sms.update(status: .failed)
            _ = cache.insertOrReplace([sms.rawValue]).subscribe()
        } else {
            
            if let idx = messages.lastIndexOf(condition: { $0.rawValue.status == .sending && $0.id == sms.id }) {
                atomic {
                    self.messages.remove(at: idx)
                }
            }
            
            let delSms = SmsMessage()
            delSms.txGroupId = sms.rawValue.txGroupId
            delSms.sendingHeight = sms.rawValue.sendingHeight
            
            if isResend {
                _ = cache.delete([delSms]).subscribe()
            }
            sms.update(status: .successed)
            sms.rawValue.txHash = result!["hash"].stringValue
            sms.rawValue.txHeight = result!["height"].uInt64Value
//            save(successSms: sms.rawValue)
            
            filterMerge([sms])
            didUpdate.onNext(([sms], [SMSChatCellViewModel.instance(delSms)]))
        }
        didSend.onNext(sms.rawValue)
    }
    
    fileprivate func didReceive(sms: SmsMessage) {
        
        sms.type = sms.message.transferTokens.count > 0 ? .receiveGift : .receiveText
        sms.status = .successed
        sms.txGroupId = roomId
        sms.receiveName = receiver.name
        let receivedMessages = [SMSChatCellViewModel.instance(sms)]
        let (newMessages, _, _) = filterMerge(receivedMessages)
        if newMessages.isNotEmpty {
            didUpdate.onNext((newMessages, nil))
//            save(successSms: sms)
        }
    }
    
    fileprivate func save(successSms sms: SmsMessage) {
        guard sms.isSuccessed,
            sms.txHeight > 0,
            sms.txHash.isNotEmpty,
            sms.txGroupId.isNotEmpty else {
            return
        }
        
        fx.sms.block(at: sms.txHeight).subscribe(onNext: { [weak self](result) in
            sms.confirmTime = result["block_meta", "header", "time"].stringValue
            _ = self?.cache.insertOrReplace([sms]).subscribe()
        }).disposed(by: bag)
    }
    
    //MARK: Load Message
    func preload() -> Observable<[SMSChatCellViewModel]> {
        guard messages.isEmpty else { return Observable.just(latest(pageSize)) }
        
        return selectMessages(fromHeight: UInt64(INT64_MAX), pageSize: pageSize).flatMap{ caches -> Observable<[SMSChatCellViewModel]> in
            
            self.filterMerge(caches.reversed())
            return self.latest(self.pageSize)
        }
    }
    
    func loadLatest(_ count: Int = 0) -> Observable<[SMSChatCellViewModel]> {
        
        let itemCount = count > 0 ? count : pageSize
        let isFirstPage = count == 0
        
        let loader = isFirstPage ? refreshMessages() : loadMoreMessages()
        return loader.flatMap { [weak self] _ -> Observable<[SMSChatCellViewModel]> in
            guard let this = self else { return Observable.empty() }
            return this.latest(itemCount, sendError: true)
        }
    }
    
    fileprivate func latestSuccessMsg() -> SmsMessage? {
        return messages.last{ $0.rawValue.isSuccessed }?.rawValue
    }
    
    private func latest(_ count: Int = 20) -> [SMSChatCellViewModel] {
        guard messages.isNotEmpty else { return [] }
        
        let end = messages.count
        let start = max(0, messages.count - count)
        return messages[start..<end]
    }
    
    private func latest(_ count: Int = 20, sendError: Bool = false) -> Observable<[SMSChatCellViewModel]> {
        
        let result = latest(count)
        if result.count > 0 || !sendError {
            return Observable.just(result)
        } else {
            return noDataError(count == 0)
        }
    }
    
    //MARK: HTTP
    private func refreshMessages(direction: Bool = false) -> Observable<[SMSChatCellViewModel]> {
        return fetchMessages(fromHeight: 0, direction: direction, pageSize: pageSize)
    }
    
    private func loadMoreMessages(direction: Bool = false) -> Observable<[SMSChatCellViewModel]> {
        guard messages.isNotEmpty, pager.hasMore else { return Observable.error(WKError.noMoreData) }
        
        let loader = selectMessages(fromHeight: pager.nextSortHeight, pageSize: pageSize).flatMap{ [weak self] caches -> Observable<[SMSChatCellViewModel]> in
            guard let this = self else { return Observable.empty() }
            
            let cacheIsAvailable = this.handle(cacheItems: caches)
            if cacheIsAvailable {
                return Observable.just(caches)
            } else {
                return this.fetchMessages(fromHeight: this.pager.nextTxHeight, direction: direction, pageSize: this.pageSize)
            }
        }
        
        return loader
    }

    private func fetchMessages(fromHeight height: UInt64, direction: Bool = false, pageSize: Int = 20) -> Observable<[SMSChatCellViewModel]> {

        weak var welf = self
        let myAddress = wallet.address
        let isFirstPage = height == 0
        return fx.sms.msgBlockList(ofGroupId: roomId, fromHeight: height, direction: direction, pageSize: pageSize)
            .flatMap{ result -> Observable<[SMSChatCellViewModel]> in
                guard let this = welf else { return Observable.empty() }
                
                if isFirstPage {
                    this.pager.minHeight = result["min_block"].uInt64Value
                    this.pager.maxHeight = result["max_block"].uInt64Value
                }
                
                var nextTxHeight = height
                var items: [SMSChatCellViewModel] = []
                for block in result["blocks"].arrayValue {
                    guard let sms = this.parser.sms(fromTx: block["txs", 0]) else { continue }
                    
                    sms.confirmTime = block["time"].stringValue
                    sms.deriveType(by: myAddress)
                    sms.txGroupId = this.roomId
                    sms.receiveName = this.receiver.name

                    sms.nextTxHeight = nextTxHeight > sms.txHeight ? nextTxHeight : sms.txHeight
                    nextTxHeight = sms.txHeight
                    
                    items.append(SMSChatCellViewModel.instance(sms))
                }
                if items.count == 0 { return this.noDataError(isFirstPage) }
                
                this.handle(items: items)
                return Observable.just(items)
        }
    }
    
    private func selectMessages(fromHeight height: UInt64, pageSize: Int = 20) -> Observable<[SMSChatCellViewModel]> {

        weak var welf = self
        let myAddress = wallet.address
        return cache.select(ofGroupId: roomId, fromHeight: height, direction: false, pageSize: pageSize).flatMap{ caches -> Observable<[SMSChatCellViewModel]> in
            guard let this = welf else { return Observable.empty() }
            
            if caches.count == pageSize || caches.last?.txHeight == this.pager.minHeight {
                
                return Observable.just(caches.map{
                    $0.receiveName = this.receiver.name
                    $0.deriveType(by: myAddress)
                    return SMSChatCellViewModel.instance($0)
                })
            }
            
            return Observable.just([])
        }
    }
    
    //MARK: Utils
    
    private func handle(items: [SMSChatCellViewModel]) {
        
        let appendItems: [SMSChatCellViewModel] = items.reversed()
        let (_, _, updateMsgs) = filterMerge(appendItems)

        let minHeight = appendItems.first?.txHeight ?? 0
        pager.nextTxHeight = minHeight
        pager.nextSortHeight = SmsMessage.sortHeight(by: minHeight)
        if updateMsgs.isNotEmpty {
            _ = self.cache.insertOrReplace(updateMsgs).subscribe()
        }
    }
    
    private func handle(cacheItems items: [SMSChatCellViewModel]) -> Bool {
        
        let (serialItems, nextTxHeight, nextSortHeight) = checkIsSerial(items)
        if serialItems.count >= pageSize - 5 || serialItems.last?.txHeight == pager.minHeight {
            
            _ = filterMerge(serialItems.reversed())
            pager.nextTxHeight = nextTxHeight
            pager.nextSortHeight = nextSortHeight
            return true
        }
        
        return false
    }
    
    private func checkIsSerial(_ items: [SMSChatCellViewModel]) -> ([SMSChatCellViewModel], UInt64, UInt64) {
        
        var serialItems: [SMSChatCellViewModel] = []
        var nextTxHeight = pager.nextTxHeight
        var nextSortHeight = pager.nextSortHeight
        var nextItemTxHeight = pager.nextTxHeight
        
        for item in items {
            if !item.rawValue.isSuccessed {
                
                serialItems.append(item)
                nextSortHeight = item.sortHeight
            } else if item.rawValue.nextTxHeight == nextItemTxHeight {
                
                serialItems.append(item)
                nextTxHeight = item.txHeight
                nextSortHeight = item.sortHeight
                nextItemTxHeight = item.txHeight
            } else { break }
        }
        
        return (serialItems, nextTxHeight, nextSortHeight)
    }
    
    private func atomic( operation: () -> () ) {
        
        lock.wait()
        operation()
        lock.signal()
    }

    @discardableResult
    private func filterMerge(_ appendItems: [SMSChatCellViewModel], needSort: Bool = false) -> ([SMSChatCellViewModel], [SmsMessage], [SmsMessage]) {
        if appendItems.isEmpty { return ([], [], []) }

        var appendItems = appendItems
        let currentItems = messages
        if needSort {
            appendItems = appendItems.sorted{ return $0.sortHeight <= $1.sortHeight }
        }

        var i = 0
        var j = 0
        var newMsgs: [SmsMessage] = []
        var updateMsgs: [SmsMessage] = []
        var newItems: [SMSChatCellViewModel] = []
        var mergedItems: [SMSChatCellViewModel] = []
        while i < currentItems.count && j < appendItems.count {

            var item: SMSChatCellViewModel
            var newItem: SMSChatCellViewModel?
            if currentItems[i].sortHeight < appendItems[j].sortHeight {

                item = currentItems[i]
                i += 1
            } else if currentItems[i].sortHeight > appendItems[j].sortHeight {

                item = appendItems[j]
                newItem = item
                j += 1
            } else {

                item = currentItems[i]
                if !item.hasNext && appendItems[j].hasNext {

                    item = appendItems[j]
                    if updateMsgs.last?.id != item.id {
                        updateMsgs.append(item.rawValue)
                    }
                }

                i += 1
                j += 1
            }

            if mergedItems.last?.id != item.id {
                mergedItems.append(item)

                if let new = newItem {
                    newItems.append(new)
                    newMsgs.append(new.rawValue)
                    if updateMsgs.last?.id != item.id {
                        updateMsgs.append(new.rawValue)
                    }
                }
            }
        }

        while i < currentItems.count {

            let item = currentItems[i]
            if mergedItems.last?.id != item.id {
                mergedItems.append(item)
            }
            i += 1
        }

        while j < appendItems.count {

            let item = appendItems[j]
            if mergedItems.last?.id != item.id {

                mergedItems.append(item)
                newItems.append(item)
                newMsgs.append(item.rawValue)
                if updateMsgs.last?.id != item.id {
                    updateMsgs.append(item.rawValue)
                }
            }
            j += 1
        }

        atomic {
            self.messages = mergedItems
        }
        return (newItems, newMsgs, updateMsgs)
    }
    
    fileprivate func noDataError(_ isFirstPage: Bool = true) -> Observable<[SMSChatCellViewModel]> {
        return Observable.error(isFirstPage ? WKError.noData : WKError.noMoreData)
    }
}
