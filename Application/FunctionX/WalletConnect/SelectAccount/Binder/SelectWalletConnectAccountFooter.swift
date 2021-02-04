//
//  SelectWalletConnectAccountFooter.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension SelectWalletConnectAccountController {
    class ListFooter: UITableViewHeaderFooterView {
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)

            logWhenDeinit()

            configuration()
            layoutUI()
        }
        
        lazy var view = FooterItemView(frame: ScreenBounds)
        var viewModel: FooterViewModel?
        
        func bind(_ viewModel: FooterViewModel?) {
            guard let vm = viewModel else { return }
            self.viewModel = viewModel
        
            view.topView.isHidden = !vm.display
            view.countLabel.text = vm.text
            view.relayout(expand: vm.isExpand)
        }
        
        func expandOrFold() {
            
            let isExpand = viewModel?.isExpand ?? false
            viewModel?.expand(!isExpand)
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
