import RxCocoa
import RxSwift
import WKKit
extension SwapConfirmViewController {
    class TokenPanelCell: FxTableViewCell {
        private var viewModel: SwapViewController.AmountsModel?
        lazy var view = TokenPanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? SwapViewController.AmountsModel else { return }
            self.viewModel = vm
            let from = vm.from
            let to = vm.to
            view.fromToken.tokenIV.setImage(urlString: from.token.imgUrl, placeHolderImage: from.token.imgPlaceholder)
            view.fromToken.tokenLabel.text = from.token.symbol
            view.toToken.tokenIV.setImage(urlString: to.token.imgUrl, placeHolderImage: to.token.imgPlaceholder)
            view.toToken.tokenLabel.text = to.token.symbol
            view.fromToken.amountLabel.text = from.inputformatValue.thousandth()
            view.toToken.amountLabel.text = to.inputformatValue.thousandth()
        }

        override class func height(model _: Any?) -> CGFloat {
            return (8 + 165).auto()
        }
    }
}

extension SwapConfirmViewController {
    class TipViewCell: FxTableViewCell {
        static var message = "Input is estimated. You will sell at most %@ or the transaction will revert."
        static var outputMessage = "Output is estimated. You will receive at least %@ or the transaction will revert."
        private var viewModel: Any?
        lazy var view = SwapTipView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? SwapViewController.AmountsModel else { return }
            self.viewModel = vm
            if vm.amountsType == .out {
                view.titleLabel.text = TR(TipViewCell.outputMessage, vm.minValue + " " + vm.amountsInput.token.symbol)
            } else {
                view.titleLabel.text = TR(TipViewCell.message, vm.maxValue + " " + vm.amountsInput.token.symbol)
            }
        }

        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - (24 * 2).auto()
            guard let vm = model as? SwapViewController.AmountsModel else { return 0 }
            var temp = ""
            if vm.amountsType == .out {
                temp = TR(TipViewCell.outputMessage, vm.maxOrMin)
            } else {
                temp = TR(TipViewCell.message, vm.maxOrMin)
            }
            let font1: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = temp
                $0.autoFont = true
            }.font
            let height = temp.height(ofWidth: width, attributes: [.font: font1])
            return (16 + 32).auto() + height
        }
    }
}

extension SwapViewController {
    class FeeCell: FxTableViewCell {
        private var viewModel: Any?
        lazy var view = FeePannel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? AmountsModel else { return }
            self.viewModel = vm
            weak var welf = self
            view.maxSold.titleLabel.text = TR("Maxmum sold")
            view.priceImpact.titleLabel.text = TR("Price Impact")
            view.providerFee.titleLabel.text = TR("Liquidity Provider Fee")
            switch vm.amountsType {
            case .in:
                welf?.view.maxSold.titleLabel.text = TR("Maxmum sold")
                welf?.view.soldValue.text = "\(vm.maxValue.thousandth()) \(vm.from.token.symbol)"
            case .out:
                welf?.view.maxSold.titleLabel.text = TR("Minimum received")
                welf?.view.soldValue.text = "\(vm.minValue.thousandth()) \(vm.to.token.symbol)"
            case .null:
                break
            }
            view.priceImpact.subTitleLabel.text = vm.priceImpact.thousandth(2) + "%"
            if vm.priceImpact.isLessThan(decimal: "0.01") {
                view.priceImpact.subTitleLabel.textColor = RGB(36, 163, 78)
                view.priceImpact.subTitleLabel.text = "<0.01%"
            } else if vm.priceImpact.isLessThan(decimal: "3") {
                view.priceImpact.subTitleLabel.textColor = UIColor.black
            } else {
                view.priceImpact.subTitleLabel.textColor = RGB(251, 79, 94)
            }
            let mobilityValue = vm.from.inputValue.mul(String(0.003)).div(String(1.0 - 0.003), 4)
            view.providerValue.text = "\(mobilityValue) \(vm.from.token.symbol)"
            view.soldHelpBtn.rx.tap.subscribe(onNext: { _ in
                welf?.router(event: "Sold.Help")
            }).disposed(by: reuseBag)
            view.priceHelpBtn.rx.tap.subscribe(onNext: { _ in
                welf?.router(event: "Price.Help")
            }).disposed(by: reuseBag)
            view.providerHelpBtn.rx.tap.subscribe(onNext: { _ in
                welf?.router(event: "Provider.Help")
            }).disposed(by: reuseBag)
        }

        override class func height(model _: Any?) -> CGFloat {
            return 132.auto()
        }
    }
}
