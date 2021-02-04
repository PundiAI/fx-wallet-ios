//
//  SelectAddressCell.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SelectAddressViewController {
    
    class Cell: WKTableViewCell {
        
        lazy var view = getView()
        func getView() -> ItemView { return ItemView(frame: ScreenBounds) }
        
        private var viewModel: CellViewModel?
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            weak var welf = self
            view.addressLabel.text = vm.address
            vm.addressRemark.asDriver()
                .drive(onNext: {
                    welf?.view.remarkLabel.text = "  \($0)  "
                    welf?.view.relayout(hideRemark: $0.count == 0)
                }).disposed(by: reuseBag)
            
            vm.isSelected.asDriver()
                .distinctUntilChanged()
                .drive(onNext: { welf?.view.relayout(isSelected: $0) })
                .disposed(by: reuseBag)
        }
        
        func bindAction() {
            
            weak var welf = self
            view.copyButton.rx.tap.subscribe(onNext: { (_) in
                UIPasteboard.general.string = welf?.viewModel?.address ?? ""
                Router.topViewController?.hud?.text(m: TR("Copied"))
            }).disposed(by: defaultBag)
            
            view.editButton.rx.tap.subscribe(onNext: { (_) in
                
                guard let vm = welf?.viewModel else { return }
                Router.showEditAddressAlert(address: vm.address) { vm.update(addressRemark: $0) }
            }).disposed(by: defaultBag)
        }

        override class func height(model: Any?) -> CGFloat { return 94 + 5 }
        
        //MARK: Utils
        override public func initSubView() {
            
            layoutUI()
            configuration()
            
            bindAction()
            
            logWhenDeinit()
        }
        
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
