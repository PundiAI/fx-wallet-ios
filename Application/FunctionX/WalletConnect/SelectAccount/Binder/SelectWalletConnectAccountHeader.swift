//
//  SelectWalletConnectAccountHeader.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SelectWalletConnectAccountController {
    class ListHeader: UITableViewHeaderFooterView {
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)

            logWhenDeinit()

            configuration()
            layoutUI()
        }
        
        lazy var view = HeaderItemView(frame: ScreenBounds)
        private var viewModel: HeaderViewModel?
        
        func bind(_ viewModel: HeaderViewModel?) {
            guard let vm = viewModel else { return }
            self.viewModel = vm
            
            view.numberLabel.text = vm.number
            view.addressLabel.text = vm.address
            view.balanceLabel.text = vm.balanceText
            view.remarkLabel.text = vm.addressRemark
            view.relayout(hideRemark: vm.addressRemark.count == 0)
            
            view.coinTypeView.bind(vm.coin)
        }
        
        var reuseBag = DisposeBag()
        override func prepareForReuse() {
            super.prepareForReuse()
            reuseBag = DisposeBag()
        }
        
        //MARK: Utils
        func configuration() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
        }
        
        func layoutUI() {
            
            self.contentView.addSubview(view)
            self.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
