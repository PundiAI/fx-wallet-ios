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
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(coin: Coin, account: Keypair?) {
        self.viewModel = CashBuyViewModel(coin: coin)
        super.init(nibName: nil, bundle: nil)
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
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CryptoBank.Cash.Buy") + " \(self.viewModel.coin.token)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputCell.view.inputTF.becomeFirstResponder()
    }
    
    private func bind() {
        inputCell = listBinder.push(CashBuyTxInputCell.self, vm: viewModel)
        confirmCell = listBinder.push(CashBuyConfirmTxCell.self, vm: viewModel)
        
        weak var welf = self
        listBinder.scrollViewDidScroll = { _ in
            welf?.view.endEditing(true)
        }
        
        confirmCell.view.submitButton.action {
            if let vm = welf?.viewModel, let userAddress = vm.addressOb.value?.address,
                let swapAmount = vm.inputTxOb.value {
                let swapAsset = vm.coin.token
                let bigSwapAmount = swapAmount.mul10(vm.coin.decimal)
                welf?.inputCell.view.inputTF.resignFirstResponder()
                if !NodeManager.shared.currentEthereumNode.isMainnet { 
                    Router.showUnSupportNodeAlert(coin: vm.coin)
                }else {
                    Router.showRampWebController(userAddress: userAddress, swapAsset: swapAsset, swapAmount: bigSwapAmount)
                }
            }
        }
    }
}
