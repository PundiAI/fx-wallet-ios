import WKKit
extension ChatViewController {
    class TextCell: Cell {
        let view = TextItemView(frame: ScreenBounds)
        override func getView() -> ItemView { view }
        private var viewModel: TextCellViewModel!
        override func getViewModel() -> CellViewModel? { viewModel }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? TextCellViewModel else { return }
            self.viewModel = vm
            view.dateLabel.text = vm.dateText
            view.textLabel.text = vm.messageText
            view.bubbleLayer.path = vm.bubblePath.cgPath
            view.avatarIV.set(text: vm.nameText)
            view.statusIV.frame = vm.statusFrame
            view.dateLabel.frame = vm.dateFrame
            view.textLabel.frame = vm.messageFrame
            view.bubbleLayer.frame = vm.bubbleFrame
            view.resendButton.frame = vm.resendFrame
            vm.status.subscribe(onNext: { [weak self] s in
                self?.view.statusIV.image = vm.statusImage
                self?.view.resendButton.isHidden = s != .failed
                self?.view.dateLabel.isHidden = s == .sending
                if s == .sending {
                    self?.view.statusIV.frame.origin = vm.dateFrame.origin
                } else {
                    self?.view.statusIV.frame = vm.statusFrame
                }
            }).disposed(by: reuseBag)
        }

        override func snapshotText() -> String { return view.textLabel.text ?? "" }
        override func snapshot() -> (UIImageView, CGRect)? {
            guard let topVC = Router.topViewController else { return nil }
            let state = (view.backgroundColor, view.avatarIV.isHidden, view.resendButton.isHidden)
            let snapshotIV = UIImageView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.88)
            view.avatarIV.isHidden = true
            view.resendButton.isHidden = true
            snapshotIV.image = asImage()
            snapshotIV.frame = topVC.view.convert(view.frame, from: view.superview)
            view.backgroundColor = state.0
            view.avatarIV.isHidden = state.1
            view.resendButton.isHidden = state.2
            let frame = topVC.view.layer.convert(view.bubbleLayer.frame, from: view.bubbleLayer.superlayer)
            return (snapshotIV, frame)
        }
    }
}

extension ChatViewController {
    class SenderTextCell: TextCell {
        override func layoutUI() {
            view.layoutForSender()
            super.layoutUI()
        }
    }
}

extension ChatViewController {
    class ReceiverTextCell: TextCell {
        override func layoutUI() {
            view.layoutForReceiver()
            super.layoutUI()
        }
    }
}
