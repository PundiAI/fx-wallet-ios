//
//  ChatViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX

extension ChatViewController {
    
    class ViewModel: WKListViewModel<CellViewModel> {
            
        let service: SmsMessageService
        var wallet: FxWallet { service.wallet }
        var address: String { wallet.address }
        
        private(set) var needReload = PublishSubject<Bool>()
        lazy var firstLoadFinished = BehaviorRelay<Bool>(value: false)
        
        lazy var lastUpdateDate = BehaviorRelay<String>(value: TR("Chat.LastUpdate$", "--"))
        
        deinit { self.service.offline() }
        init(receiver: SmsUser, wallet: FxWallet) {
            self.service = SmsServiceManager.service(forWallet: wallet, receiver: receiver)
            super.init()
            
            setupList()
            bindService()
        }
        
        private func setupList() {
            
            self.pager.page = 0
            self.pager.pageSize = 20
            self.service.pageSize = self.pager.pageSize
            self.refreshItems = Action { [weak self] _ -> Observable<[CellViewModel]> in
                guard let this = self else { return Observable.empty() }
                
                return this.service.loadLatest(this.pager.page)
                    .observeOn(MainScheduler.instance)
                    .do(onNext: { (items) in
                        
                        this.handle(items)
                        this.pager.page = items.count + this.pager.pageSize
                        this.fetchLastUpdateDate()
                        if !this.firstLoadFinished.value {
                            this.firstLoadFinished.accept(items.count > 0)
                        }
                    })
            }
            
            self.service.preload()
                .filter{ $0.isNotEmpty }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (items) in
                    
                    self?.handle(items)
                    self?.needReload.onNext(true)
                    self?.firstLoadFinished.accept(true)
            }).disposed(by: defaultBag)
        }
        
        private func bindService() {
            
            service.didUpdate.subscribe(onNext: {[weak self] (updateMsgs) in
                guard let this = self else { return }
                
                let (new, del) = updateMsgs
                if let delItems = del, delItems.isNotEmpty {
                    
                    for item in delItems {
                        if let idx = this.items.lastIndexOf(condition: { $0.rawValue.sendingHeight == item.rawValue.sendingHeight }) {
                            this.items.remove(at: idx)
                        }
                    }
                }
                
                if let newItems = new, newItems.isNotEmpty {
                    this.items.append(contentsOf: newItems)
                }
                this.needReload.onNext(true)
                this.fetchLastUpdateDate()
            }).disposed(by: defaultBag)
        }
        
        private func fetchLastUpdateDate() {
            
//            let receiverAddress = service.receiver.address
//            if let sms = items.lastObjectOf(condition: { $0.rawValue.message.fromAddress == receiverAddress }) {
//                lastUpdateDate.accept(TR("Chat.LastUpdate$", sms.rawValue.availableTime))
//            }
            
            if let sms = items.last {
                lastUpdateDate.accept(TR("Chat.LastUpdate$", sms.rawValue.availableTime))
            }
        }
        
        private func handle(_ items: [CellViewModel]) {
            guard items.isNotEmpty else { return }
            
            var compareItem = items.first!
            if compareItem.isToday {
                self.items = items
            } else {
                
                var temp: [CellViewModel] = [DateCellViewModel(compareItem.rawValue)]
                for item in items {
                    
                    if !compareItem.isToday, !compareItem.date.isSameDay(date: item.date) {
                        temp.append(DateCellViewModel(item.rawValue))
                        compareItem = item
                    }
                    temp.append(item)
                }
                self.items = temp
            }
        }
        
    }
    
}
