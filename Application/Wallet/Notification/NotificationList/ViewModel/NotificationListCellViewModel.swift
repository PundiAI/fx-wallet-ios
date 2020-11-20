import DateToolsSwift
import RxCocoa
import RxSwift
import WKKit
extension NotificationListViewController {
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
                showAddToken = XWallet.currentWallet?.wk.coinManager.has(coin) == false
            }
            formatMsg()
            formatDate()
            calculateSize()
        }

        func didAddCoin() {
            guard showAddToken else { return }
            showAddToken = false
            calculateSize()
        }

        private func formatMsg() { var text = rawValue.message
            var link = ""
            if rawValue.url.isNotEmpty || rawValue.txHash.isNotEmpty {
                link = TR("Notif.ViewDetails")
                text += " \(link)"
            }
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 14), .foregroundColor: COLOR.title])
            if link.isNotEmpty, let range = text.range(of: link) {
                attText.addAttributes([.foregroundColor: HDA(0x0552DC), .underlineColor: HDA(0x0552DC), .underlineStyle: NSUnderlineStyle.single.rawValue], range: text.convert(range: range))
            }
            message = attText
        }

        private func formatDate() {
            dateText = Date(timeIntervalSince1970: Double(rawValue.timestamp)).format(with: "MMM dd HH:mm")
        }

        private func calculateSize() {
            let width = ScreenWidth - (24.auto() * 2)
            if coin == nil || !showAddToken {
                let height = message!.string.heightWithConstrainedWidth(width: width, font: XWallet.Font(ofSize: 14))
                contentHeight = 28.auto() + max(10.auto(), height) + 32.auto() * 2
                size = CGSize(width: width, height: contentHeight)
            } else {
                let height = message!.string.heightWithConstrainedWidth(width: ScreenWidth - (24 + 96).auto(), font: XWallet.Font(ofSize: 14))
                let noticeHeight = TR("Notif.AddTokenNotice$", coin!.token).heightWithConstrainedWidth(width: width, font: XWallet.Font(ofSize: 14, weight: .medium))
                contentHeight = 28.auto() + max(10.auto(), height) + 32.auto() * 2
                size = CGSize(width: width, height: contentHeight + (noticeHeight + (16 * 2 + 56 + 24).auto()))
            }
        }
    }
}
