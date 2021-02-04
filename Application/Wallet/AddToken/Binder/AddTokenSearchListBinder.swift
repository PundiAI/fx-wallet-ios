//
//  AddTokenSearchListBinder.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/17.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension AddTokenViewController {
    
    class SearchListBinder: AddCoinListBinder {
        
        private lazy var sectionView = SectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - (24 * 2).auto(), height: 40.auto()), text: "")
        
        override init(view: WKTableView, searchView: AddCoinListHeaderView) {
            super.init(view: view, searchView: searchView)
            
            view.sectionView = sectionView
        }
        
        override func bind() {
            super.bind()
            
            viewModel.itemCount.subscribe(onNext: { [weak self]value in
                self?.sectionView.titleLabel.text = TR("Select.Token.Result", value.s)
            }).disposed(by: defaultBag)
            
            view.viewModels = { [weak self] _ in
                
                let items = NSMutableArray.viewModels(from: self?.viewModel.items, AddCoinListCell.self)
                if items.count == 0 { items.push(NoDataCell.self) }
                return items
            }
            
            view.scrollViewDidScroll = { [weak self] _ in
                self?.view.superview?.endEditing(true)
            }
        }
        
        private var adding = false
        override func router(event: String, context: [String : Any]) {
            guard event == "add", let coin = (context["eventSender"] as? AddCoinListCell)?.viewModel?.rawValue else { return }
            guard !adding else { return }
            adding = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.adding = false
            }
            
            self.searchView.inputTF.resignFirstResponder()
            self.didAdded?(coin)
        }
    }
}


