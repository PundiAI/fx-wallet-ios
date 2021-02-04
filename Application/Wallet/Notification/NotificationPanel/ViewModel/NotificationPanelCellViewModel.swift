//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import DateToolsSwift
import SwiftDate

extension NotificationPanelViewController {
    
    class CellViewModel {
        
        let rawValue: FxNotification
        var coin: Coin? { rawValue.coin }
        
        var size: CGSize = .zero
        var contentHeight: CGFloat = 0
        
        var showAddToken = false
        
        var dateText = ""
        var message: NSAttributedString?
        
        init(_ rawValue: FxNotification) {
            rawValue.recoverAccount()
            self.rawValue = rawValue
            if let coin = rawValue.coin { 
                self.showAddToken = XWallet.currentWallet?.wk.coinManager.has(coin) == false
            }
            
            self.formatMsg()
            self.formatDate()
            self.calculateSize()
        }
        
        func didAddCoin() {
            guard self.showAddToken else { return }
            
            self.showAddToken = false
            self.calculateSize()
        }
        
        var titleMsg: String {
            return rawValue.type == 0 ? TR("System") : TR("Transfer")
        }
        
        var msgIcon: UIImage? {
            return rawValue.type == 0 ? IMG("Notify.System") : IMG("Notify.Trans")
        }
        
        var isTransfer : Bool {
            return rawValue.type == 1
        }
        
        private func formatMsg() { 
            let text = rawValue.message
            let link = rawValue.urlText
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 14), .foregroundColor: COLOR.title])
            if link.isNotEmpty, let range = text.range(of: link) {
                attText.addAttributes([.foregroundColor: HDA(0x0552DC),
                                       .underlineColor: HDA(0x0552DC),
                                       .underlineStyle: NSUnderlineStyle.single.rawValue], range: text.convert(range: range))
            }
            self.message = attText
        }
        
        private func formatDate() {
            let local = Locale(identifier: WKLocale.Shared.localeIdentifier)
            self.dateText = Date(timeIntervalSince1970: Double(rawValue.timestamp)).format(with: "MMM dd HH:mm", locale: local)
        }
        
        private func calculateSize() {
            
            let width = ScreenWidth - (24.auto() * 2)
            if coin == nil || !showAddToken {
                let height = message!.string.heightWithConstrainedWidth(width: width, font: XWallet.Font(ofSize: 14))
                if isTransfer {
                    self.contentHeight = 24.auto() + 32.auto() + 28.auto() + 28.auto() + max(10.auto(), height) + 32.auto()
                } else {
                    self.contentHeight = 24.auto() + 32.auto() + 28.auto() + max(10.auto(), height) + 32.auto()
                }
                self.size = CGSize(width: width, height: contentHeight)
            } else {
                
                let height = message!.string.heightWithConstrainedWidth(width: ScreenWidth - (24 + 96).auto(), font: XWallet.Font(ofSize: 14))
                let noticeHeight = TR("Notif.AddTokenNotice$", coin!.token).heightWithConstrainedWidth(width: width, font: XWallet.Font(ofSize: 14, weight: .medium))
                self.contentHeight = 24.auto() + 32.auto() + 28.auto() + 28.auto() + max(10.auto(), height) + 32.auto()
                self.size = CGSize(width: width, height: contentHeight + (noticeHeight + (16 * 2 + 56 + 24).auto()))
            }
        }
    }
}
        


