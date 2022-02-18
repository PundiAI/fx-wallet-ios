//
//  SelectWalletConnectAccountViewController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import Hero

extension WKWrapper where Base == SelectWalletConnectAccountController {
    var view: Base.View { return base.view as! Base.View }
}

extension SelectWalletConnectAccountController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }

        let filter = context["filter"] as? (Coin, [String: Any]?) -> Bool
        let vc = SelectWalletConnectAccountController(wallet: wallet, filter: filter)
        vc.cancelHandler = context["cancelHandler"] as? () -> Void
        vc.confirmHandler = context["handler"] as? (UIViewController?, Keypair) -> Void
        return vc
    }
}

class SelectWalletConnectAccountController: WKViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, filter: ((Coin, [String: Any]?) -> Bool)? = nil) {
        
        self.viewModel = ListViewModel(wallet: wallet, filter: filter)
        super.init(nibName: nil, bundle: nil)
        super.modalPresentationStyle = .overFullScreen
        super.modalPresentationCapturesStatusBarAppearance = true
        self.bindHero()
    }
    
    let viewModel: ListViewModel
    var cancelHandler: (() -> Void)?
    var confirmHandler: ((UIViewController?, Keypair) -> Void)?
    override var interactivePopIsEnabled: Bool { false }
    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindListView()
        bindTitleAnimation()
    }
    
    private func bindTitleAnimation() {
        wk.view.titleAnimator.bind(listView)
        view.wk.bindLineDisplay(listView, maxOffset: wk.view.navBarHeight)
    }
}


extension SelectWalletConnectAccountController: UITableViewDataSource, UITableViewDelegate {

    private var listView: UITableView { wk.view.listView }
    private func bindListView() {
        
        listView.register(Cell.self, forCellReuseIdentifier: "cell")
        listView.register(ListHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        listView.register(ListFooter.self, forHeaderFooterViewReuseIdentifier: "footer")
        
        listView.delegate = self
        listView.dataSource = self
        
        weak var welf = self
        wk.view.closeButton.action {
            Router.pop(welf) {
                welf?.cancelHandler?()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { viewModel.items[section].header.height }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ListHeader
        let vm = viewModel.items[section].header
        header?.bind(vm)
        if let bag = header?.reuseBag {
            
            header?.view.actionButton.rx.tap.subscribe(onNext: { [weak self] value in
                self?.confirmHandler?(self, vm.account)
            }).disposed(by: bag)
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { viewModel.items[section].footer.height }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as? ListFooter
        footer?.bind(viewModel.items[section].footer)
        if let bag = footer?.reuseBag {
            
            footer?.view.actionButton.rx.tap.subscribe(onNext: { value in
                
                footer?.expandOrFold()
                tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
            }).disposed(by: bag)
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].displayItemCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.items[indexPath.section].items[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        cell.bind(viewModel.items[indexPath.section].items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = viewModel.items[indexPath.section].items[indexPath.row]
        confirmHandler?(self, vm.account)
    }
}


extension SelectWalletConnectAccountController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "SelectWalletConnectAccountController"):  return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self 
        let animator = WKHeroAnimator({ (_) in
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace,
                                                        .useOptimizedSnapshot,
                                                        .translate(y: 1000)
            ]
        }, onSuspend: { (_) in
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
        })
        animators["0"] = animator
    }
}
