//
//  ChatCellViewModel.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import RxCocoa
import WKKit

extension ChatViewController {
    class CellViewModel {
        static func instance(_ sms: SmsMessage) -> SmsCellViewModel {
            switch sms.type {
            case .sendText: return SenderTextCellViewModel(sms)
            case .sendGift: return SenderGiftCellViewModel(sms)
            case .receiveText: return ReceiverTextCellViewModel(sms)
            case .receiveGift: return ReceiverGiftCellViewModel(sms)
            }
        }

        var height: CGFloat = 50

        private static let today = Date()
        var date = CellViewModel.today
        var isToday = true

        let rawValue: SmsMessage
        init(_ sms: SmsMessage) {
            rawValue = sms
            if sms.availableTimestamp > 0 {
                date = Date(timeIntervalSince1970: sms.availableTimestamp)
                isToday = date.isSameDay(date: CellViewModel.today)
            }
        }

        var type: SmsMessage.Types { rawValue.type }

        var id: UInt64 { rawValue.id }
        var txHeight: UInt64 { rawValue.txHeight }
        var sortHeight: UInt64 { rawValue.sortHeight }

        var hasNext: Bool { rawValue.hasNext }
        var nextTxHeight: UInt64 { rawValue.nextTxHeight }

        func update(status _: SmsMessage.Status) {}
    }
}

// MARK:

extension ChatViewController {
    class DateCellViewModel: CellViewModel {
        let dateText: String
        override init(_ sms: SmsMessage) {
            dateText = Date(timeIntervalSince1970: sms.availableTimestamp).format(with: "MMM dd")

            super.init(sms)
            height = 10 + 14 + 10
        }
    }
}

// MARK: SmsCellViewModel

extension ChatViewController {
    class SmsCellViewModel: CellViewModel {
        var nameText = ""

        var dateText = ""
        var dateFrame = CGRect.zero

        var messageText = ""
        var messageFrame = CGRect.zero

        var bubblePath = UIBezierPath()
        var bubbleFrame = CGRect.zero

        var statusFrame = CGRect.zero
        var statusImage: UIImage?
        var resendFrame = CGRect.zero

        let status: BehaviorRelay<SmsMessage.Status>

        override init(_ sms: SmsMessage) {
            status = BehaviorRelay(value: sms.status)

            nameText = sms.isReceiver ? sms.receiveName : ""
            dateText = Date(timeIntervalSince1970: sms.availableTimestamp).format(with: "HH:mm")
            messageText = sms.message.content

            super.init(sms)

            parse(sms.message)
            update(status: rawValue.status)
        }

        override func update(status: SmsMessage.Status) {
            rawValue.status = status
            if status == .failed {
                statusImage = nil
            } else {
                statusImage = IMG(status == .successed ? "Chat.MsgSuccess" : "Chat.MsgSending")
            }

            dateText = Date(timeIntervalSince1970: rawValue.availableTimestamp).format(with: "HH:mm")
            if status != self.status.value { self.status.accept(status) }
        }

        fileprivate func parse(_: TransactionMessage.SmsSendMsg) {}
    }
}

// MARK: TextCell

extension ChatViewController {
    class TextCellViewModel: SmsCellViewModel {
        fileprivate var isMultiLine: Bool { return height > minBubbleHeight }

        fileprivate var bubbleMargin: CGFloat { return 8 }
        fileprivate var minBubbleWidth: CGFloat { return 70 }
        fileprivate var minBubbleHeight: CGFloat { return 50 }

        fileprivate var textMargin: CGFloat { return 14 }

        fileprivate var dateHeight: CGFloat { return 14 }
        fileprivate var dateMargin: CGFloat { return 10 }

        override func parse(_ sms: TransactionMessage.SmsSendMsg) {
            let size = CGSize(width: ScreenWidth - 90 - 60, height: CGFloat.greatestFiniteMagnitude)
            let textSize = sms.content.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: XWallet.Font(ofSize: 14)], context: nil).size

            calculateBubble(textSize)
            calculateMessage(textSize)
            calculateDate()
            calculateResend()
            height = bubbleFrame.height + 10
        }

        fileprivate func calculateBubble(_: CGSize) {}
        fileprivate func calculateDate() {}
        fileprivate func calculateResend() {}
        fileprivate func calculateMessage(_ textSize: CGSize) {
            messageFrame = CGRect(x: bubbleFrame.minX + textMargin, y: bubbleFrame.minY + bubbleMargin, width: textSize.width, height: textSize.height)
        }
    }
}

// MARK: TextCell(Sender)

extension ChatViewController {
    class SenderTextCellViewModel: TextCellViewModel {
        override func calculateBubble(_ textSize: CGSize) {
            let width = max(minBubbleWidth, textSize.width + textMargin + 20)
            let height = max(minBubbleHeight, textSize.height + bubbleMargin + dateHeight + dateMargin)
            let corner = CGSize(width: isMultiLine ? 20 : 15, height: isMultiLine ? 20 : 15)
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            bubblePath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight], cornerRadii: corner)
            bubbleFrame = CGRect(x: ScreenWidth - width - 14, y: 0, width: width, height: height)
        }

        override func calculateDate() {
            let size = CGSize(width: 33.5, height: 14)
            dateFrame = CGRect(x: bubbleFrame.minX + 14, y: bubbleFrame.maxY - bubbleMargin - dateHeight, width: size.width, height: size.height)
            statusFrame = CGRect(x: dateFrame.maxX, y: dateFrame.midY - 5, width: 10, height: 10)
        }

        override func calculateResend() {
            let size: CGFloat = 30
            resendFrame = CGRect(x: bubbleFrame.minX - 8 - size, y: bubbleFrame.midY - size * 0.5, width: size, height: size)
        }
    }
}

// MARK: TextCell(Receiver)

extension ChatViewController {
    class ReceiverTextCellViewModel: TextCellViewModel {
        override func calculateBubble(_ textSize: CGSize) {
            let width = max(minBubbleWidth, textSize.width + textMargin + 20)
            let height = max(minBubbleHeight, textSize.height + bubbleMargin + dateHeight + dateMargin)
            let corner = CGSize(width: isMultiLine ? 20 : 15, height: isMultiLine ? 20 : 15)
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)
            bubblePath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight, .bottomLeft, .bottomRight], cornerRadii: corner)
            bubbleFrame = CGRect(x: 14 + 36 + 10, y: 1, width: width, height: height)
        }

        override func calculateDate() {
            dateFrame = CGRect(x: bubbleFrame.minX + 14, y: bubbleFrame.maxY - bubbleMargin - dateHeight, width: 70, height: dateHeight)
        }
    }
}

// MARK: GiftCell

extension ChatViewController {
    class GiftCellViewModel: SmsCellViewModel {
        var tokenText = ""
        var tokenWidth: CGFloat = 0

        var amountText = ""
        var legalAmountText = ""

        override func parse(_ sms: TransactionMessage.SmsSendMsg) {
            height = 119 + 16
            if let token = sms.transferTokens.first {
                tokenText = "FX" // token.denom.uppercased()
                tokenWidth = CGFloat(tokenText.count * 15)

                amountText = String(token.amount.fxc.thousandth())
                //                self.legalAmountText = String(format: "$ %.2f", Float(token.amount) * 0.1)
            }
        }
    }
}

// MARK: GiftCell(Sender)

extension ChatViewController {
    class SenderGiftCellViewModel: GiftCellViewModel {}
}

// MARK: GiftCell(Receiver)

extension ChatViewController {
    class ReceiverGiftCellViewModel: GiftCellViewModel {}
}
