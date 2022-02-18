

import WKKit
import RxSwift
import RxCocoa
import DateToolsSwift

extension CryptoBankTxHistoryViewController {
    class Cell: FxTableViewCell {
        
        private var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            weak var welf = self
            view.relayout(isDeposit: vm.isDeposit)
            view.dateLabel.text = vm.dateText
            view.amountLabel.text = "\(vm.txInfo.amount) \(vm.txInfo.symbol)"
            view.addressLabel.text = vm.txInfo.address
            vm.legalAmount.subscribe(onNext: { value in
                welf?.view.legalAmountLabel.text = value
            }).disposed(by: reuseBag)
            
            if vm.txInfo.txHash.isNotEmpty {
                
                view.explorerButton.rx.tap.subscribe(onNext: { value in
                    Router.showExplorer(.ethereum, path: .hash(vm.txInfo.txHash))
                }).disposed(by: reuseBag)
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            return (model as? CellViewModel)?.height ?? 44
        }
    }
}
                
