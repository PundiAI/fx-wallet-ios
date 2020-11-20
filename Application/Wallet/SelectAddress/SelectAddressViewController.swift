//
//  SelectAddressViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import RxSwift
import TrustWalletCore
import UIKit
import WKKit

extension WKWrapper where Base: SelectAddressViewController {
    var view: SelectAddressViewController.View { return base.view as! SelectAddressViewController.View }
}

class SelectAddressViewController: WKViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet,
            let url = context["url"] as? String else { return nil }

        let coin = context["coin"] as? String ?? ""
        switch coin {
        case "Fx":
            return FxSelectAddressViewController(wallet: wallet, walletConnectURL: url)
        default:
            return nil
        }
    }

    fileprivate let wallet: Wallet
    fileprivate let walletConnectURL: String
    fileprivate lazy var listBinder = WKTableViewBinder<CellViewModel>(view: wk.view.listView)

    fileprivate var selectedItem: CellViewModel? {
        didSet {
            oldValue?.isSelected.accept(false)
            selectedItem?.isSelected.accept(true)
            navigationBar.rightBarButton?.isEnabled = selectedItem != nil
        }
    }

    override func navigationItems(_ navigationBar: WKNavigationBar) {
        navigationBar.action(.right, imageName: "ic_arrow_right_white") { [weak self] () in
            self?.pushToWalletConnect()
        }?.config(config: {
            $0?.disabledImage = IMG("ic_arrow_right_gray")
        })
        navigationBar.rightBarButton?.isEnabled = false
        super.navigationItems(navigationBar)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet, walletConnectURL: String) {
        self.wallet = wallet
        self.walletConnectURL = walletConnectURL
        super.init(nibName: nil, bundle: nil)

        logWhenDeinit()
    }

    override func loadView() { view = View(frame: ScreenBounds) }

    fileprivate func pushToWalletConnect() {
        guard let cellVM = selectedItem else { return }

        Router.manager.pushToFxWalletConnect(url: walletConnectURL,
                                             privateKey: cellVM.privateKey)
    }
}

// MARK: Fx

class FxSelectAddressViewController: SelectAddressViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        bindListView()
        fetchData()
    }

    private func bindListView() {
        let listView = wk.view.listView

        weak var welf = self
        let viewModel = FXListViewModel(wallet)
        listView.viewModels = { _ in

            let result = NSMutableArray()
            for item in viewModel.items {
                if item.address == welf?.selectedItem?.address {
                    welf?.selectedItem = item
                }
                result.push(Cell.self, m: item)
            }
            return result
        }

        // handle error
        listBinder.bindListError = {}
        viewModel.error.filterNil()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [] error in
                welf?.hud?.text(m: error.localizedDescription)
            }).disposed(by: defaultBag)

        listView.didSeletedBlock = { _, indexPath in
            welf?.selectedItem = viewModel.items[indexPath.row]
        }

        listBinder.bind(viewModel)
    }

    private func fetchData() {
        listBinder.refresh()
    }
}
