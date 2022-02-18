//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == CheckBackUpViewController {
    var view: CheckBackUpViewController.View { return base.view as! CheckBackUpViewController.View }
}

extension CheckBackUpViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let mnemonic = context["mnemonic"] as? String else { return nil }
        let vc = CheckBackUpViewController(mnemonic: mnemonic)
        return vc
    }
}

class CheckBackUpViewController: WKViewController {
    
    private let mnemonic: String
    lazy var viewModel = ViewModel(mnemonic: self.mnemonic)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(mnemonic: String) {
        self.mnemonic = mnemonic
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        logWhenDeinit()
    }
    
    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CheckBackUp.Title"))
        navigationBar.action(.back, imageName: "ic_back_black" ) {[weak self] in
            Router.showVerifyStopAlert {[weak self] (error) in
                if let err = error, WKError.success.isEqual(to: err) {
                    Router.pop(self)
                }
            }
        }
    }
    
    private func bind() {
        let temp = "\(viewModel.currentPage) / 3"
        let attri = NSMutableAttributedString.init(string: temp)
        attri.addAttributes([.font: XWallet.Font(ofSize: 24, weight: .bold)], range: NSMakeRange(0, temp.length))
        attri.addAttributes([.foregroundColor: COLOR.title], range: NSMakeRange(0, "\(viewModel.currentPage)".length))
        let bool = viewModel.currentPage == 3
        attri.addAttributes([.foregroundColor: bool ? COLOR.title : COLOR.title.withAlphaComponent(0.3)],
                            range: NSMakeRange("\(viewModel.currentPage)".length, temp.length - "\(viewModel.currentPage)".length))
         
        wk.view.stepLabel.attributedText = attri
        if let tags = viewModel.getRandomTags() {
            wk.view.idxTag = tags.0
            let subTitle = TR("CheckBackUp.SubTitle$", "\(tags.0)")
            subTitle.lineSpacingLabel(wk.view.subtitleLabel)
            wk.view.bindButton(tags: tags.1)
        }
        
        wk.view.copyClosure = { [weak self](idx, selectTag) in
            guard let weakself = self else { return }
            weakself.viewModel.selected.append((idx, selectTag))
            if weakself.viewModel.currentPage == 3 {
                if weakself.viewModel.check() {
                    Router.showBackUpSuccess(completionHandler: { (_) in
                        Router.pop(weakself)
                    }) { (_) in
                        
                        if  Router.isExistInNavigator("SettingsViewController") {
                            Router.popAllButTop{ $0?.heroIdentity == "SettingsViewController" }
                        }
                        else if Router.isExistInNavigator("FxTabBarController") {
                            Router.popAllButTop{ $0?.heroIdentity == "FxTabBarController" }
                        }
                    }
                    XWallet.sharedKeyStore.currentWallet?.wk.isBackuped = true
                } else {
                    Router.showBackUpError(completionHandler:{ (_) in
                        Router.pop(weakself)
                    })
                }
                return
            }
             
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                weakself.viewModel.currentPage += 1
                if let vc: CheckBackUpViewController = Router.checkBackUpController(mnemonic: weakself.mnemonic) as? CheckBackUpViewController {
                       vc.viewModel = weakself.viewModel
                        Router.push(vc) {
                            guard let viewControllers = Router.currentNavigator?.viewControllers, viewControllers.count > 2 else { return }
                            if let vc = viewControllers.get(viewControllers.count - 2) {
                                Router.remove(vc)
                            }
                        }
                        return
                }
            }

        }
    }
    
}

/// Hero
extension CheckBackUpViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        //case (_, "CheckBackUpViewController"):  return animators["0"]
        default: return nil
            
        }
    }
    
    private func bindHero() { 
        weak var welk = self
        let animator = WKHeroAnimator({ _ in
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: 1000),
                                                       .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: 1500),
                                                          .useGlobalCoordinateSpace]
            welk?.wk.view.stepLabel.hero.modifiers = [.fade, .scale(2),
                                                      .useGlobalCoordinateSpace]
            welk?.wk.view.bordView.hero.modifiers = [.translate(x: 2500),
                                                     .useGlobalCoordinateSpace]
            welk?.wk.view.selectdLabel.hero.modifiers = [.translate(x: 3000),
                                                         .useGlobalCoordinateSpace]
            
            welk?.wk.view.tagButtons.each { (index, button) in
                let offsetY = (50 + (10 * Double(index)))
                button.hero.modifiers = [.fade,
                                         .scale(0.8),
                                         .translate(x: CGFloat(offsetY)),
                                         .useGlobalCoordinateSpace]
            }
        }, onSuspend: { _ in
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.stepLabel.hero.modifiers = nil
            welk?.wk.view.bordView.hero.modifiers = nil
            welk?.wk.view.selectdLabel.hero.modifiers = nil
            welk?.wk.view.tagButtons.each { (index, button) in
                button.hero.modifiers = nil
            }
        })
        animators["0"] = animator
    }
}
