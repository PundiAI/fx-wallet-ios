//
//  DappSelectAddressCell.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/30.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension DappSelectAddressViewController {
    
    class DappCell: SelectAddressViewController.Cell {
        
        private var viewModel: DappCellViewModel?
        
        override func bind(_ viewModel: Any?) {
            super.bind(viewModel)
            guard let vm = viewModel as? DappCellViewModel else { return }
            self.viewModel = vm
            
            if vm.chain == .sms || vm.chain == .hub {
                bindNamedChain(vm)
            } else {
                bindOtherChain(vm)
            }
        }
        
        private func bindNamedChain(_ vm: DappCellViewModel) {
            vm.addressName.asDriver()
                .drive(view.nameLabel.rx.text)
                .disposed(by: reuseBag)
            
            vm.balanceText.asDriver()
                .drive(view.balanceLabel.rx.text)
                .disposed(by: reuseBag)
        }
        
        private func bindOtherChain(_ vm: DappCellViewModel) {
            
            view.balanceLabel.text = vm.token.uppercased()
            vm.balanceText.asDriver()
                .drive(view.nameLabel.rx.text)
                .disposed(by: reuseBag)
        }
    }
}
