//
//
//  XWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 May All rights reserved.
//

import Hero
import WKKit
import BigInt
import RxSwift
import RxCocoa


extension SendTokenCrossChainRecommitController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
              let wallet = context["wallet"] as? WKWallet,
            let account = context["account"] as? Keypair else { return nil }
        
        return SendTokenCrossChainRecommitController(tx: tx, wallet: wallet, account: account)
    }
}

class SendTokenCrossChainRecommitController: FxRegularPopViewController {
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
    
    override var dismissWhenTouch: Bool { false }
    
    override func bindListView() {
        
        let contentCell = listBinder.push(ContentCell.self, vm: tx.to)
        let confirmCell = listBinder.push(ActionCell.self)
        
        let amount = tx.fxProof["claims", "amount", "amount"].string ?? tx.amount
        contentCell.amountLabel.text = "\(amount.div10(tx.coin.decimal).thousandth(tx.coin.decimal)) \(tx.token)"
        contentCell.addressLabel.text = tx.to
        contentCell.closeButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            Router.pop(self)
        }).disposed(by: defaultBag)
        
        confirmCell.confirmButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.doConfirm()
        }).disposed(by: defaultBag)
    }

    private func doConfirm() {
        Router.pushToSendTokenCrossChainCommit(tx: tx, wallet: wallet, account: account)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

/// hero
extension SendTokenCrossChainRecommitController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch to {
        case "SendTokenCrossChainRecommitController": return animators["0"]
        default: return nil
        }
    }

    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ (_) in
            welf?.setBackgoundOverlayViewImage()
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers:[HeroModifier] = [.useGlobalCoordinateSpace,
                             .useOptimizedSnapshot,
                             .translate(y: 1000)]

            welf?.wk.view.contentBGView.hero.modifiers = modifiers
            welf?.wk.view.contentView.hero.modifiers = modifiers
        }, onSuspend: { (_) in
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
        })
        animators["0"] = animator
    }
}


