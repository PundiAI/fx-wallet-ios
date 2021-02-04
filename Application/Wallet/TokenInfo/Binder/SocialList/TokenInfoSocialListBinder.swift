//
//  TokenInfoSocialListBinder.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import XLPagerTabStrip

class TokenInfoSocialListBinder: TokenInfoSubListBinder, UITableViewDataSource, UITableViewDelegate {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.bindListView()
    }
    
    let viewModel: ViewModel
    
    override func refresh() {
        
        viewModel.refreshItems.execute().subscribe(onNext: { [weak self]value in
            self?.listView.reloadData()
        }).disposed(by: defaultBag)
    }
    
    private func bindListView() {
        listView.delegate = self
        listView.dataSource = self
        
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listView.scrollViewDidScroll?(listView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return section == 0 ? 0.01 : socialHeader.height }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { socialHeader.height }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? nil : socialHeader
//        return section == 0 ? extendHeader : socialHeader
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.0001 }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { "" }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : viewModel.items.count
//        return section == 0 ? 1 : viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return newsCell.estimatedHeight }
        return viewModel.items[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { return newsCell }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        cell.bind(viewModel.items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            Router.showWebViewController(url: "https://www.baidu.com")
        } else {
            let cell = tableView.cellForRow(at: indexPath) as? Cell
            let vm = viewModel.items[indexPath.row]
            cell?.view.selected()
            if let url = vm.url { 
                Router.showVisitSocialAlert(social: vm.rawValue) { (allow) in
                    if allow {
                        Router.showWebViewController(url: url)
                    }
                }
            }
        }
    }
    
    //MARK: View
    override func layoutUI() {
        self.navigationBar.isHidden = true
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: listTop, left: 0, bottom: 0, right: 0))
        }
    }
    
    override var listView: WKTableView { tableView }
    lazy var tableView: WKTableView = {

        let v = WKTableView(frame: ScreenBounds, style: .grouped)
        v.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001), .clear)
        v.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001), .clear)
        v.backgroundColor = HDA(0x080A32)
        return v
    }()
    
    lazy var newsCell = NewsCell()
    lazy var extendHeader = HeaderView(isSocial: false)
    lazy var socialHeader = HeaderView(isSocial: true)
}
