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
import Macaw

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
            $0.mainView.border(Color.white, 1)
                .backgroundColor(Color(0xF0F3F5))
                .cornerRadius(16.auto())
                .borderShaow(x: 0, y: 2, radius: 16.auto(), color: HDA(0x0A0E1D), opacity: 0.08)
                .shadow(x: 0, y: 6, radius: 16.auto(), color: HDA(0x0A0E1D), opacity: 0.08)
                .snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview().offset(-20.auto())
                    make.left.right.equalToSuperview().inset(24.auto())
                    make.height.equalTo(320.auto())
                }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(amountsModel: OxAmountsModel) {
        self.amountsModel = amountsModel
        super.init(nibName: nil, bundle: nil) 
        logWhenDeinit()
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
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        Router.pop(self)
    }
}
