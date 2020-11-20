import Hero
import SwiftyJSON
import TrustWalletCore
import WKKit
extension SendTokenFeeViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let tx = context["tx"] as? FxTransaction,
            let account = context["account"] as? Keypair else { return nil }
        let vc = SendTokenFeeViewController(tx: tx, account: account)
        vc.completionHandler = context["handler"] as? (WKError?, JSON) -> Void
        return vc
    }
}

class SendTokenFeeViewController: FxRegularPopViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(tx: FxTransaction, account: Keypair) {
        self.tx = tx
        self.account = account
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    let tx: FxTransaction
    var coin: Coin { tx.coin }
    let account: Keypair
    private var completionHandler: ((WKError?, JSON) -> Void)?
    var noticeCell = SendTokenFeeNoticeCell(style: .default, reuseIdentifier: "")
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() {
        let feeVM = WKTableViewCell.FeeCellViewModel(tx: tx)
        var optionsCell: OptionsCell?
        let amountCell = listBinder.push(AmountCell.self)
        listBinder.push(WKTableViewCell.FeeCell.self, vm: feeVM)
        if tx.coin.isEthereum || tx.isDepositETHBusiness { optionsCell = listBinder.push(OptionsCell.self) }
        let nextCell = listBinder.push(SendTokenFeeNextCell.self)
        optionsCell?.actionButton.action { [weak self] in
            guard let this = self else { return }
            Router.pushToSendTokenFeeOptions(tx: this.tx, account: this.account, contentHeight: this.contentHeight, completionHandler: this.completionHandler)
        }
        nextCell.submitButton.action { [weak self] in
            guard let this = self else { return }
            Router.showBroadcastTxAlert(tx: this.tx, privateKey: this.account.privateKey, completionHandler: { error, result in
                if let handler = self?.completionHandler {
                    handler(error, result)
                } else if WKError.canceled.isEqual(to: error) {
                    if result.count == 0 {
                        Router.pop(to: "SendTokenInputViewController")
                    } else if Router.canPop(to: "TokenInfoViewController") {
                        Router.pop(to: "TokenInfoViewController")
                    } else {
                        Router.popToRoot()
                    }
                }
            }, completion: { _ in
                if Router.isExistInNavigator("SendTokenInputViewController") {
                    Router.popAllButTop { $0?.heroIdentity == "SendTokenInputViewController" }
                }
            })
        }
        wk.view.closeButton.action { [weak self] in if let handler = self?.completionHandler {
            handler(.canceled, [:])
        } else {
            Router.pop(self)
        }
        }
        feeVM.speed.subscribe(onNext: { [weak self] _ in
            guard let this = self else { return }
            let coin = this.coin
            let fee = feeVM.fee.div10(coin.feeDecimal)
            let feeSymbol = this.coin.feeSymbol.uppercased()
            var spend = feeVM.fee
            if coin.isETH {
                spend = this.tx.amount.add(feeVM.fee)
            }
            this.tx.set(fee: feeVM.fee, denom: this.tx.feeToken)
            this.tx.gasPrice = feeVM.gasPrice
            let exchangeRate = feeSymbol.exchangeRate().value.value
            amountCell.amountLabel.text = "\(fee.thousandth(4)) \(feeSymbol)"
            if !exchangeRate.isUnknown {
                amountCell.legalAmountLabel.wk.set(amount: fee.mul(exchangeRate.value))
            }
            let isInsufficient = spend.isGreaterThan(decimal: this.tx.balance)
            nextCell.submitButton.isEnabled = !isInsufficient
            if !isInsufficient {
                this.listBinder.pop(this.noticeCell)
            } else {
                var total = TR("SendToken.Fee.Total$$$$", spend.div10(coin.decimal).thousandth(4), feeSymbol, fee.thousandth(4), feeSymbol)
                let balance = TR("Balance") + ": \(this.tx.balance.div10(coin.decimal).thousandth(4)) \(feeSymbol)"
                if this.coin.isERC20 {
                    total = TR("SendToken.Fee.Total$$", fee.thousandth(4), feeSymbol)
                }
                this.noticeCell.totalLabel.text = "\(total)\n\(balance)"
                this.noticeCell.balanceLabel.text = balance
                if this.listBinder.index(of: this.noticeCell) == nil {
                    this.listBinder.push(this.noticeCell)
                    this.listBinder.refresh()
                }
            }
            this.updateContentHeight()
        }).disposed(by: defaultBag)
    }

    override func layoutUI() {
        super.layoutUI()
        view.backgroundColor = .clear
        wk.view.backgroundButton.backgroundColor = .white
        wk.view.navBar.relayoutForPopTitle()
        wk.view.navBar.backButton.title = TR("SendToken.Fee.Title")
    }
}

extension SendTokenFeeViewController: HeroViewControllerDelegate {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) { case ("SendTokenCommitViewController", "SendTokenFeeViewController"): return animators["0"]
        case ("SendTokenFeeViewController", "SendTokenFeeOptionsViewController"): return animators["1"]
        case ("SendTokenFeeViewController", "BroadcastTxInfoController"): return animators["2"]
        case ("SwapApproveViewController", "SendTokenFeeViewController"): return animators["3"]
        case ("SwapConfirmViewController", "SendTokenFeeViewController"): return animators["3"]
        default: return nil
        }
    }

    private func bindHero() { weak var welf = self
        let onSuspendBlock: (WKHeroAnimator) -> Void = { _ in
            welf?.wk.view.backgroundBlur.hero.id = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentView.hero.id = nil
            welf?.wk.view.contentView.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.navBar.hero.modifiers = nil
            welf?.wk.view.listView.hero.modifiers = nil
        }
        animators["0"] = WKHeroAnimator({ _ in
            welf?.wk.view.backgroundBlur.hero.id = "backgroundView_white"
            welf?.wk.view.backgroundBlur.hero.modifiers = [.useGlobalCoordinateSpace, .useNormalSnapshot, .cornerRadius(36)]
            welf?.wk.view.backgroundButton.hero.modifiers = [.source(heroID: "backgroundView_white"),
                                                             .whenDismissing(.opacity(0)),
                                                             .useOptimizedSnapshot, .cornerRadius(36)]
            welf?.wk.view.contentBGView.hero.id = "backgroundView"
            welf?.wk.view.contentBGView.hero.modifiers = [.useGlobalCoordinateSpace]
            welf?.wk.view.listView.hero.modifiers = [.fade, .scale(0.8), .whenPresenting(.delay(0.15)), .useGlobalCoordinateSpace]
            welf?.wk.view.navBar.hero.modifiers = [.fade, .scale(0.8), .whenPresenting(.delay(0.15)), .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        animators["1"] = WKHeroAnimator({ _ in
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot, .useGlobalCoordinateSpace]
            welf?.wk.view.contentBGView.hero.id = "backgroundView"
            welf?.wk.view.contentBGView.hero.modifiers = [.masksToBounds(true)]
            welf?.wk.view.contentView.hero.modifiers = [.fade, .useGlobalCoordinateSpace, .useOptimizedSnapshot, .translate(x: -1 * ScreenWidth)]
        }, onSuspend: onSuspendBlock)
        animators["2"] = WKHeroAnimator({ _ in
            welf?.wk.view.contentBGView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: 1000)]
            welf?.wk.view.contentView.hero.modifiers = [.scale(0.8), .useGlobalCoordinateSpace, .translate(y: 1000)]
        }, onSuspend: onSuspendBlock)
        animators["3"] = WKHeroAnimator({ _ in
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers: [HeroModifier] = [.useGlobalCoordinateSpace,
                                             .useOptimizedSnapshot,
                                             .translate(y: 1000)]
            welf?.wk.view.contentBGView.hero.modifiers = modifiers
            welf?.wk.view.contentView.hero.modifiers = modifiers
        }, onSuspend: onSuspendBlock)
    }

    func heroWillStartAnimating(transition: HeroTransition) {
        if let contentBGView = transition.context?.snapshotView(for: wk.view.contentBGView),
            let contentView = transition.context?.snapshotView(for: wk.view.contentView)
        {
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentView.size)
            contentBGView.layer.masksToBounds = true
            contentBGView.addSubview(contentView)
        }
    }
}
