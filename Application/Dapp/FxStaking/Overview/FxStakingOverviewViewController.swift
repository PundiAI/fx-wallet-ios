

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == FxStakingOverviewViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension FxStakingOverviewViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
              let npxs = context["npxs"] as? Coin,
              let fx = context["fx"] as? Coin else { return nil }
        
        return FxStakingOverviewViewController(wallet: wallet, npxs: npxs, fx: fx)
    }
}

class FxStakingOverviewViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, npxs: Coin, fx: Coin) {
        self.viewModel = ViewModel(wallet: wallet, npxs: npxs, fx: fx)
        super.init(nibName: nil, bundle: nil)
    }
    
    let viewModel: ViewModel
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    
    private var accountCell = AccountCell()
    private lazy var npxsCell = StakingCell()
    private lazy var fxCell = StakingCell()
    
    private var timer: Timer?
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindAccount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshIfNeed()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("FxStaking.Title")) 
    }
    
    private func bindAccount() {
        
        weak var welf = self
        listBinder.push(accountCell, vm: accountCell)
        
        let rewardsCoin = viewModel.rewardsCoin
        let exchangeRate = rewardsCoin.symbol.exchangeRate()
        Observable.combineLatest(viewModel.totalRewards, exchangeRate.value)
            .subscribe(onNext: { (value, rate) in
                
                welf?.accountCell.rewardsLabel.text = "\(value.div10(rewardsCoin.decimal).thousandth()) \(rewardsCoin.token)"
                if !rate.isUnknown {
                    welf?.accountCell.legalRewardsLabel.text = "$\(value.div10(rewardsCoin.decimal).mul(rate.value).thousandth(ThisAPP.CurrencyDecimal, isLegal: true))"
                }
        }).disposed(by: defaultBag)
        
        accountCell.addressActionButton.action {
            guard let this = welf else { return }
            
            Router.pushToSelectWalletConnectAccount(wallet: this.viewModel.wallet, filter: { (c,_) in this.viewModel.filter(coin:c) }) { (vc, account) in
                Router.pop(vc)
                
                if welf?.accountCell.state != .selected {
                    welf?.accountCell.state = .selected
                    welf?.bindStaking()
                }
                
                welf?.accountCell.addressLabel.text = account.address
                welf?.viewModel.accept(account: account)
            }
        }
    }
    
    private func bindStaking() {
        
        bindStaking(viewModel.npxsVM)
        bindStaking(viewModel.fxVM)
        listBinder.refresh()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true, block: { [weak self](_) in
            self?.viewModel.refreshIfNeed()
        })
    }
    
    private func bindStaking(_ vm: StakingCellViewModel) {
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        let cell = listBinder.push(StakingCell.self)
        
        let coin = vm.coin
        let rewardsCoin = viewModel.rewardsCoin
        
        cell.tokenLabel.text = coin.token
        cell.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
        vm.apyText.asDriver()
            .drive(cell.apyLabel.rx.attributedText)
            .disposed(by: cell.reuseBag)
        
        vm.account.subscribe(onNext: { value in
            cell.avaStakeLabel.text = "\(unknownAmount) \(coin.token)"
            cell.legalAvaStakeLabel.text = "$\(unknownAmount)"
            cell.stakedLabel.text = "\(unknownAmount) \(coin.token)"
            cell.legalStakedLabel.text = "$\(unknownAmount)"
            cell.rewardsLabel.text = "\(unknownAmount) \(rewardsCoin.token)"
            cell.legalRewardsLabel.text = "$\(unknownAmount)"
            cell.lockedLabel.text = "\(unknownAmount) \(rewardsCoin.token)"
            cell.legalLockedLabel.text = "$\(unknownAmount)"
        }).disposed(by: cell.reuseBag)
        
        let exchangeRate = vm.coin.symbol.exchangeRate()
        let rewardsExchangeRate = rewardsCoin.symbol.exchangeRate()
        bindLabel(vm.avaStake, exchangeRate, coin, cell.avaStakeLabel, cell.legalAvaStakeLabel, cell.reuseBag)
        bindLabel(vm.staked, exchangeRate, coin, cell.stakedLabel, cell.legalStakedLabel, cell.reuseBag)
        bindLabel(vm.rewards, rewardsExchangeRate, rewardsCoin, cell.rewardsLabel, cell.legalRewardsLabel, cell.reuseBag)
        bindLabel(vm.locked, rewardsExchangeRate, rewardsCoin, cell.lockedLabel, cell.legalLockedLabel, cell.reuseBag)

        cell.avaStakeActionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let this = self else { return }
            Router.pushToFxStake(wallet: this.viewModel.wallet, coin: coin, account: vm.account.value)
        }).disposed(by: cell.reuseBag)
        
        cell.stakedActionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let this = self else { return }
            Router.pushToFxRedeem(wallet: this.viewModel.wallet, coin: coin, account: vm.account.value)
        }).disposed(by: cell.reuseBag)
        
        cell.rewardsActionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.pushToFxClaim(coin: coin, account: vm.account.value)
        }).disposed(by: cell.reuseBag)
    }
    
    private func pushToFxClaim(coin: Coin, account: Keypair) {
        
        let key = "didShowFxClaim"
        let wallet = viewModel.wallet
        if UserDefaults.standard.bool(forKey: key) {
            Router.pushToFxClaim(wallet: wallet, coin: coin, account: account)
        } else {
            
            let alert = FxClaimAlertController()
            Router.present(alert)
            
            alert.confirmHandler = { vc in
                
                UserDefaults.standard.setValue(true, forKey: key)
                Router.dismiss(vc, animated: false) {
                    Router.pushToFxClaim(wallet: wallet, coin: coin, account: account)
                }
            }
        }
    }
    
    private func bindLabel(_ source: BehaviorRelay<String>, _ exchangeRate: ExchangeRate, _ coin: Coin, _ label: UILabel, _ legalLabel: UILabel, _ bag: DisposeBag) {
        
        Observable.combineLatest(source, exchangeRate.value)
            .subscribe(onNext: { (value, rate) in
                guard !value.isUnknownAmount else { return }
                
                label.text = "\(value.div10(coin.decimal).thousandth()) \(coin.token)"
                if !rate.isUnknown {
                    legalLabel.text = "$\(value.div10(coin.decimal).mul(rate.value).thousandth(ThisAPP.CurrencyDecimal, isLegal: true))"
                }
        }).disposed(by: bag)
    }
    
    deinit {
        timer?.invalidate()
    }
}
        
