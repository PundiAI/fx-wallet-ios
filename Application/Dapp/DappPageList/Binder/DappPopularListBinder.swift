//
//  DappPopularListBinder.swift
//  XWallet
//
//  Created by May on 2020/8/6.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//
import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip


class DappPopularListBinder: DappSubListBinder {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.bindListView() 
    }
    
    let viewModel: ViewModel
    
    private func bindListView() { 
        let listView = self.listView
        let listViewModel = self.viewModel
        listView.nextEventResponder = self
        listViewModel.refreshItems.elements.subscribe(onNext: { (_) in
            listView.reloadData()
        }).disposed(by: defaultBag)
        
        listView.viewModels = { _ in NSMutableArray.viewModels(from: listViewModel.items, DappCell.self) }
        
        listView.didSeletedBlock = { [weak self]( tableView, indexPath) in
            if let _ = tableView.cellForRow(at: indexPath as IndexPath) as? DappCell {
                let cellVM = listViewModel.items[indexPath.row]
                
                if cellVM.dapp.isExplorer {
                    Router.showExplorer(.hub, push: true)
                } else {
                    Router.pushToDappBrowser(dapp: cellVM.dapp, wallet: self?.viewModel.wallet.wk)
                }
            }
        }
    }
    

    override var next: UIResponder? { nil }
    override func router(event: String, context: [String : Any]) {
        if event == "selected", let dapp = (context[eventSender] as? DappCell)?.viewModel {
            
            dapp.update()
            if dapp.star.value {
                Router.topViewController?.hud?.text(m: TR("Dapp.FavoritedTip"))
            }
        }
    }
    
    override func refresh() {
        viewModel.refreshItems.execute()
    }
    
    //MARK: View
    override func layoutUI() {
        self.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: DappSubListBinder.topEdge + 5, left: 0, bottom: 0, right: 0))
        }
        tableView.contentInset = UIEdgeInsets(top: 24.auto(), left: 0, bottom: listBottom, right: 0)
    }
    
    
    override var listView: WKTableView { tableView }
    lazy var tableView: WKTableView = {

        let v = WKTableView(frame: ScreenBounds, style: UITableView.Style.plain)
        v.separatorStyle = .none
        v.backgroundColor = .clear
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.contentInsetAdjustmentBehavior = .never
        return v
    }()
}


