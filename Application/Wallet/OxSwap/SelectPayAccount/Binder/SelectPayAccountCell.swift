//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SelectPayAccountViewController {

    class OxAccountListCell: FxTableViewCell {
        
        lazy var view = OxAccountListItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        var viewModel: AccountListCellModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? AccountListCellModel else { return }
            self.viewModel = vm
            
            let coin = vm.coin
            weak var welf = self
//            view.remarkLabel.text = vm.remark
            view.addressLabel.text = vm.address
//            view.disableMask.isHidden = vm.isEnabled
//            view.relayout(hideRemark: vm.remark.isEmpty)
            
            view.relayout(hideEthRemark: vm.coin.isETH)

            if vm.coin.isERC20 { 
                let balance = XWallet.currentWallet?.wk.balance(of: vm.address, coin: .ethereum) ?? .empty
                let amount = balance.value.value.div10(18).thousandth(mb: true)
                view.ethBalanceLabel.text = "\(amount) ETH"
            }
            
//            vm.isSelected
//                .subscribe(onNext: { welf?.view.isSelected = $0 })
//                .disposed(by: reuseBag)
            
            vm.balance.value.asDriver().drive(onNext: { (balance) in
                welf?.view.balanceLabel.wk.set(amount: balance, symbol: coin.token, power: coin.decimal, thousandth: 8, animated: false)
            }).disposed(by: reuseBag)
            
            view.layoutCorner(vm.corners, size: vm.size)
        }
        
        override class func height(model: Any?) -> CGFloat {
            return (model as? AccountListCellModel)?.height ?? 98
        }
    }
}
                
