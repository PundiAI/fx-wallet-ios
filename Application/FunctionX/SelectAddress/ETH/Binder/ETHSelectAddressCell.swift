//
//  ETHSelectAddressCell.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SelectAddressViewController {
    
    class ETHCell: SelectAddressViewController.Cell {
        
        private var viewModel: ETHCellViewModel?
        
        private var symbolLabel: UILabel { view.balanceLabel }
        private var balanceLabel: UILabel { view.nameLabel }
        
        override func bind(_ viewModel: Any?) {
            super.bind(viewModel)
            guard let vm = viewModel as? ETHCellViewModel else { return }
            self.viewModel = vm
            
            symbolLabel.text = vm.token.uppercased()
            vm.balanceText.asDriver()
                .drive(balanceLabel.rx.text)
                .disposed(by: reuseBag)
        }
    }
}
