//
//  FxCloudSelectAddressCell.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/6/2.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxAnyNodeSelectAddressViewController {
    
    class FCAddressCell: SelectAddressViewController.Cell {
        
        private var viewModel: FCCellViewModel?
        private var symbolLabel: UILabel { view.balanceLabel }
        private var balanceLabel: UILabel { view.nameLabel }
        
        override func bind(_ viewModel: Any?) {
            super.bind(viewModel)
            guard let vm = viewModel as? FCCellViewModel else { return }
            self.viewModel = vm
            
            symbolLabel.text = vm.token.uppercased()
            vm.balanceText.asDriver()
                .drive(balanceLabel.rx.text)
                .disposed(by: reuseBag)
        }
        
        override func layoutUI() {
            super.layoutUI()
            
            view.addressLabel.font = XWallet.Font(ofSize: 14)
            view.addressLabel.textColor = .white
        }
    }
}
