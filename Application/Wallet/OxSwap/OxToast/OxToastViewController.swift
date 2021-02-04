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
import TrustWalletCore
import Hero

extension OxToastViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let amountsModel = context["amountsModel"] as? OxAmountsModel  else { return nil }
        let vc = OxToastViewController(amountsModel:amountsModel)
        return vc
    }
}

class OxToastViewController: FxRegularPopViewController  {
    override var dismissWhenTouch: Bool { true }
    
    override func getView() -> FxPopViewController.BaseView {
        return BaseView(frame: ScreenBounds).then {
            $0.contentBGView.backgroundColor = .clear
            $0.contentBGView.isHidden = true
            $0.listView.backgroundColor = .clear
            $0.contentView.backgroundColor = HDA(0xF0F3F5)
            $0.contentView.autoCornerRadius = 16
            $0.contentView.layer.masksToBounds = false
            $0.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.contentView.layer.shadowColor = HDA(0x0A0E1D).cgColor
            $0.contentView.layer.shadowOpacity = 0.08
            $0.contentView.layer.shadowRadius = $0.contentView.layer.cornerRadius
            
            $0.contentView.layer.borderWidth = 1
            $0.contentView.layer.borderColor = UIColor.white.cgColor
            
            $0.contentView.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(320.auto())
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(amountsModel: OxAmountsModel) {
        self.amountsModel = amountsModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        logWhenDeinit()
        bindHero()
    }
    
    let amountsModel: OxAmountsModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindListView()
    }
    
    override func bindListView() {
        listBinder.push(ContentCell.self, vm: getTitle()) { [weak self] in self?.bindAction($0)}
    }
    
    private func getTitle() -> String {
        guard let model =  self.amountsModel.price else {
            return ""
        }
        let sources = model.sources.filter { $0.proportion != "0"}
        var  source =  ""
        for item in sources {
            source = item.name + " "  + item.proportion.mul10(2) + "%" + " "
        }
        return TR("Ox.Tip.Title", source)
    }
    
    private func bindAction(_ cell: ContentCell) {
        weak var welf = self
        cell.closeButton.rx.tap.subscribe(onNext: { (_) in
            welf?.dismiss()
        }).disposed(by: cell.reuseBag)
        
        guard let model =  self.amountsModel.price, let price = self.amountsModel.price?.price, let wallet = XWallet.currentWallet?.wk else {
            return
        }
        
        let slippagePercentage = wallet.slippagePercentage ?? "1"
        
        
        let sources = model.sources.filter { $0.proportion != "0"}
        var  source =  ""
        for item in sources {
            source = item.name + " "  + item.proportion.mul10(2) + "%" + " "
        }
        
        let scl = price.isLessThan(decimal: "1") ?  8 : 2
        let _price = price.thousandth(decimal: scl)
        let formatPrice = price.mul10(2).mul(String(1 - "\(slippagePercentage.d/100)".d)).div10(2, scl)
        
        cell.titleLabel.text = TR("Ox.Tip.Title", source)
        let symbol = amountsModel.amountsType == .out ? amountsModel.to.token.symbol : amountsModel.from.token.symbol
        cell.expectedValueLabel.text = "\(_price) \(symbol)"
        cell.minimumValueLabel.text =  formatPrice + " " + symbol
        cell.slippageValueLabel.text = "\(slippagePercentage)%"
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

extension OxToastViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "OxToastViewController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ (_) in
            welf?.setBackgoundOverlayViewImage(for: Router.currentNavigator?.view)
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers:[HeroModifier] = [.useGlobalCoordinateSpace,
                                            .useOptimizedSnapshot, .scale(0), .fade]
            
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
