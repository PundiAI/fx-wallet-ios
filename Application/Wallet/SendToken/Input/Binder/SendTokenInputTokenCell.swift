import RxCocoa
import RxSwift
import WKKit
extension SendTokenInputViewController {
    class Cell: FxTableViewCell {
        private var viewModel: Coin?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? Coin else { return }
            self.viewModel = vm
            view.nameLabel.text = vm.name
            view.symbolLabel.text = vm.symbol
            view.tokenIV.setImage(urlString: vm.imgUrl, placeHolderImage: vm.imgPlaceholder)
        }

        override class func height(model _: Any?) -> CGFloat { return 60 }
    }
}
