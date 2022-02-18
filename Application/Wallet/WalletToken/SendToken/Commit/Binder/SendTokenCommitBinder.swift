//
//  SendTokenCommitBinder.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import SwiftyJSON

//MARK: UserNameListBinder
extension SendTokenCommitViewController {
    
    class UserNameListBinder: RxObject {
        
        init(view: WKTableView) { self.view = view }
        
        let view: WKTableView
        
        private var coin: Coin!
        private var wallet: WKWallet!
        private var users: [User] = []
        
        private var items: [NameCellViewModel] = []
        var didSeleted: ((User) -> Void)?
        
        func bind(wallet: WKWallet, coin: Coin, input: UITextView) {
            self.coin = coin
            self.wallet = wallet
            
            guard self.support(coin: coin) else { return }
            
            for user in self.wallet.receivers(forCoin: coin).receivers {
                if user.name.isEmpty || user.address.isEmpty { continue }
                users.append(user)
            }
            
            weak var welf = self
            input.rx.text.subscribe(onNext: { (v) in
                guard let this = welf else { return }
                
                let text = v ?? ""
                var display = text.hasPrefix("@") && input.isFirstResponder
                if display {
                    
                    var items: [NameCellViewModel] = []
                    let keyword = text.substring(from: 1)
                    for item in this.users {
                        if text == "@" || item.name.contains(keyword) {
                            items.append(NameCellViewModel(user: item, keyword: keyword))
                        }
                    }
                    display = items.isNotEmpty
                    this.items = items
                    this.view.reloadData()
                }
                this.view.isHidden = !display
            }).disposed(by: defaultBag)
            
            view.viewModels = { _ in NSMutableArray.viewModels(from: welf?.items, NameCell.self) }
            view.didSeletedBlock = { (_, i) in
                guard let this = welf else { return }
                
                input.resignFirstResponder()
                this.view.isHidden = true
                this.didSeleted?(this.items[i.row].user)
            }
        }
        
        func support(coin: Coin) -> Bool {
            return coin.isEthereum || coin.isFunctionX || coin.isBSC
        }
    }
    
    class NameCellViewModel {
        let user: User
        let keyword: String
        init(user: User, keyword: String) {
            self.user = user
            self.keyword = keyword
        }
    }
    
    class NameCell: FxTableViewCell {
        
        let nameLabel = UILabel(font: XWallet.Font(ofSize: 16), textColor: HDA(0x838498)).then {$0.autoFont = true}
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? NameCellViewModel else { return }
            
            let text = "@\(vm.user.name)"
            let attText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: HDA(0x838498), .font: XWallet.Font(ofSize: 16)])
            attText.addAttributes([.foregroundColor: COLOR.title], range: NSRange(location: 0, length: 1))
            if vm.keyword.isNotEmpty {
                attText.addAttributes([.foregroundColor: COLOR.title], range: text.convert(range: text.range(of: vm.keyword)!))
            }
            nameLabel.attributedText = attText
            nameLabel.autoFont = true
        }
        
        override class func height(model: Any?) -> CGFloat { 37.auto() }
        
        override func layoutUI() {
            contentView.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(48.auto())
                make.centerY.equalToSuperview()
            }
        }
    }
}
