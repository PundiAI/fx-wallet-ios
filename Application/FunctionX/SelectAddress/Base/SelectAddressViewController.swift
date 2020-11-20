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

class SelectAddressViewController: WKPopViewController {
    let wallet: Wallet

    lazy var viewS = getViewS()
    func getViewS() -> View { return View(frame: ScreenBounds) }

    var listViewModel: ListViewModel { ListViewModel(wallet) }
    lazy var listBinder = WKTableViewBinder<CellViewModel>(view: viewS.listView)

    var confirmHandler: ((UIViewController?, Keypair) -> Void)?

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindNavBar()
        bindListView()
        fetchData()

        layoutUI()
        configuration()
        logWhenDeinit()

        view.layoutIfNeeded()
    }

    var cellClass: Cell.Type { return Cell.self }
    func bindListView() {
        let viewModel = listViewModel

        weak var welf = self
        let cellClass = self.cellClass
        viewS.listView.viewModels = { _ in

            let result = NSMutableArray()
            for item in viewModel.items {
                if item.address == welf?.selectedItem?.address {
                    welf?.selectedItem = item
                }
                result.push(cellClass, m: item)
            }
            return result
        }

        viewS.listView.didSeletedBlock = { _, indexPath in
            welf?.selectedItem = viewModel.items[indexPath.row]
        }

        listBinder.bindListError = {}
        listBinder.bind(viewModel)
        viewS.listView.mj_header = nil
    }

    func bindNavBar() {
        viewS.closeButton.bind(self, action: #selector(onClickClose), forControlEvents: .touchUpInside)
        viewS.confirmButton.bind(self, action: #selector(onClickConfirm), forControlEvents: .touchUpInside)
    }

    var selectedItem: CellViewModel? {
        didSet {
            if selectedItem === oldValue { return }

            oldValue?.isSelected.accept(false)
            selectedItem?.isSelected.accept(true)
            viewS.confirmButton.isEnabled = selectedItem != nil

            #if DEBUG
                print("xxxSelectAddress:", selectedItem?.address ?? "")
            #endif
        }
    }

    @objc func onClickClose() {
        dismiss(animated: true, completion: nil)
    }

    @objc func onClickConfirm() {
        guard let item = selectedItem else { return }

        let account = Keypair(privateKey: item.privateKey, address: item.address, derivationPath: item.derivationPath)
        if confirmHandler == nil {
            dismiss(animated: true, completion: nil)
        } else {
            confirmHandler?(self, account)
        }
    }

    func fetchData() {
        listBinder.refresh()
    }

    // MARK: Utils

    func configuration() {
        transitioning.alertType = .sheet
        transitioningDelegate = transitioning
        contentView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
        viewS.confirmButton.isEnabled = false
    }

    private func layoutUI() {
        backgroundView.gradientBGLayerForPop.frame = ScreenBounds

        viewS.frame = CGRect(x: 8, y: 100, width: ScreenWidth - 8 * 2, height: ScreenHeight - 100)
        viewS.addCorner()

        contentView.addSubview(viewS)
        contentView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalTo(view).inset(8)
            make.height.equalTo(viewS.height)
        }

        viewS.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
