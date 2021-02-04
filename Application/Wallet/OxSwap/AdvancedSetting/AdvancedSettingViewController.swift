//
//
//  XWallet
//
//  Created by May on 2020/12/22.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == AdvancedSettingViewController {
    var view: AdvancedSettingViewController.View { return base.view as! AdvancedSettingViewController.View }
}

extension AdvancedSettingViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet, let handle = context["handler"] as? (CGFloat) -> Void  else { return nil }
        let vc = AdvancedSettingViewController(wallet: wallet)
        vc.handle = handle
        return vc
    }
}

class AdvancedSettingViewController: WKViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    private let wallet: WKWallet
    override func loadView() { view = View(frame: ScreenBounds) }
    var handle: ((CGFloat) -> Void)?
    
    var sliderVaule = BehaviorRelay<CGFloat>(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bind()
    }
    
    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Ox.Advanced.Settings"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }
    
    private func bind() {
        
        var value = "1"
        if let v = wallet.slippagePercentage {
            value = v
        } else {
            wallet.slippagePercentage = value
        }
        
        wk.view.pannel.sliderView.reactiveValue = Float((value.toDouble() - 0.1) / 4.9)
        wk.view.pannel.sliderView.rx.value.subscribe(onNext: {[weak self] (percent) in
            let minPrice: Float = 0.1
            let maxPrice: Float = 4.9
            let price = String(format: "%.1f", minPrice + maxPrice * percent)
            self?.sliderVaule.accept(price.toCGFloat())
            self?.wk.view.pannel.amountLabel.text = price + "%"
        }).disposed(by: defaultBag)
        
        wk.view.saveBtn.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let this = self else { return }
            this.wallet.slippagePercentage = "\(this.sliderVaule.value)"
            this.handle?(this.sliderVaule.value)
            Router.pop(this)
        }).disposed(by: defaultBag)
    }
}
