

import WKKit
import RxSwift
import RxCocoa

extension FxMyDelegatesViewController {
    class Cell: FxTableViewCell {
        
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        private var viewModel: CellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            let fxc = vm.coin.token
            view.fxcRewardsTLabel.text = "\(fxc) \(TR("FXDelegator.Rewards")):"
            view.fxUSDRewardsTLabel.text = "\(Coin.FxUSDSymbol) \(TR("FXDelegator.Rewards")):"
            
            view.relayout(isLast: vm.isLast)
            view.validatorIV.setImage(urlString: vm.validator.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
            view.apyLabel.text = "\(vm.validator.rewards)%"
            view.validatorNameLabel.text = vm.validator.validatorName
            view.delegateAmountLabel.text = vm.validator.delegateAmount.div10(vm.coin.decimal).thousandth() + " \(fxc)"
            
            view.fxcRewardsLabel.text = vm.validator.reward(of: vm.coin.symbol).div10(vm.coin.decimal).thousandth() + " \(fxc)"
            view.fxUSDRewardsLabel.text = vm.validator.reward(of: Coin.FxUSDSymbol).div10(vm.coin.decimal).thousandth() + " \(Coin.FxUSDSymbol)"
        }
    }
}
                
