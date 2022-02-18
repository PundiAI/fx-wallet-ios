 
import WKKit
import RxSwift
import TrustWalletCore
import Hero

extension SheetWebViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        let eth = context["eth"] as? (Coin?, String)
        let fx = context["fx"] as? (Coin?, String)
        let ethTofx = context["ethTofx"] as? Bool ?? true
        let vc = SheetWebViewController(fx: fx, eth: eth, ethTofx: ethTofx)
        return vc
    }
}

class SheetWebViewController: FxRegularPopViewController {
    
    var fx: (Coin?, String)?
    var eth: (Coin?, String)?
    
    var ethTofx: Bool = true
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(fx: (Coin?, String)?, eth: (Coin?, String)? , ethTofx: Bool = false ) {
        self.fx = fx
        self.eth = eth
        self.ethTofx = ethTofx
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    override var dismissWhenTouch: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() { 
        listBinder.push(ContentCell.self) { self.bindContent($0) }
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
    
    private func bindContent(_ cell: ContentCell) {
        cell.closeButton.rx.tap.subscribe(onNext: { [weak self](_) in
            Router.pop(self)
        }).disposed(by: cell.defaultBag)
    }
    
    private func bindAction(_ cell: ActionCell) {
        
        if ethTofx {
            cell.ethereum.title = TR("Button.View.Ethereum")
            cell.functionX.title = TR("Button.View.FunctionX")
            
            if let _fx = fx {
                cell.functionX.isEnabled =   _fx.1.length > 0
            }
            if let _eth = eth {
                cell.ethereum.isEnabled = _eth.1.length > 0
            }
            
        } else {
            cell.ethereum.title = TR("Button.View.FunctionX")
            cell.functionX.title = TR("Button.View.Ethereum")
            
            
            if let _fx = fx {
                cell.ethereum.isEnabled =   _fx.1.length > 0
            }
            if let _eth = eth {
                cell.functionX.isEnabled = _eth.1.length > 0
            }
        }
        
        
        cell.ethereum.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            if this.ethTofx {
                this.toWeb(true)
            } else {
                this.toWeb(false)
            }
        }).disposed(by: cell.defaultBag)
         
        cell.functionX.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let this = self else { return }
            if this.ethTofx {
                this.toWeb(false)
            } else {
                this.toWeb(true)
            }
        }).disposed(by: cell.defaultBag)
    }
    
    private func toWeb(_ isEth: Bool) {
        
        if isEth {
            guard let eth = self.eth, let coin = eth.0 else { return }
            Router.showExplorer(coin, path: .hash(eth.1)) { _ in
                if  Router.isExistInNavigator("TokenInfoViewController") {
                    Router.popAllButTop{ $0?.heroIdentity == "TokenInfoViewController" }
                }
            }
            
        } else {
            
            guard let fx = self.fx, let coin = fx.0 else { return }
            Router.showExplorer(coin, path: .hash(fx.1)) { _ in
                if  Router.isExistInNavigator("TokenInfoViewController") {
                    Router.popAllButTop{ $0?.heroIdentity == "TokenInfoViewController" }
                }
            }
        }
    }
    
     
    override func layoutUI() {
        hideNavBar()
    }
}

/// hero
extension SheetWebViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "SheetWebViewController"): return animators["0"]
        case ("SheetWebViewController", "DappWebViewController"): return animators["1"]
        case ("SheetWebViewController", "FxWebViewController"): return animators["1"]
        default: return nil
        }
    }
     
    private func bindHero() {
        animators["0"] = self.heroAnimatorBackgound()
        animators["1"] = self.heroAnimatorDefault()
    }
}

 
