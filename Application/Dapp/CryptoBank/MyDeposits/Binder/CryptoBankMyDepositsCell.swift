

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankMyDepositsViewController {
    class Cell: FxTableViewCell {
        
        private var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            weak var welf = self
            view.relayout(isLast: vm.isLast)
            view.tokenIV.setImage(urlString: vm.token.imgUrl, placeHolderImage: vm.token.imgPlaceholder)
            
            vm.balance.value.subscribe(onNext: { value in
                welf?.view.balanceLabel.text = "\(value.div10(vm.token.decimal).thousandth()) \(vm.aToken.symbol)"
            }).disposed(by: reuseBag)
            
            vm.legalBalance.value.subscribe(onNext: { value in
                welf?.view.legalBalanceLabel.text = "$\(value)"
            }).disposed(by: reuseBag)
            
            vm.reserveData.value.subscribe(onNext: { [weak self]value in
                self?.view.apyLabel.text = vm.apy
            }).disposed(by: reuseBag)
            
            view.withdrawButton.rx.tap.subscribe(onNext: { value in
                Router.pushToCryptoBankWithdraw(wallet: vm.wallet, coin: vm.token, account: vm.account)
            }).disposed(by: reuseBag)
        }
    }
}
                
