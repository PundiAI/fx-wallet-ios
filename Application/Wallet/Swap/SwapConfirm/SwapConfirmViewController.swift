import RxCocoa
import RxSwift
import TrustWalletCore
import Web3
import WKKit
extension WKWrapper where Base == SwapConfirmViewController {
    var view: SwapConfirmViewController.View { return base.view as! SwapConfirmViewController.View }
}

extension SwapConfirmViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet,
            let vm = context["vm"] as? SwapModel, let amountsModel = context["amountsModel"] as? AmountsModel else { return nil }
        let vc = SwapConfirmViewController(wallet: wallet, vm: vm, amountsModel: amountsModel)
        return vc
    }
}

class SwapConfirmViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, vm: SwapModel, amountsModel: AmountsModel) {
        self.wallet = wallet
        viewModel = vm
        self.amountsModel = amountsModel
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    private let wallet: WKWallet
    private let viewModel: SwapModel
    private let amountsModel: AmountsModel
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindList()
        bindAction()
        logWhenDeinit()
    }

    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Button.ConfirmSwap"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }

    private func bindList() {
        wk.view.listView.viewModels = { [weak self] section in
            guard let amountsModel = self?.amountsModel else { return section }
            section.push(TokenPanelCell.self, m: amountsModel)
            section.push(TipViewCell.self, m: amountsModel)
            section.push(SwapViewController.FeeCell.self, m: amountsModel)
            return section
        }
    }

    private func bindAction() {
        wk.view.startButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.swap()
        }).disposed(by: defaultBag)
    }

    func swap() {
        var _amount = BigUInt(0)
        var _amo = BigUInt(0)
        switch amountsModel.amountsType {
        case .in:
            _amount = BigUInt(amountsModel.to.inputBigValue)!
            _amo = BigUInt(amountsModel.from.inputBigValue.mul(String(1 + 0.005), 0))!
        case .out:
            _amount = BigUInt(amountsModel.to.inputBigValue.mul(String(1 - 0.005), 0))!
            _amo = BigUInt(amountsModel.from.inputBigValue)!
        case .null:
            break
        }
        let toAccount = amountsModel.to.account
        let fromAccount = amountsModel.from.account
        let fromToken = amountsModel.from.token
        let toToken = amountsModel.to.token
        var from = fromToken.contract
        var to = toToken.contract
        if fromToken.isETH {
            from = SwapViewController.WETHContract
        }
        if toToken.isETH {
            to = SwapViewController.WETHContract
        }
        var tx: EthereumTransaction?
        print("\(amountsModel.amountsType)  _amount : \(_amount) _amo : \(_amo)")
        let deadline = BigUInt((NSDate().timeIntervalSince1970 + 15 * 60) * 1000)
        guard let ethPrivateKey = try? EthereumPrivateKey(hexPrivateKey: fromAccount.privateKey.data.hexString) else {
            print("privateKey is invalid")
            return
        }
        if amountsModel.amountsType == .out {
            if fromToken.isETH, !toToken.isETH {
                tx = UniswapV2.Router02.swapExactETHForTokens(privateKey: ethPrivateKey,
                                                              path: [from, to],
                                                              to: toAccount.address,
                                                              amount: _amount,
                                                              amo: _amo,
                                                              deadline: deadline)
            } else if !fromToken.isETH, toToken.isETH {
                tx = UniswapV2.Router02.swapExactTokensForETH(privateKey: ethPrivateKey,
                                                              path: [from, to],
                                                              to: toAccount.address,
                                                              amount: _amount,
                                                              amo: _amo,
                                                              deadline: deadline)
            } else if !fromToken.isETH, !toToken.isETH {
                var paths = [from, to]
                paths = SwapPairManager.shared.getPairs(fromToken: from, toToken: to)
                print(">>>>>>>> \(paths)")
                tx = UniswapV2.Router02.swapExactTokensForTokens(privateKey: ethPrivateKey,
                                                                 path: paths,
                                                                 to: toAccount.address,
                                                                 amount: _amount,
                                                                 amo: _amo,
                                                                 deadline: deadline)
            }
        } else {
            if fromToken.isETH, !toToken.isETH {
                tx = UniswapV2.Router02.swapETHForExactTokens(privateKey: ethPrivateKey,
                                                              path: [from, to],
                                                              to: toAccount.address,
                                                              amount: _amount,
                                                              amo: _amo,
                                                              deadline: deadline)
            } else if !fromToken.isETH, toToken.isETH {
                tx = UniswapV2.Router02.swapTokensForExactETH(privateKey: ethPrivateKey,
                                                              path: [from, to],
                                                              to: toAccount.address,
                                                              amount: _amount,
                                                              amo: _amo,
                                                              deadline: deadline)
            } else if !fromToken.isETH, !toToken.isETH {
                var paths = [from, to]
                paths = SwapPairManager.shared.getPairs(fromToken: from, toToken: to)
                tx = UniswapV2.Router02.swapTokensForExactTokens(privateKey: ethPrivateKey,
                                                                 path: paths,
                                                                 to: toAccount.address,
                                                                 amount: _amount,
                                                                 amo: _amo,
                                                                 deadline: deadline)
            }
        }
        guard let txTran = tx else {
            return
        }
        hud?.waiting()
        let bulidTx = UniswapV2.Router02.buildEthTx(txTran, fromCoin: fromToken, wallet: wallet.rawValue)
        _ = bulidTx.subscribe(onNext: { tx in
            self.hud?.hide()
            Router.pushToSendTokenFee(tx: tx, account: fromAccount) { error, json in
                print("json :  \(json)")
                if WKError.canceled.isEqual(to: error) {
                    Router.pushToSwap(wallet: self.wallet) { [self] vc in
                        Router.setRootController(wallet: wallet.rawValue,
                                                 viewControllers: [vc])
                    }
                }
            }
        }, onError: { e in
            self.hud?.hide()
            print(">>>>>>>> \(e)")
        }).disposed(by: defaultBag)
    }
}

extension SwapConfirmViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SwapConfirmViewController", "SendTokenFeeViewController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() { animators["0"] = WKHeroAnimator.Share.push()
    }
}
