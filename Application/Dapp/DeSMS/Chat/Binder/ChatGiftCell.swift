import WKKit
extension ChatViewController {
    class GiftCell: Cell {
        let view = GiftItemView(frame: ScreenBounds)
        override func getView() -> ItemView { view }
        private var viewModel: GiftCellViewModel!
        override func getViewModel() -> CellViewModel? { viewModel }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? GiftCellViewModel else { return }
            self.viewModel = vm
            view.dateLabel.text = vm.dateText
            view.textLabel.text = vm.messageText
            view.tokenLabel.text = vm.tokenText
            view.amountLabel.text = vm.amountText
            view.legalAmountLabel.text = vm.legalAmountText
            view.avatarIV.set(text: vm.nameText)
            view.layoutToken(vm.tokenWidth)
            vm.status.subscribe(onNext: { [weak self] s in
                self?.view.resendButton.isHidden = s != .failed
            }).disposed(by: reuseBag)
        }

        override func snapshotText() -> String { return view.textLabel.text ?? "" }
        override func snapshot() -> (UIImageView, CGRect)? {
            guard let topVC = Router.topViewController else { return nil }
            let state = view.resendButton.isHidden
            view.resendButton.isHidden = true
            let snapshotIV = UIImageView()
            snapshotIV.image = view.contentView.asImage()
            snapshotIV.frame = topVC.view.convert(view.contentView.frame, from: view.contentView.superview)
            view.resendButton.isHidden = state
            return (snapshotIV, snapshotIV.frame)
        }
    }
}

extension ChatViewController {
    class SenderGiftCell: GiftCell {
        override func layoutUI() {
            view.layoutForSender()
            super.layoutUI()
        }
    }
}

extension ChatViewController {
    class ReceiverGiftCell: GiftCell {
        override func layoutUI() {
            view.layoutForReceiver()
            super.layoutUI()
        }
    }
}
