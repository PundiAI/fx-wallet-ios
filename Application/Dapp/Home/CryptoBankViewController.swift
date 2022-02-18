

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension WKWrapper where Base == CryptoBankViewController {
    var view: Base.View { return base.view as! Base.View }
}
 
open class CryptoBankViewController: WKViewController {

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.viewModel = ViewModel(wallet: wallet)
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = .bottom
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    let viewModel: ViewModel
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    
    private var depositCell: DepositCell?
    private var swapCell: NPXSSwapCell?
    private var stakingCell: FxStakingCell?

    open override func loadView() { view = View(frame: ScreenBounds) }
    open override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindListView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.refresh()
        AAve.current.syncIfNeed()
    }
    
    open override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CryptoBank"))
    }
    
    private func bindListView() {  
        listBinder.push(DelegateCell.self, vm: viewModel.delegateVM)
        self.pushDepositCell()
        listBinder.push(PurchaseCell.self, vm: viewModel.purchaseVM)
        
        let block:()->Void = {[weak self] in
            guard let this = self else { return }

            let count = this.listBinder.itemCount
            if !this.viewModel.fxStakingVM.display {
                this.listBinder.pop(this.stakingCell, refresh: false)
                this.stakingCell = nil
            } else if this.stakingCell == nil {
                this.stakingCell = this.listBinder.push(FxStakingCell.self, vm: this.viewModel.fxStakingVM, at: this.swapCell == nil ? 0 : 1)
            }

            if !this.viewModel.npxsSwapVM.display {
                this.listBinder.pop(this.swapCell, refresh: false)
                this.swapCell = nil
            } else if this.swapCell == nil {
                this.swapCell = this.listBinder.push(NPXSSwapCell.self, vm: this.viewModel.npxsSwapVM, at: 0)
            }

            if count != this.listBinder.itemCount {
                this.listBinder.refresh()
            }
        }

        block()
        viewModel.checkDisplayItems.elements
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                block()
        }).disposed(by: defaultBag)
    }
    
    private func pushDepositCell() {
        
        depositCell = listBinder.push(DepositCell.self, vm: viewModel.depositVM)
        
        depositCell?.hud?.waiting(.fullScreen)
        AAve.current.didSync
            .filter{ $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.depositCell?.hud?.hide()
                self?.depositCell?.reloadIfNeed()
        }).disposed(by: defaultBag)
    }
    
    open override func router(event: String, context: [String : Any]) {
        if event == "buy", let coin = context["coin"] as? Coin {
            Router.showCashBuyController(coin: coin)
        } else if event == "all" {
            Router.pushToAllPurchaseController()
        } else if event == "DelegateDetail" {
            listBinder.refresh()
        }
    }
}
        
