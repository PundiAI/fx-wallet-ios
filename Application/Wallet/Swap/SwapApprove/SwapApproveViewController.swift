import RxCocoa
import RxSwift
import TrustWalletCore
import Web3
import WKKit
extension WKWrapper where Base == SwapApproveViewController {
    var view: SwapApproveViewController.View { return base.view as! SwapApproveViewController.View }
}

extension SwapApproveViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet, let vm = context["vm"] as? SwapModel else { return nil }
        let vc = SwapApproveViewController(wallet: wallet, vm: vm)
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class SwapApproveViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, vm: SwapModel) {
        self.wallet = wallet
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }

    var completionHandler: ((WKError?) -> Void)?
    private let wallet: WKWallet
    private let viewModel: SwapModel
    private var vm: ApproveViewModel?

    lazy var unfold = BehaviorRelay<Bool>(value: false)
    var approveAmount: String?
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindList()
        bindAction()
        logWhenDeinit()
        getPrice()
    }

    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Button.Approve"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }

    private func bindList() {
        weak var weak = self
        wk.view.listView.viewModels = { section in
            guard let this = weak else { return section }
            section.push(InfoCell.self, m: this.getCoin())
            section.push(FeeCell.self, m: this.vm)
            section.push(ApproveSwitchCell.self) {
                $0.view.unfold = weak?.unfold.value ?? false
            }
            if this.unfold.value {
                section.push(PermissionCell.self, m: this.vm)
                section.push(WKSpacingCell.self, m: WKSpacing(16.auto(), 0, .clear))
                section.push(DataCell.self, m: this.vm)
            }
            return section
        }
        wk.view.listView.didSeletedBlock = { table, idx in
            if let _ = table.cellForRow(at: idx as IndexPath) as? ApproveSwitchCell {
                let value = weak?.unfold.value ?? false
                weak?.unfold.accept(!value)
            }
        }
        unfold.asDriver().drive(onNext: { _ in
            weak?.wk.view.listView.reloadData()
        }).disposed(by: defaultBag)
    }

    override func router(event: String, context: [String: Any]) {
        if event == "Edit", let _ = (context[eventSender] as? InfoCell) {
            guard let vm = self.vm else { return }
            Router.pushToApproveEditPermission(wallet: wallet, vm: vm) { [weak self] amount in
                guard let _amount = amount else {
                    self?.convertMoney(nil)
                    return
                }
                self?.convertMoney(_amount)
            }
        }
    }

    private func bindAction() {
        wk.view.startButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.approved()
        }).disposed(by: defaultBag)
    }

    private func convertMoney(_ amount: String?) {
        approveAmount = amount
        guard let fromToken = viewModel.fromV.value?.token else { return }
        var amountTitle = "\(pow(2, 256.d).s) \(fromToken.symbol)"
        if let approveAmount = self.approveAmount {
            vm?.editState.accept(.custom)
            vm?.amount.accept(approveAmount)
            amountTitle = "\(approveAmount) \(fromToken.symbol)"
        } else {
            vm?.amount.accept("")
            vm?.editState.accept(.unlimited)
        }
        vm?.amountTitle.accept(amountTitle)
        wk.view.listView.reloadData()
    }

    private func getCoin() -> String {
        guard let fromToken = viewModel.fromV.value?.token else { return "" }
        return fromToken.symbol
    }

    private func getPrice() {
        guard let fromToken = viewModel.fromV.value?.token,
            let fromAccount = viewModel.fromV.value?.account else { return }
        var amountTitle = "\(pow(2, 256.d).s) \(fromToken.symbol)"
        var subAmount = approveAmount
        if let approveAmount = self.approveAmount {
            subAmount = approveAmount.mul10(fromToken.decimal)
            amountTitle = "\(approveAmount) \(fromToken.symbol)"
            vm?.amount.accept(approveAmount)
        }
        weak var welf = self
        let tx: EthereumTransaction? = viewModel.approveAbi(accountAddress: fromAccount.address, token: fromToken.contract, maxAmount: subAmount)
        guard let txTran = tx else {
            return
        }
        hud?.waiting()
        viewModel.buildEthTx(txTran, fromCoin: fromToken, wallet: wallet.rawValue)
            .subscribe(onNext: { tx in
                welf?.hud?.hide()
                welf?.vm = ApproveViewModel(tx: tx)
                welf?.vm?.approveCoin.accept(fromToken.symbol)
                welf?.vm?.amountTitle.accept(amountTitle)
                welf?.vm?.to.accept(fromAccount.address)
                welf?.vm?.abi.accept(txTran.data.hex())
                if let balance = welf?.viewModel.balanceAmount.value.0 {
                    let scl = balance.div10(fromToken.decimal).isLessThan(decimal: "1") ? 8 : 2
                    welf?.vm?.balance.accept("\(balance.div10(fromToken.decimal, scl).thousandth()) \(fromToken.symbol)")
                }
                welf?.wk.view.listView.reloadData()
            }, onError: { e in
                welf?.hud?.error(m: "\(e.asWKError().msg) not enough money")
            }).disposed(by: defaultBag)
    }

    func approved() {
        guard let fromToken = viewModel.fromV.value?.token, let fromAccount = viewModel.fromV.value?.account else {
            return
        }
        weak var welf = self
        var subAmount = approveAmount
        if let approveAmount = self.approveAmount {
            subAmount = approveAmount.mul10(fromToken.decimal)
        }
        let tx: EthereumTransaction? = viewModel.approveAbi(accountAddress: fromAccount.address,
                                                            token: fromToken.contract, maxAmount: subAmount)
        guard let txTran = tx else {
            return
        }
        hud?.waiting()
        viewModel.buildEthTx(txTran, fromCoin: fromToken, wallet: wallet.rawValue)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { tx in
                welf?.hud?.hide()
                Router.pushToSendTokenFee(tx: tx, account: fromAccount) { error, json in
                    let hash = json["hash"].stringValue
                    if hash.length > 0 {
                        if subAmount == nil {
                            subAmount = "115792089237316195423570985008687907853269984665640564039457584007913129639935"
                        }
                        welf?.viewModel.approvedList.value.add(item: ApprovedModel(token: fromToken.symbol, amount: subAmount!, txHash: hash, coin: tx.coin))
                    }
                    var value = false
                    if json["didRequested"].stringValue == "1" {
                        value = true
                    }
                    if WKError.canceled.isEqual(to: error) {
                        if value {
                            welf?.completionHandler?(.success)
                        } else {
                            welf?.completionHandler?(.canceled)
                        }
                        Router.pop(to: "SwapViewController")
                    }
                }
            }, onError: { e in
                welf?.hud?.error(m: "\(e.asWKError().msg) not enough money")
            }).disposed(by: defaultBag)
    }
}

typealias ApproveViewModel = SwapApproveViewController.ApproveViewModel
extension SwapApproveViewController {
    class ApproveViewModel { lazy var amount = BehaviorRelay<String>(value: "")
        lazy var amountTitle = BehaviorRelay<String>(value: "")
        lazy var to = BehaviorRelay<String>(value: "")
        lazy var abi = BehaviorRelay<String>(value: "")
        lazy var feeTitle = BehaviorRelay<String>(value: "")
        lazy var legalAmountTitle = BehaviorRelay<String>(value: "")
        lazy var approveCoin = BehaviorRelay<String>(value: "")
        lazy var balance = BehaviorRelay<String>(value: "")
        lazy var editState = BehaviorRelay<EditState>(value: .unlimited)
        init(tx: FxTransaction) {
            self.tx = tx
            let coin = tx.coin
            let fee = tx.gasPrice.mul(tx.gasLimit)
            let _feeText = fee.div10(coin.feeDecimal).thousandth(4)
            let feeSymbol = tx.feeToken
            let exchangeRate = feeSymbol.exchangeRate().value.value
            let legalAmount = "$" + fee.div10(coin.feeDecimal).mul(exchangeRate.value).thousandth(2)
            feeTitle.accept("\(_feeText) \(feeSymbol)")
            legalAmountTitle.accept(legalAmount)
        }

        let tx: FxTransaction
    }
}
