//
//  AddTokenListBinder.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/17.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension AddTokenViewController {
    
    class ListBinder: NSObject, UITableViewDelegate, UITableViewDataSource, EventResponder {
        
        init(view: View) {
            self.view = view
            super.init()
            self.listView.nextEventResponder = self
        }
        
        let view: View
        var listView: WKTableView { view.mainListView }
        
        var viewModel: ListViewModel!
        
        var didAdded: ((Coin) -> Void)?
        var didScroll: ((UITableView) -> Void)?
        
        func bind(_ viewModel: ListViewModel) {
            self.viewModel = viewModel
            
            listView.register(AddCoinListCell.self, forCellReuseIdentifier: "cell")
            
            listView.delegate = self
            listView.dataSource = self
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            didScroll?(listView)
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return viewModel?.items.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 40.auto() }
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            return section == 0 ? view.suggestedSection : view.availableSection
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 24.auto() }
        func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return "" }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.items[section].count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return viewModel.items[indexPath.section][indexPath.row].height
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AddCoinListCell
            cell.bind(viewModel.items[indexPath.section][indexPath.row])
            return cell
        }
        
        private var adding = false
        var nextEventResponder: EventResponder? { nil }
        func router(event: String, context: [String : Any]) {
            guard event == "add", let coin = (context["eventSender"] as? AddCoinListCell)?.viewModel?.rawValue else { return }
            guard !adding else { return }
            adding = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.adding = false
            }
            
            self.didAdded?(coin)
        }
    }
}
