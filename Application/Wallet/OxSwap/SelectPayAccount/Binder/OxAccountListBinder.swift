//
//  OxAccountListBinder.swift
//  fxWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

typealias OxAccountListCell = SelectPayAccountViewController.OxAccountListCell

extension SelectPayAccountViewController {
    
    class OxAccountListBinder: NSObject {
        
        init(view: WKTableView, searchView: AddCoinListHeaderView) {
            self.view = view
            self.searchView = searchView
            super.init()
        }
            

        
        let searchView: AddCoinListHeaderView
        
        let view: UITableView
        private(set) var viewModel: AccountListViewModel!
        private lazy var noneHeader = AccountListUnavailableSectionHeader(size: .zero)
        
        var didSeleted: ((AccountListSectionHeader?, Coin, Keypair) -> Void)?
        
        
        var didNotEnougtFee: (() -> ())?
        
        func bind(_ viewModel: AccountListViewModel) {
            let listView = self.view
            self.viewModel = viewModel
            
            self.searchView.inputTF.delegate = self
            
            
            viewModel.search(searchView.inputTF.rx.text)
                .subscribe(onNext: { (_) in listView.reloadData() })
                .disposed(by: defaultBag)
            
            view.register(OxAccountListCell.self, forCellReuseIdentifier: "cell")
            view.register(AccountListSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
            
            view.delegate = self
            view.dataSource = self
            
//            [weak self] (offset) in
            view.rx.didScroll.subscribe(onNext: { [weak self] (offset) in
                print("\(offset)")
                self?.view.superview?.endEditing(true)
            
            }).disposed(by: defaultBag)
            
            
        }
        
        func refresh() {
            viewModel?.refresh()
        }
    }
}
//MARK: UITextFieldDelegate
extension SelectPayAccountViewController.OxAccountListBinder : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchView.isEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchView.isEditing(false)
    }
}


extension SelectPayAccountViewController.OxAccountListBinder: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = viewModel.coins.count
        viewModel.itemsCount.accept(count)
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { viewModel.items[section].height }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = viewModel.coins[section]
        if item is NoneAccountSectionViewModel { return noneHeader }
        
        let coin = item.coin
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? AccountListSectionHeader
        header?.titleLabel.text = coin.name
        header?.coinTypeView.bind(coin)
//        header?.disableMask.isHidden = viewModel.items[section].isEnabled
        header?.iconIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        header?.iconIV.bind(coin)
        if item is RecentAccountSectionViewModel {
            header?.iconIV.backgroundColor = .clear
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 24.auto() }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { "" }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coins[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.coins[indexPath.section].items[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OxAccountListCell
        cell.bind(viewModel.coins[indexPath.section].items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vm = viewModel.coins[indexPath.section].items[indexPath.row]
//        guard vm.isEnabled else { return }
        
//        if vm.coin.isERC20 {
//            let balance = XWallet.currentWallet?.wk.balance(of: vm.address, coin: .ethereum) ?? .empty
//            let amount = balance.value.value.div10(18).d
//
//            if amount < 0.0044 {
//                didNotEnougtFee?()
//                return
//            }
//        }
        
        let headview = tableView.headerView(forSection: indexPath.section) as? AccountListSectionHeader
        didSeleted?(headview, vm.coin, vm.account)
    }
}
