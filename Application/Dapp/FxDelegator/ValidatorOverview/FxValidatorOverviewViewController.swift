

import WKKit
import RxSwift
import RxCocoa
import DateToolsSwift

extension WKWrapper where Base == FxValidatorOverviewViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxValidatorOverviewViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let coin = context["coin"] as? Coin,
              let validator = context["validator"] as? Validator else { return nil }
        
        let account = context["account"] as? Keypair
        return FxValidatorOverviewViewController(wallet: wallet, coin: coin, validator: validator, account: account)
    }
}

class FxValidatorOverviewViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, validator: Validator, account: Keypair?) {
        self.coin = coin
        self.wallet = wallet
        self.account = account
        self.validator = validator
        super.init(nibName: nil, bundle: nil)
    }
    
    let coin: Coin
    let wallet: WKWallet
    var account: Keypair?
    let validator: Validator
    lazy var listBinder = ListBinder(view: wk.view.listView)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        predisplay()
        bindAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("ValidatorOverview.Title"))
    }
    
    private func predisplay() {
        
        wk.view.relayout(isActive: validator.isActive)
        wk.view.listHeader.statusButton.isActive = validator.isActive
        wk.view.listHeader.validatorIV.setImage(urlString: validator.imageURL, placeHolderImage: IMG("Dapp.Placeholder"))
        wk.view.listHeader.validatorNameLabel.text = validator.validatorName
        wk.view.listHeader.validatorAddressButton.setAttributedTitle(NSAttributedString(string: validator.validatorAddress, attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium), .foregroundColor: COLOR.title, .underlineColor: COLOR.title, .underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        wk.view.listHeader.validatorAddressButton.action { [weak self] in
            guard let this = self else { return }
            Router.showExplorer(this.coin, path: .address(this.validator.validatorAddress))
        }
    }
    
    private func bindAction() {
        
        weak var welf = self
        wk.view.delegateButton.action {
            guard let this = welf else { return }
            
            if this.account != nil {
                Router.pushToFxDelegate(wallet: this.wallet, coin: this.coin, validator: this.validator, account: this.account)
            } else {
                
                let erc20FX = CoinService.current.coin(forSymbol: Coin.ERC20FxSymbol, chain: NodeManager.shared.currentEthereumNode.chainType)
                let filter: (Coin, [String : Any]?) -> Bool = { c,_ in c.id == this.coin.id || c.id == erc20FX?.id }
                Router.showSelectAccount(wallet: this.wallet, current: nil, push: true, filter: filter) { (selectAccountVC, coin, account) in
                    
                    let isFxCore = coin.isFxCore
                    if isFxCore { this.account = account }
                    if isFxCore {
                        Router.pushToFxDelegate(wallet: this.wallet, coin: this.coin, validator: this.validator, account: this.account)
                    } else {
                        Router.pushToERC20ToFxTransferAlert(wallet: this.wallet, coin: coin, account: account)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Router.currentNavigator?.remove([selectAccountVC])
                    }
                }
            }
        }
        
        wk.view.undelegateButton.action {
            guard let this = welf, let account = welf?.account else { return }
            Router.pushToFxUndelegate(wallet: this.wallet, coin: this.coin, validator: this.validator, account: account)
        }
        
        wk.view.rewardsButton.action {
            guard let this = welf, let account = welf?.account else { return }
            Router.pushToFxRewards(wallet: this.wallet, coin: this.coin, validator: this.validator, account: account)
        }
    }
    
    private func bind(_ info: Validator) {
        
        validator.delegateAmount = info.delegateAmount
        validator.delegateReward = info.delegateReward
        validator.delegateRewards = info.delegateRewards
        
        let coin = self.coin
        let header = wk.view.listHeader
        let desc = info.description.isEmpty ? "~" : info.description
        header.validatorDescLabel.text = desc
        header.validatorLinkButton.title = info.webSite.isEmpty ? "~" : info.webSite
        header.stakeLabel.text = info.totalDelegate.div10(coin.decimal).thousandth(ThisAPP.NumberDecimal)
        header.votingPowerLabel.text = TR("ValidatorOverview.VotingPower$", info.votingPowerPercent) + "%"
        header.rewardsLabel.text = String(format: "%.2f%@", info.rewards.f, "%")
        header.myDelegateLabel.text = "\(info.delegateAmount.div10(coin.decimal).thousandth()) \(coin.token)"
        
        header.fxcRewardsTLabel.text = "\(coin.token) \(TR("FXDelegator.Rewards")):"
        header.fxcRewardsLabel.text = "\(info.reward(of: coin.symbol).div10(coin.decimal).thousandth()) \(coin.token)"
        
        header.fxUSDRewardsTLabel.text = "\(Coin.FxUSDSymbol) \(TR("FXDelegator.Rewards")):"
        header.fxUSDRewardsLabel.text = "\(info.reward(of: Coin.FxUSDSymbol).div10(coin.decimal).thousandth()) \(Coin.FxUSDSymbol)"
        
        let showMyDelegate = info.delegateAmount.isGreaterThan(decimal: "0")
        let myDelegateHeight: CGFloat = showMyDelegate ? (header.delegatedContentHeight + 24).auto() : 0
        let descHeight = info.description.height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
        let headerHeight = 8.auto() + (myDelegateHeight + descHeight + 365.auto() + header.foldHeight) + 16.auto()
        if abs(header.height - headerHeight) > 2 {
            wk.view.listView.tableHeaderView = nil
            header.height = headerHeight
            wk.view.listView.tableHeaderView = header
        }
        
        if listBinder.itemCount == 0 {
            
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.SelfStake")
                $0.contentLabel.text = String(format: "%@ / %.2f%@", info.selfDelegate.div10(coin.decimal, 0), info.selfDelegatePercent.f, "%")
            }
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.Validator")
                $0.contentLabel.text = TR("Validator.Block", info.validatorSince)
            }
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.Uptime")
                $0.contentLabel.text = String(format: "%.2f%@", info.uptime.f, "%")
            }
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.CurrentCommissionRate")
                $0.contentLabel.text = String(format: "%.2f%@", info.currentCommissionRate.f, "%")
            }
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.MaxCommissionRate")
                $0.contentLabel.text = String(format: "%.2f%@", info.commissionMaxRate.f, "%")
            }
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.MaxDailyCommissionChange")
                $0.contentLabel.text = String(format: "%.2f%@", info.maxDailyCommissionChange.f, "%")
            }
            listBinder.push(Cell.self) {
                $0.titleLabel.text = TR("ValidatorOverview.LastCommissionChange")
                $0.contentLabel.text = Date(timeIntervalSince1970: Double(info.lastCommissionChange) / 1000).formattedText
            }
            listBinder.refresh()
            
            let foldButton = header.foldButton
            foldButton.action { [weak self] in
                foldButton.inactiveAWhile(1)
                foldButton.isSelected = !foldButton.isSelected
                header.relayout(expand: foldButton.isSelected)
                self?.listBinder.expand(foldButton.isSelected)
            }
        }
        
        if showMyDelegate {
            header.relayoutForMyDelegate()
            wk.view.relayoutForMutilActions()
        }
    }
    
    private func fetchData() {
        
        weak var welf = self
        if listBinder.itemCount == 0  { self.hud?.waiting() }
        FxAPIManager.fx.fetchValidatorInfo(validatorAddress: validator.validatorAddress, delegateAddress: account?.address ?? "").subscribe(onNext: { value in
            self.hud?.hide()
            welf?.bind(value)
        }, onError: { (e) in
            self.hud?.hide()
            welf?.hud?.text(m: e.asWKError().msg)
        }).disposed(by: defaultBag)
    }
}
