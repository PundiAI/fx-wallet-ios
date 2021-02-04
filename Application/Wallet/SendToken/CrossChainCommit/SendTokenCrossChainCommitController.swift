//
//  SendTokenCrossChainCommitController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/12.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import SwiftyJSON
import TrustWalletCore

private typealias InfoCell = WKTableViewCell.InfoCell
private typealias InfoCellViewModel = WKTableViewCell.InfoCellViewModel

extension WKWrapper where Base == SendTokenCrossChainCommitController {
    var view: Base.View { return base.view as! Base.View }
}

extension SendTokenCrossChainCommitController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
              let wallet = context["wallet"] as? WKWallet,
            let account = context["account"] as? Keypair else { return nil }
        
        return SendTokenCrossChainCommitController(tx: tx, wallet: wallet, account: account)
    }
}

class SendTokenCrossChainCommitController: FxRegularPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, wallet: WKWallet, account: Keypair) {
        self.tx = tx
        self.wallet = wallet
        self.account = account
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let wallet: WKWallet
    let account: Keypair
    
    override func getView() -> BaseView { View(frame: ScreenBounds) }
    
    override var dismissWhenTouch: Bool { false }
    override var interactivePopIsEnabled: Bool { false }
    
    private var ethFeeCell: InfoCell?
    override func bindListView() {
        
        let amountText = "\(tx.f2eAmount.div10(tx.coin.decimal).thousandth(tx.coin.decimal)) \(tx.token)"
        wk.view.navSubtitleLabel.text = amountText
            
        listBinder.push(TitleCell.self)
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Amount"), content: amountText, corners: (true, true)))
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        
        listBinder.push(SectionTitleCell.self){
            $0.titleLabel.text = TR("CrossChain.FromFX")
            $0.chainTypeButton.bind(self.tx.coin)
        }
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Address"), content: account.address, corners: (true, false)).subOneInterval())
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Fee"), content: "\(tx.decimalFee.thousandth(tx.coin.decimal)) \(tx.feeToken)", height: 68.auto(), corners: (false, true)))
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(SectionTitleCell.self){
            $0.titleLabel.text = TR("CrossChain.ToETH")
            $0.chainTypeButton.bind(CoinService.current.ethereum)
        }
        listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Address"), content: tx.to, corners: (true, false)).subOneInterval())
        ethFeeCell = listBinder.push(InfoCell.self, vm: InfoCellViewModel(title: TR("Fee"), content: "\(tx.f2eETHFee ?? unknownAmount) ETH", height: 86.auto(), corners: (false, true))){
            $0.detailLabel.attributedText = NSAttributedString(string: TR("EDIT"), attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: HDA(0x5B8FF9), .underlineColor: HDA(0x5B8FF9), .underlineStyle: NSUnderlineStyle.single.rawValue])
        }
        
        listBinder.didSeletedBlock = { [weak self](_,_, cell) in
            guard let cell = cell as? InfoCell else { return }
            
            if cell.detailLabel.attributedText?.string == TR("EDIT") {
                self?.editETHFee()
            }
        }
        
        listBinder.scrollViewDidScroll = { [weak self] listView in
            
            let limit: CGFloat = 108
            let offset = min(limit, max(0, listView.contentOffset.y))
            self?.wk.view.navBar.alpha = (offset * 2) / limit
        }
    }
    
    override func updateContentHeight() {
        
        wk.view.listView.isScrollEnabled = true
        wk.view.contentView.snp.updateConstraints { (make) in
            make.height.equalTo(self.maxContentHeight)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ethFeeCell?.contentLabel.attributedText = NSAttributedString(string: "\(tx.f2eETHFee ?? "~") ETH", attributes: [.font: XWallet.Font(ofSize: 16, weight: .bold)])
    }
    
    override func bindAction() {
        
        weak var welf = self
        wk.view.cancelButton.action { Router.pop(self) }
        
        wk.view.confirmButton.action {
            welf?.doConfirm()
        }
    }
    
    private func editETHFee() {
        Router.pushToSendTokenFee(tx: tx, account: account)
    }
    
    private func doConfirm() {
        
        Router.showBroadcastTxVerifyPassword(tx: tx, privateKey: account.privateKey, completionHandler: { (error, result) in
            
            if WKError.canceled.isEqual(to: error) {
                if result.count == 0 {
                    let vc = Router.currentNavigator?.viewControllers.last
                    Router.pop(vc)
                } else if Router.canPop(to: "TokenInfoViewController") {
                    Router.pop(to: "TokenInfoViewController")
                } else {
                    Router.popToRoot()
                }
            }
        }, completion: { _ in
            if  Router.isExistInNavigator("SendTokenInputViewController") {
                Router.popAllButTop{ $0?.heroIdentity == "SendTokenInputViewController" }
            }
        })
    }
    
    override func layoutUI() {
        super.layoutUI()
        
        view.backgroundColor = .clear
        wk.view.backgroundButton.backgroundColor = .white        
    }
}

/// hero
extension SendTokenCrossChainCommitController : HeroViewControllerDelegate  {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SendTokenCommitViewController",  "SendTokenCrossChainCommitController"):  return animators["3"]
        case ("SendTokenCrossChainCommitController", "SendTokenFeeViewController"):  return animators["3"]
        case (_,  "SendTokenCrossChainCommitController"):  return animators["3"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        
        let onSuspendBlock:(WKHeroAnimator) ->Void = { a in
            welf?.wk.view.backgroundBlur.hero.id = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.id = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.navBar.hero.modifiers = nil
            welf?.wk.view.listView.hero.modifiers = nil
        }
        
        animators["0"] = WKHeroAnimator({ (_) in
            welf?.wk.view.backgroundBlur.hero.id = "backgroundView_white"
            welf?.wk.view.backgroundBlur.hero.modifiers = [.useGlobalCoordinateSpace, .useNormalSnapshot, .cornerRadius(36)]
            welf?.wk.view.backgroundButton.hero.modifiers = [.source(heroID: "backgroundView_white"),
                                                             .whenDismissing(.opacity(0)),
                                                             .useOptimizedSnapshot, .cornerRadius(36)]
            
            welf?.wk.view.contentBGView.hero.id = "backgroundView"
            welf?.wk.view.contentBGView.hero.modifiers = [.useGlobalCoordinateSpace]
 
            welf?.wk.view.listView.hero.modifiers = [.fade, .scale(0.8), .whenPresenting(.delay(0.15)), .useGlobalCoordinateSpace]
            welf?.wk.view.navBar.hero.modifiers = [.fade, .scale(0.8), .whenPresenting(.delay(0.15)), .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        
        animators["1"] = WKHeroAnimator({ (a) in
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.contentBGView.hero.id = "backgroundView"
            welf?.wk.view.contentBGView.hero.modifiers = [.masksToBounds(true)]
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace,.useOptimizedSnapshot, .translate(x: -1 * ScreenWidth)]
        }, onSuspend: onSuspendBlock)
        
        animators["3"] = WKHeroAnimator({ (_) in
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers:[HeroModifier] = [.useGlobalCoordinateSpace,
                             .useOptimizedSnapshot,
                             .translate(y: 1000)]

            welf?.wk.view.contentBGView.hero.modifiers = modifiers
            welf?.wk.view.contentView.hero.modifiers = modifiers
        }, onSuspend: onSuspendBlock)
    }
}
