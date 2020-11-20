import RxCocoa
import WKKit
extension ChatListViewController {
    class Cell: WKTableViewCell {
        let view = ItemView(frame: ScreenBounds)
        private var viewModel: CellViewModel!
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            weak var welf = self
            view.nameLabel.text = vm.nameText
            view.avatarIV.set(text: vm.nameText)
            vm.msgText.asDriver()
                .drive(view.textLabel.rx.text)
                .disposed(by: reuseBag)
            vm.dateText.asDriver()
                .drive(view.dateLabel.rx.text)
                .disposed(by: reuseBag)
            vm.badge.asDriver().drive(onNext: { badge in
                welf?.view.badgeView.number = badge
            }).disposed(by: reuseBag)
        }

        override class func height(model _: Any?) -> CGFloat { return 75 }

        override public func initSubView() {
            layoutUI()
            configuration()
            logWhenDeinit()
        }

        private func configuration() {
            backgroundColor = COLOR.backgroud
            contentView.backgroundColor = COLOR.backgroud
        }

        private func layoutUI() {
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
