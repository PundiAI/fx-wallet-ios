//
//  CashBuyViewController.swift
//  fxWallet
//
//  Created by Pundix54 on 2020/12/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == CashBuyViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CashBuyViewController { 
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin else { return nil } 
        return CashBuyViewController(coin: coin, account: nil)
    }
}

class CashBuyViewController: WKViewController {
    let viewModel:CashBuyViewModel
    var rampViewController:UIViewController?
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(coin: Coin, account: Keypair?) {
        self.viewModel = CashBuyViewModel(coin: coin)
        super.init(nibName: nil, bundle: nil)
        setupNotificationObserving()
    }

    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private var inputCell: CashBuyTxInputCell!
    private var confirmCell: CashBuyConfirmTxCell!
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bind()
    }
    
    deinit {
        removeNotificationObserving()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CryptoBank.Cash.Buy") + " \(self.viewModel.coin.token)")
    }
 
    private func bind() {
        inputCell = listBinder.push(CashBuyTxInputCell.self, vm: viewModel)
        confirmCell = listBinder.push(CashBuyConfirmTxCell.self, vm: viewModel)
        
        weak var welf = self
        confirmCell.view.submitButton.action {
            if let vm = welf?.viewModel, let userAddress = vm.addressOb.value?.address {
                let swapAsset = vm.coin.token 
                var enable:Bool = true
                if vm.coin.isETH { enable = NodeManager.shared.currentEthereumNode.isMainnet }
                if vm.coin.isBTC { enable = NodeManager.shared.currentBitcoinNode.isMainnet }

                if enable {
                    welf?.rampViewController = Router.showRampWebController(userAddress: userAddress,
                                                                            swapAsset: swapAsset,
                                                                            swapAmount: "0")
                }else {
                    Router.showUnSupportNodeAlert(coin: vm.coin)
                }
            }
        }
    }
    
    func removeNotificationObserving() {
        NotificationCenter.default.removeObserver(self, name: Ramp.notification, object: nil)
    }
    
    func setupNotificationObserving() {
        NotificationCenter.default.addObserver(forName: Ramp.notification, object: nil, queue: .main)
        { [weak self] (notification) in
            self?.rampViewController?.dismiss(animated: true) {
                self?.showAlert()
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: TR("Dapp.Ramp.Purchase.Finished"), message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: TR("OK"), style: .default))
        present(alert, animated: true)
    }
}
