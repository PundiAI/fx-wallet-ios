//
//  ChatCell.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/16.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension ChatViewController {
    class Cell: WKTableViewCell, SnapshotProviderProtocol {
        static func cls(for viewModel: CellViewModel) -> Cell.Type {
            if viewModel is DateCellViewModel { return DateCell.self }

            switch viewModel.type {
            case .sendText: return SenderTextCell.self
            case .sendGift: return SenderGiftCell.self
            case .receiveText: return ReceiverTextCell.self
            case .receiveGift: return ReceiverGiftCell.self
            }
        }

        func getView() -> ItemView { return ItemView() }
        func getViewModel() -> CellViewModel? { return nil }

        func snapshot() -> (UIImageView, CGRect)? { return nil }
        func snapshotText() -> String { return "" }

        override class func height(model: Any?) -> CGFloat {
            return (model as? CellViewModel)?.height ?? 55
        }

        // MARK: Action

        private func bindAction() {
            let longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(longTapAction))
            longTapGR.minimumPressDuration = 0.6
            getView().addGestureRecognizer(longTapGR)

            getView().resendButton.bind(self, action: #selector(resendAction), forControlEvents: .touchUpInside)
        }

        static let longTapEvent = "longTapEvent"
        static let resendTapEvent = "resendTapEvent"
        @objc func longTapAction(_ gr: UILongPressGestureRecognizer) {
            guard gr.state == .began else { return }

            gr.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                gr.isEnabled = true
            }
            router(event: Cell.longTapEvent, context: [eventSender: self])
        }

        @objc func resendAction(_ sender: UIButton) {
            sender.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                sender.isEnabled = true
            }
            router(event: Cell.resendTapEvent, context: [eventSender: self])
        }

        override public func initSubView() {
            layoutUI()
            bindAction()
            configuration()

            logWhenDeinit()
        }

        func configuration() {
            backgroundColor = HDA(0x1D1D1D)
            contentView.backgroundColor = HDA(0x1D1D1D)
        }

        func layoutUI() {
            let view = getView()
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
