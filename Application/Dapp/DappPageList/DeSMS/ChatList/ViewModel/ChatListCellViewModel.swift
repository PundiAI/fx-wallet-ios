//
//  ChatListCellViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX
import SwiftyJSON
import DateToolsSwift

extension ChatListViewController {
    class CellViewModel {
        
        let bag = DisposeBag()
        let rawValue: SmsUser
        
        let unreadKey: String
        let latestMsgKey: String
        
        var latestMsgHeight: UInt64 = 0
        private var online = false
        private(set) var latestSms: SmsMessage?
        
        private(set) var nameText = ""
        let badge = BehaviorRelay<Int>(value: 0)
        let msgText = BehaviorRelay<String>(value: "")
        let dateText = BehaviorRelay<String>(value: "")
        let avatarUrl = BehaviorRelay<String>(value: "")
        
        init(_ user: SmsUser) {
            self.rawValue = user
            self.unreadKey = (user.chatRoomId + user.address).md5()
            self.latestMsgKey = "latestMsg_" + self.unreadKey
            
            setup()
            fetchUnreadCount()
        }
        
        private func setup() {
            
            let cache = self.cache
            self.nameText = rawValue.name
            if let msg = cache["msg"] { self.msgText.accept(msg) }
            if let date = cache["date"] { self.dateText.accept(date) }
        }
        
        func accept(_ sms: SmsMessage) {
            self.latestSms = sms
            
            let msg = sms.message.transferTokens.isEmpty ? sms.message.content : "[ gift ]"
            self.msgText.accept(msg)
            self.dateText.accept(Date(timeIntervalSince1970: sms.availableTimestamp).format(with: "HH:mm"))
            self.cache = ["msg": msg, "date": dateText.value]
            
            if sms.txHeight > latestMsgHeight {
                
                if latestMsgHeight > 0, !online, sms.sendingHeight == 0 {
                    self.badge.accept(self.badge.value + 1)
                }
                latestMsgHeight = sms.txHeight
            }
        }
        
        func readToEnd(_ latestSms: SmsMessage? = nil) {
            self.badge.accept(0)
            
            self.online = latestSms == nil
            if let sms = latestSms {
                latestMsgHeight = max(sms.txHeight, latestMsgHeight)
            }
            if latestMsgHeight > 0 {
                UserDefaults.standard.set(latestMsgHeight, forKey: unreadKey)
            }
        }
        
        func updateUnreadCountIfNeed() {
            guard !online, latestSms?.isToday == true else { return }
            
            fetchUnreadCount()
        }
        
        private func fetchUnreadCount() {
            
            let lastUnreadHeight = UInt64(UserDefaults.standard.integer(forKey: unreadKey))
            guard lastUnreadHeight > 0 else { return }
            
            let location = SmsChatLocation(groupId: rawValue.chatRoomId, lastMsgHeight: lastUnreadHeight)
            FunctionX.shared.sms.msgCount(ofSender: rawValue.address, location: location).subscribe(onNext: { [weak self](badge) in
                if badge > 0 {
                    self?.badge.accept(Int(badge))
                }
            }).disposed(by: bag)
        }
        
        private var cache: [String: String] {
            set { UserDefaults.standard.set(newValue, forKey: latestMsgKey) }
            get { return UserDefaults.standard.object(forKey: latestMsgKey) as? [String: String] ?? [:] }
        }
    }
}
