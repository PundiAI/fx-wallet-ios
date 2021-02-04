//
//  SelectReceiveCoinListBinder.swift
//  fxWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa


extension SelectReceiveCoinViewController {
    
    class SelectCoinListBinder: NSObject, EventResponder {
        
        init(view: WKTableView, searchView: AddCoinListHeaderView) {
            self.view = view
            self.searchView = searchView
            super.init()
            self.view.nextEventResponder = self
        }
        
        let view: WKTableView
        let searchView: AddCoinListHeaderView
        
        private(set) var viewModel: AddCoinListViewModel!
        
        
        func bind(_ viewModel: AddCoinListViewModel) {
            self.viewModel = viewModel
            bind()
        }
        
        func refresh() {
            
        }
        
        func bind() {
            
            let listView = self.view
            let listViewModel = self.viewModel!
            self.searchView.inputTF.delegate = self
            listViewModel.search(searchView.inputTF.rx.text)
                .subscribe(onNext: { (_) in listView.reloadData() })
                .disposed(by: defaultBag)

            listView.viewModels = { _ in NSMutableArray.viewModels(from: listViewModel.items, AddCoinListCell.self) }
            listView.rx.didScroll.subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
            }).disposed(by: defaultBag)
        }
        
        var nextEventResponder: EventResponder? { nil }
        
        func router(event: String, context: [String : Any]) {
            
        }
    }
    
    
    
}

//MARK: UITextFieldDelegate
extension SelectReceiveCoinViewController.SelectCoinListBinder : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchView.isEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchView.isEditing(false)
    }
}


extension SelectReceiveCoinViewController {
    
    class SearchListBinder: SelectCoinListBinder {
        
        override init(view: WKTableView, searchView: AddCoinListHeaderView) {
            super.init(view: view, searchView: searchView)
        }
        
        var coinSelected: ((Coin) -> ())?
        
        var loadCompleted: Bool = false
        
        override func bind() {
            super.bind()
            
            view.viewModels = { [weak self] vm in
                guard  let this = self else {
                    return vm
                }
                let items = NSMutableArray.viewModels(from: self?.viewModel.items, AddCoinListCell.self)
                if !this.loadCompleted  {
                    self?.view.tableHeaderView?.isHidden  = items.count == 0
                } else {
                    self?.view.tableHeaderView?.isHidden = false
                    if items.count == 0 { items.push(NoDataCell.self) }
                }
                return items
            }
            
            view.didSeletedBlock = {[weak self] (table, indexPath) in
                guard let this = self,  let cell = table.cellForRow(at: indexPath as IndexPath) as? AddCoinListCell,
                      let vm = cell.viewModel else { return }
                this.coinSelected?(vm.rawValue.cnvertCoin)
            }
            
            view.scrollViewDidScroll = { [weak self] _ in
                self?.view.superview?.endEditing(true)
            }
        }
        
        override func router(event: String, context: [String : Any]) {
//            guard event == "add", let coin = (context["eventSender"] as? AddCoinListCell)?.viewModel?.rawValue else { return }
            
        }
    }
}
