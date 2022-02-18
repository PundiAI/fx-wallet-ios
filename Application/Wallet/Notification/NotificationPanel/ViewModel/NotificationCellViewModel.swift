

import WKKit
import RxSwift
import RxCocoa
import DateToolsSwift
import SwiftDate
 
extension NotificationPanelViewController {
    class CellViewModel {
        var _contentSize: CGSize?
        var _messageSize: CGSize?  
        
        let rawValue: FxNotification
        var coin: Coin? { rawValue.coin }
        var showAddToken = false
        
        var dateText = ""
        var message: NSAttributedString?
        
        init(_ rawValue: FxNotification) {
            rawValue.recoverAccount()
            self.rawValue = rawValue
            if let coin = rawValue.coin { 
                self.showAddToken = XWallet.currentWallet?.wk.coinManager.has(coin) == false
                
                let noteChainType = NodeManager.shared.currentEthereumNode.chainType
                if let chainType = rawValue.chainType {
                    if self.showAddToken == true && noteChainType != chainType {
                        self.showAddToken = false
                    }
                }
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
            switch rawValue.notiType {
            case .backup, .system:
                return TR("System")
            case .transfer, .failureTransfer, .crossFailureTransfer:
                return TR("Transfer")
            default:
                return TR("System")
            }
        }
        
        var msgIcon: UIImage? {
            switch rawValue.notiType {
            case .backup,.system:
                return IMG("Notify.System")
            case .transfer, .failureTransfer:
                return IMG("Notify.Trans")
            default:
                return IMG("Notify.System")
            }
        }
        
        var isTransfer : Bool {
            return rawValue.notiType == .transfer
        }
        
        var isPendingTransfer : Bool {
            return rawValue.notiType == .pendingTransfer ||
                   rawValue.notiType == .crossPendingTransfer
        }
        
        private func formatMsg() { 
            let text = rawValue.message
            let link = rawValue.urlText
            let paraph = NSMutableParagraphStyle().then { $0.lineSpacing = 4 }
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 14),
                                                                               .paragraphStyle: paraph,
                                                                               .foregroundColor: COLOR.title])
            
            if link.isNotEmpty, let range = text.range(of: link, options: String.CompareOptions.backwards) {
                attText.addAttributes([.foregroundColor: HDA(0x0552DC),
                                       .underlineColor: HDA(0x0552DC),
                                       .underlineStyle: NSUnderlineStyle.single.rawValue], range: text.convert(range: range))
            }
            self.message = attText
        }
        
        private func formatDate() {
            let local = Locale(identifier: WKLocale.Shared.localeIdentifier)
            self.dateText = Date(timeIntervalSince1970: Double(rawValue.timestamp)).format(with: "MM-dd HH:mm", locale: local)
        }
        
        private func calculateSize() {
            
        }
         
        static func viewCellClass() ->[AnyClass] {
            return [FoldNormalCell.self, ExpandNormalCell.self, FoldPendingCell.self,
                                    FoldFailureCell.self, TransactionCell.self, TransactionFailureCell.self,
                                    TransactionInProgressCell.self,TransactionAddTokenCell.self, TransactionCrossInProgressCell.self,
                                    TransactionCrossFailureCell.self
                                   ]
        }
        
        func viewCellClass() -> (AnyClass, AnyClass) {
            switch rawValue.notiType {
            case .backup, .system: return (FoldNormalCell.self, ExpandNormalCell.self)
            case .transfer: return (FoldNormalCell.self, (showAddToken ? TransactionAddTokenCell.self : TransactionCell.self))
            case .pendingTransfer: return (FoldPendingCell.self, TransactionInProgressCell.self)
            case .failureTransfer: return (FoldFailureCell.self, TransactionFailureCell.self)
            case .crossPendingTransfer: return (FoldPendingCell.self, TransactionCrossInProgressCell.self)
            case .crossFailureTransfer: return (FoldFailureCell.self, TransactionCrossFailureCell.self)
            default: break
            }
            return (FoldNormalCell.self, ExpandNormalCell.self)
        }
        
        func contentSize() -> CGSize {
            if let size = _contentSize {
                return size
            }
            _contentSize = (viewCellClass().1 as! fxNotificationViewCell.Type).contentSize(model: self)
            return _contentSize ?? CGSize.zero
        }
        
        func messageSize() -> CGSize {
            if let size = _messageSize { 
                return size
            }
            _messageSize = (viewCellClass().1 as! fxNotificationViewCell.Type).messageSize(model: self)
            return _messageSize ?? CGSize.zero
        }
    }
}
        


