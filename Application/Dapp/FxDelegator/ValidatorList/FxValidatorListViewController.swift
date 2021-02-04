//
//
//  XWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == FxValidatorListViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxValidatorListViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let coin = context["coin"] as? Coin else { return nil }
        
        return FxValidatorListViewController(wallet: wallet, coin: coin)
    }
}

class FxValidatorListViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        self.coin = coin
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    private let coin: Coin
    private let wallet: WKWallet
    
    lazy var leftListBinder =  ValidatorsListBinder(view: wk.view.leftListView, searchView: wk.view.searchView)
    lazy var rightListBinder = ValidatorsListRightBinder(view: wk.view.rightListView, searchView: wk.view.searchView2) 
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bindSwitch()
        bindLeftListView()
        bindRightListView()
        bindTitleAnimator()
    }
    
    override func bindNavBar() {
        navigationBar.isHidden = true
        wk.view.closeButton.action { [weak self] in
            Router.pop(self)
        }
    }
    
    private func bindSwitch() {
        wk.view.switchToAll.bind(self, action: #selector(switchTo), forControlEvents: .touchUpInside)
        wk.view.switchToMyAssets.bind(self, action: #selector(switchTo), forControlEvents: .touchUpInside)
        wk.view.switchToMyAssets.isSelected = true
    }
    
    @objc private func switchTo(_ sender: UIButton) {
        
        let isMyAssets = sender == wk.view.switchToMyAssets
        let reduceHeader = leftListBinder.view.contentOffset.y < FullNavBarHeight

        wk.view.switchToAll.isSelected = !isMyAssets
        wk.view.switchToMyAssets.isSelected = isMyAssets
        wk.view.switchIndicator.snp.updateConstraints { (make) in
            make.left.equalTo(isMyAssets ? 4 : 4 + sender.width)
        }

        if !reduceHeader {
            UIView.animate(withDuration: 0.2) {
                self.wk.view.switchView.layoutIfNeeded()
            }
        }

        if isMyAssets {
            rightListBinder.view.endEditing(true)
            bindTitleAnimator()
        } else {
            leftListBinder.view.endEditing(true)
            bindRightTitleAnimator()
        }
        wk.view.contentView.setContentOffset(CGPoint(x: isMyAssets ? 0 : ScreenWidth, y: 0), animated: true)
    }
    
    private func bindLeftListView() {
        let viewModel = ListViewModel(wallet)
        wk.view.hud?.waiting()
        viewModel.itemCount.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self]value in
            if viewModel.isloading {
                self?.wk.view.hud?.hide()
                viewModel.isloading = false
            }
            self?.wk.view.searchView.titleLabel.text = TR("Select.Token.Result", value.s)
            self?.wk.view.leftListView.reloadData()
        }).disposed(by: defaultBag)
        
        
        leftListBinder.didSelected = { [weak self] validator in
            DispatchQueue.main.async {
                self?.wk.view.searchView.inputTF.resignFirstResponder()
                self?.pushToValidatorOverview(validator)
            }
        }
        
        leftListBinder.bind(viewModel)
    }
    
    private func bindRightListView() {

        let viewModel = RightListViewModel(wallet)
        viewModel.itemCount.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self]value in
            self?.wk.view.searchView2.titleLabel.text = TR("Select.Token.Result", value.s)
            self?.wk.view.rightListView.reloadData()
        }).disposed(by: defaultBag)
        
        rightListBinder.didSelected = { [weak self] validator in
            DispatchQueue.main.async {
                self?.wk.view.searchView2.inputTF.resignFirstResponder()
                self?.pushToValidatorOverview(validator)
            }
        }
        rightListBinder.bind(viewModel)
    }
     
    private func pushToValidatorOverview(_ validator: Validator) {
        Router.pushToFxValidatorOverview(wallet: wallet, coin: coin, validator: validator, account: nil)
    }
     
    private func bindTitleAnimator() {
        
        let listView = leftListBinder.view
        let blurOrigin = wk.view.blurContainer.origin.y
        listView.rx.didScroll.subscribe(onNext: { [weak self] _ in

            let interval = min(FullNavBarHeight, max(0, listView.contentOffset.y))
            self?.wk.view.blurContainer.origin.y = blurOrigin - interval
        }).disposed(by: defaultBag)
        wk.view.titleAnimator.bind(listView)
        view.wk.bindLineDisplay(listView)
    }
    
    
    private func bindRightTitleAnimator() {
        let listView = rightListBinder.view
        let blurOrigin = wk.view.blurContainer.origin.y
        listView.rx.didScroll.subscribe(onNext: { [weak self] _ in

            let interval = min(FullNavBarHeight, max(0, listView.contentOffset.y))
            self?.wk.view.blurContainer.origin.y = blurOrigin - interval
        }).disposed(by: defaultBag)
        wk.view.titleAnimator.bind(listView)
        view.wk.bindLineDisplay(listView)
    }
}
        
