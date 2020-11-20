//
import Hero
import RxCocoa
import RxSwift
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
import WKKit

extension TokenListViewController {
    class Cell: FxTableViewCell {
        private var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }

        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm

            view.tokenLabel.text = vm.coin.name
            view.tokenIV.setImage(urlString: vm.coin.imgUrl, placeHolderImage: IMG("ic_coin_placeholder"))

            vm.priceText.asDriver()
                .drive(view.priceLabel.rx.text)
                .disposed(by: reuseBag)

            vm.rateText.asDriver()
                .drive(view.rateLabel.rx.attributedText)
                .disposed(by: reuseBag)

            vm.rateImage.asDriver()
                .drive(view.rateIV.rx.image)
                .disposed(by: reuseBag)

            vm.amountText.asDriver()
                .drive(view.amountLabel.rx.text)
                .disposed(by: reuseBag)

            vm.legalAmountText.asDriver()
                .drive(view.legalAmountLabel.rx.text)
                .disposed(by: reuseBag)
        }

        override class func height(model _: Any?) -> CGFloat { return 79 }
    }
}
