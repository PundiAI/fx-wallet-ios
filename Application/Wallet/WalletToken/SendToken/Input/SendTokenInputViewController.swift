

import Hero
import WKKit
import BigInt
import XChains
import RxSwift
import RxCocoa

extension WKWrapper where Base == SendTokenInputViewController {
    var view: SendTokenInputViewController.View { return base.view as! SendTokenInputViewController.View }
}

extension SendTokenInputViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
            let coin = context["coin"] as? Coin else { return nil }
        
        let account = context["account"] as? Keypair
        let receiver = context["receiver"] as? User
        let amount = context["amount"] as? String
        return SendTokenInputViewController(wallet: wallet, coin: coin, amount: amount, account: account, receiver: receiver)
    }
}

class SendTokenInputViewController: WKViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, amount: String? = nil, account: Keypair? = nil, receiver: User? = nil) {
        self.initialAmount = amount
        self.viewModel = ViewModel(wallet: wallet, coin: coin, account: account, receiver: receiver)
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }
    
    let viewModel: ViewModel
    var initialAmount: String?
    private lazy var calculator = CalculatorBinder(size: wk.view.calculatorSize)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindAmount()
        bindAccount()
        bindCalculator()
        
        fetchData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.right, title: "")
        navigationBar.navigationItem.titleView = wk.view.titleView
    }
 
    private func bindAmount() {
        
        weak var welf = self
        wk.view.unitButton.action { welf?.switchUnit() }
        wk.view.maxButton.action {
            if welf?.viewModel.isUSD.value == true { welf?.switchUnit() }
            welf?.calculator.set(number: welf?.viewModel.availableBalance ?? "")
        }
        
        viewModel.ready
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (ready) in
                welf?.wk.view.unitButton.isEnabled = ready
        }).disposed(by: defaultBag)
    }
    
    private func switchUnit() {
        
        let unitButton = wk.view.unitButton
        unitButton.isSelected = !unitButton.isSelected
        unitButton.setTitlePosition(.bottom)
        calculator.clear()
        viewModel.isUSD.accept(unitButton.isSelected)
    }
    
    private func bindAccount() {
        
        let view = wk.view
        let selectedToken = viewModel.selectedToken
        selectedToken.subscribe(onNext: { [weak self](coin) in
            
            view.tokenIV.bind(coin)
            view.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
            view.titleLabel.text = TR("Send")
            view.relayout(token: coin)
            if !coin.node.isMainnet, self?.viewModel.isUSD.value == true {
                self?.switchUnit()
            }
        }).disposed(by: defaultBag)
        
        viewModel.selectedAccount.subscribe(onNext: { [weak self](account) in
            
            view.relayout(hideRemark: account.remark.isEmpty)
            view.remarkLabel.text = account.remark
            view.addressLabel.text = account.address
            self?.calculator.clear()
        }).disposed(by: defaultBag)
        
        viewModel.balance.asDriver()
            .drive(onNext: {
                view.balanceLabel.wk.set(amount: $0, symbol: selectedToken.value.token, power: selectedToken.value.decimal, thousandth: selectedToken.value.decimal, autoTrim: false)
            }).disposed(by: defaultBag)
        
        let enableSwitch = CoinService.current.didSync.value && initialAmount == nil
        view.tokenArrowIV.isHidden = !enableSwitch
        view.switchAccountButton.isEnabled = enableSwitch
        view.switchAccountButton.action { [weak self] in
            guard let this = self else { return }
            
            let vm = this.viewModel
            Router.showSelectAccount(wallet: vm.wallet, current: (selectedToken.value, vm.selectedAccount.value)) { vc, coin, account in
                vm.select(coin, account: account)
                Router.dismiss(vc)
            }
        }
    }
    
    private func bindCalculator() {
        
        wk.view.add(calculator: calculator.view)
        Observable.combineLatest(calculator.result.distinctUntilChanged(), viewModel.selectedToken, viewModel.rate, viewModel.isUSD)
            .subscribe(onNext: { [weak self] (t) in
                guard let this = self else { return }
                let (v, coin, rate, isUSD) = t
                let amount = v.isEmpty ? "0" : v
                let usdDecimal = 2
                DispatchQueue.main.async {
                    
                    let decimalLimit = (isUSD ? usdDecimal : coin.decimal)
                    if amount.count > min(12, decimalLimit) {
                        
                        let components = amount.components(separatedBy: ".")
                        var isOverLimit = components.count == 1 && amount.count > 12
                        if components.count == 2 {
                            
                            let integer = components.first!
                            let decimal = components.last!
                            isOverLimit = integer.count > 12 || decimal.count > decimalLimit
                        }
                        
                        if isOverLimit {
                            self?.wk.view.amountLabel.shake(times: 6, withDelta: 5, speed: 0.03)
                            self?.calculator.back()
                            self?.calculator.okIsEnabled = false
                            return
                        }
                    }
                    
                    let isInsufficient = amount.isGreaterThan(decimal: this.viewModel.availableBalance)
                    self?.wk.view.hideNotice(!isInsufficient)
                    self?.calculator.okIsEnabled = !isInsufficient && this.viewModel.availableBalance.f > 0
                     
                    let point = amount.hasSuffix(".") ? "." : ""
                    let decimal = coin.decimal
                    let amountText = isUSD ? "$\(amount.thousandth(decimal: usdDecimal, autoTrim: false, trimZero: false))\(point)" : "\(amount.thousandth(decimal: decimal, autoTrim: false, trimZero: false))\(point) \(coin.token)"
                    self?.wk.view.updateAmountWidth(amountText)
                    self?.wk.view.amountLabel.text = amountText
                    
                    if rate.isUnknownAmount || amount == "0" {
                        self?.wk.view.exchangeAmountLabel.text = ""
                    } else {
                        let exchangeAmountText = isUSD ? "\(amount.div(rate, decimal).thousandth(decimal, autoTrim: false)) \(coin.token)" : "$\(amount.mul(rate, decimal).thousandth(ThisAPP.CurrencyDecimal, isLegal: true))"
                        self?.wk.view.exchangeAmountLabel.text = exchangeAmountText
                    }
                }
        }).disposed(by: defaultBag)
        
        if let amount = initialAmount { calculator.set(number: amount) }
        calculator.confirmHandler = { [weak self] result in
            guard let this = self else { return }
            
            let tx = FxTransaction([:])
            let coin = this.viewModel.selectedToken.value
            var amount = result
            if this.viewModel.isUSD.value {
                amount = amount.div(this.viewModel.rate.value, coin.decimal)
            }
            amount = amount.mul10(coin.decimal)
            
            tx.coin = coin
            tx.from = this.viewModel.selectedAccount.value.address
            tx.set(amount: amount, denom: coin.symbol)
            if coin.isMainCoin { tx.balance = this.viewModel.balance.value }
            if let receiver = this.viewModel.receiver { tx.receiver = receiver }
            Router.pushToSendTokenCommit(tx: tx, wallet: this.viewModel.wallet, account: this.viewModel.selectedAccount.value)
        }
    }
    
    private func fetchData() {
//        viewModel.refreshItems.execute()
    }
}
    
/// Hero Animator
extension SendTokenInputViewController : HeroViewControllerDelegate {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
//        case ("TokenRootViewController", "SendTokenInputViewController"): return animators["0"]
//        case ("CryptoRootViewController", "SendTokenInputViewController"): return animators["0"]
        case ("SendTokenInputViewController", "SendTokenCommitViewController"): return animators["1"]
        case ("TokenInfoViewController", "SendTokenInputViewController"): return animators["2"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        let onSuspendBlock:(WKHeroAnimator)->Void  = { _ in
            welf?.navigationBar.hero.modifiers = nil
            welf?.wk.view.noticeContainer.alpha = 1
            welf?.wk.view.noticeContainer.hero.modifiers = nil
           
            welf?.wk.view.amountContainer.hero.modifiers = nil
            welf?.wk.view.tokenContainer.hero.modifiers = nil
            welf?.calculator.view.hero.modifiers = nil
            welf?.wk.view.backgoundContainer.hero.modifiers = nil
            welf?.wk.view.backgoundContainer.alpha = 0
        }
        
        let animator0 = WKHeroAnimator({ a in
            welf?.wk.view.noticeContainer.alpha = 0
            welf?.wk.view.hero.modifiers = [.useOptimizedSnapshot]
            welf?.navigationBar.hero.modifiers = [.translate(x: 0, y: -500, z: 0)]
            welf?.wk.view.amountContainer.hero.modifiers = [.translate(x: 0, y: -500, z: 0)]
            welf?.wk.view.tokenContainer.hero.modifiers = [.translate(x: 0, y: -500, z: 0)]
            welf?.calculator.view.hero.modifiers = [.translate(x: 0, y: 500, z: 0)]
        }, onSuspend: onSuspendBlock)
        
        animators["0"] = animator0
    
        let animator1 = WKHeroAnimator({ (_) in
            welf?.wk.view.backgoundContainer.alpha = 1
            let modifiers:[HeroModifier] = [.scale(0.8), .useGlobalCoordinateSpace ,.translate(y:-600)]
            welf?.navigationBar.hero.modifiers = modifiers
            welf?.wk.view.amountContainer.hero.modifiers = modifiers
            welf?.wk.view.tokenContainer.hero.modifiers = modifiers
            welf?.wk.view.noticeContainer.hero.modifiers = modifiers
            welf?.wk.view.backgoundContainer.hero.modifiers = modifiers
            welf?.calculator.view.hero.modifiers = [.translate(x: 0, y: 900, z: 0)]
        }, onSuspend: onSuspendBlock)
        animators["1"] = animator1
        
        animators["2"] = WKHeroAnimator.Share.push()
    }
}
