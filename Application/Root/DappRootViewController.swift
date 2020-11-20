import HapticGenerator
import Hero
import TrustWalletCore
import UIKit
import WKKit

extension WKWrapper where Base == DappPageListViewController {
    var view: DappPageListViewController.View { return base.view as! DappPageListViewController.View }
}

extension DappPageListViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet else { return nil }
        guard let coin = context["coin"] as? Coin else { return nil }
        let viewController = DappPageListViewController(wallet: wallet, coin: coin)
        viewController.bindHero()
        return viewController
    }
}

extension DappPageListViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("DappPageListViewController", "SendTokenInputViewController"): return animators.get(0)
        case ("DappPageListViewController", "SelectOrAddAccountViewController"): return animators.get(0)
        case ("DappPageListViewController", "ReceiveTokenViewController"): return animators.get(0)
        default: return nil
        }
    }

    private func bindHero() {
        weak var welf = self
        let animator0 = WKHeroAnimator({ _ in
            welf?.backgoundView.hero.id = "token_list_background"
            welf?.backgoundView.hero.modifiers = [.useGlobalCoordinateSpace, .fade]
            welf?.buttonBarView.hero.modifiers = [.scale(0.8), .useOptimizedSnapshot, .useGlobalCoordinateSpace,
                                                  .translate(x: 0, y: -200, z: 0)]
            welf?.containerView.hero.modifiers = [.scale(0.8), .useNormalSnapshot, .useGlobalCoordinateSpace,
                                                  .translate(x: 0, y: 1000, z: 0)]
        }, onSuspend: { _ in
            welf?.buttonBarView.hero.modifiers = nil
            welf?.containerView.hero.modifiers = nil
            welf?.backgoundView.hero.id = nil
            welf?.backgoundView.hero.modifiers = nil
        })
        animators.append(animator0)
    }
}
