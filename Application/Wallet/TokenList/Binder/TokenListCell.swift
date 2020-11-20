import RxCocoa
import RxSwift
import WKKit
extension TokenListViewController {
    class Cell: FxTableViewCell {
        private(set) var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            predisplay(vm)
            weak var welf = self
            let coin = vm.coin
            view.tokenLabel.text = vm.coin.name
            view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: vm.coin.imgPlaceholder)
            vm.priceText.asDriver()
                .drive(view.priceLabel.rx.text)
                .disposed(by: reuseBag)
            vm.rateText.asDriver()
                .drive(view.rateLabel.rx.attributedText)
                .disposed(by: reuseBag)
            vm.balance.value.asDriver()
                .drive(onNext: { welf?.view.balanceLabel.wk.set(amount: $0, symbol: coin.token, power: coin.decimal, thousandth: 8, mb: true) })
                .disposed(by: reuseBag)
            vm.legalBalance.value.asDriver()
                .drive(onNext: { welf?.view.legalBalanceLabel.wk.set(amount: $0, mb: true) })
                .disposed(by: reuseBag)
        }

        private func predisplay(_ vm: CellViewModel) {
            view.balanceLabel.wk.set(amount: vm.balance.value.value, symbol: vm.coin.token, power: vm.coin.decimal, thousandth: 8, mb: true, animated: false)
            view.legalBalanceLabel.wk.set(amount: vm.legalBalance.value.value, mb: true, animated: false)
        }

        override class func height(model _: Any?) -> CGFloat { return 80.auto() }
    }
}
