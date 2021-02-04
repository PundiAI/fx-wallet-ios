//
//  ValidatorsListBinder.swift
//  fxWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa


extension  FxValidatorListViewController {

    
    class ValidatorsListBinder: NSObject, EventResponder {
        
        init(view: WKTableView, searchView: ListHeaderView) {
            self.view = view
            self.searchView = searchView
            super.init()
            
            self.view.sectionView = searchView
            self.view.nextEventResponder = self
        }
        
        let view: WKTableView
        let searchView: ListHeaderView
        
        private(set) var viewModel: ListViewModel!
        
        var didSelected: ((Validator) -> Void)?
        
        func bind(_ viewModel: ListViewModel) {
            self.viewModel = viewModel
            bind()
        }
        
        func refresh() {
            
        }
        
        func bind() {
            
            let listView = self.view
            let listViewModel = self.viewModel!
            self.searchView.inputTF.delegate = self

            listView.viewModels = { [weak self] vm  in
                guard  let this = self else {
                    return vm
                }
                listViewModel.items.each { (idex, item) in
                    item.rawValue.index =  "\(idex + 1)"
                }
                let items = NSMutableArray.viewModels(from: listViewModel.items, ValidatorsCell.self)
                if items.count == 0 { items.push(NoDataCell.self) }
                return items
            }
            
            listView.rx.didScroll.subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
            }).disposed(by: defaultBag)
            
            
            listViewModel.search(searchView.inputTF.rx.text)
                .subscribe(onNext: { (_) in listView.reloadData() })
                .disposed(by: defaultBag)
            
            listView.didSeletedBlock = { [weak self] (listView, indexPath) in
                guard let cell = listView.cellForRow(at: indexPath as IndexPath) as? ValidatorsCell,
                    let vm = cell.viewModel else { return }
                self?.didSelected?(vm.rawValue)
            }
            
        }
        
        var nextEventResponder: EventResponder? { nil }
        func router(event: String, context: [String : Any]) {
            guard event == "add", let coin = (context["eventSender"] as? ValidatorsCell)?.viewModel?.rawValue else { return }
//
//            let fromReceive = Router.topViewController?.heroIdentity == "SelectOrAddAccountViewController"
//            Router.showAddCoinAlert(coin: coin, fromReceive: fromReceive) { [weak self] allow in
//                guard allow else { return }
//                self?.viewModel?.wallet.coinManager.add(coin)
//                self?.didAdded?(coin)
//            }
        }
    }
}


//MARK: UITextFieldDelegate
extension FxValidatorListViewController.ValidatorsListBinder : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchView.isEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchView.isEditing(false)
    }
}




extension  FxValidatorListViewController {

    
    class ValidatorsListRightBinder: NSObject, EventResponder {
        
        init(view: WKTableView, searchView: ListHeaderView) {
            self.view = view
            self.searchView = searchView
            super.init()
            
            self.view.sectionView = searchView
            self.view.nextEventResponder = self
        }
        
        let view: WKTableView
        let searchView: ListHeaderView
        
        private(set) var viewModel: RightListViewModel!
        
        var didSelected: ((Validator) -> Void)?
        
        func bind(_ viewModel: RightListViewModel) {
            self.viewModel = viewModel
            bind()
        }
        
        func refresh() {
            
        }
        
        func bind() {
            
            let listView = self.view
            let listViewModel = self.viewModel!
            self.searchView.inputTF.delegate = self
    
            listView.viewModels = { [weak self] vm  in
                guard  let this = self else {
                    return vm
                }
                listViewModel.items.each { (idex, item) in
                    item.rawValue.index =  "\(idex + 1)"
                }
                let items = NSMutableArray.viewModels(from: listViewModel.items, ValidatorsCell.self)
                if items.count == 0 { items.push(NoDataCell.self) }
                return items
            }
            
            listView.rx.didScroll.subscribe(onNext: { [weak self] (_) in
                self?.view.endEditing(true)
            }).disposed(by: defaultBag)
            
            
            listViewModel.search(searchView.inputTF.rx.text)
                .subscribe(onNext: { (_) in listView.reloadData() })
                .disposed(by: defaultBag)
            
            listView.didSeletedBlock = { [weak self] (listView, indexPath) in
                guard let cell = listView.cellForRow(at: indexPath as IndexPath) as? ValidatorsCell,
                    let vm = cell.viewModel else { return }
                self?.didSelected?(vm.rawValue)
            }
            
        }
        
        var nextEventResponder: EventResponder? { nil }
        func router(event: String, context: [String : Any]) {
            guard event == "add", let coin = (context["eventSender"] as? ValidatorsCell)?.viewModel?.rawValue else { return }
//
//            let fromReceive = Router.topViewController?.heroIdentity == "SelectOrAddAccountViewController"
//            Router.showAddCoinAlert(coin: coin, fromReceive: fromReceive) { [weak self] allow in
//                guard allow else { return }
//                self?.viewModel?.wallet.coinManager.add(coin)
//                self?.didAdded?(coin)
//            }
        }
    }
}


//MARK: UITextFieldDelegate
extension FxValidatorListViewController.ValidatorsListRightBinder : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchView.isEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchView.isEditing(false)
    }
}
