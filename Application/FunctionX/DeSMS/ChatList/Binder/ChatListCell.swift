//
//  ChatListCell.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxCocoa

extension ChatListViewController {
    
    class Cell: WKTableViewCell {
        
        let view = ItemView(frame: ScreenBounds)
        private var viewModel: CellViewModel!
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            
            weak var welf = self
            view.nameLabel.text = vm.nameText
            view.avatarIV.set(text: vm.nameText)
            
            vm.msgText.asDriver()
                .drive(view.textLabel.rx.text)
                .disposed(by: reuseBag)
            
            vm.dateText.asDriver()
                .drive(view.dateLabel.rx.text)
                .disposed(by: reuseBag)
            
            vm.badge.asDriver().drive(onNext: { (badge) in
                welf?.view.badgeView.number = badge
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { return 75 }
        
        //MARK: Utils
        override public func initSubView() {
            
            layoutUI()
            configuration()
            
            logWhenDeinit()
        }
        
        private func configuration() {
            
            self.backgroundColor = COLOR.BACKGROUND
            self.contentView.backgroundColor = COLOR.BACKGROUND
        }
        
        private func layoutUI() {
            
            self.contentView.addSubview(view)
            self.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
