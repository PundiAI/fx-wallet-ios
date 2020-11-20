import RxCocoa
import RxSwift
import WKKit
extension WKWrapper where Base == ResetWalletViewController {
    var view: ResetWalletViewController.View { return base.view as! ResetWalletViewController.View }
}

extension ResetWalletViewController { override class func instance(with context: [String: Any]) -> UIViewController? {
    guard let wallet = context["wallet"] as? WKWallet else { return nil }
    let vc = ResetWalletViewController(wallet: wallet)
    return vc
}
}

class ResetWalletViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    fileprivate lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    private let wallet: WKWallet
    fileprivate lazy var viewModel = ViewModel()
    lazy var defaultText = BehaviorRelay<String>(value: "")
    var scrollToTop: CGFloat = 0
    var lastPosition: CGFloat = 0
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindListView()
        bindKeyboard()
        logWhenDeinit()
    }

    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("ResetWallet.Title"))
    }

    private func bindListView() {
        wk.view.backgroundColor = .white
        listBinder.view.backgroundColor = .white
        weak var weakself = self
        listBinder.push(Cell.self, vm: viewModel.cellmodel)
        listBinder.push(InputCell.self, vm: viewModel.tipMessage) { weakself?.bindInputCell($0) }
        let height = InputCell.height(model: viewModel.tipMessage)
        let space = (ScreenHeight - FullNavBarHeight - 260) - height
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(space, 0, .clear))
        weakself?.scrollToTop = Cell.height(model: viewModel.cellmodel)
        listBinder.scrollViewDidScroll = { [weak self] table in
            guard let this = self else { return }
            let currentPostion = table.contentOffset.y
            if currentPostion - this.lastPosition > 25 {
                this.lastPosition = currentPostion
            } else if this.lastPosition - currentPostion > 25 {
                this.lastPosition = currentPostion
                this.wk.view.endEditing(true)
            }
        }
    }

    private func bindInputCell(_ cell: InputCell) {
        defaultText.asObservable().bind(to: cell.view.inputTF.rx.text).disposed(by: cell.defaultBag)
        defaultText
            .subscribe {
                if $0.element == self.viewModel.checkMessage ?? "" {
                    cell.view.doneButton.isEnabled = true
                }
            }
            .disposed(by: cell.defaultBag)
        let temp = cell.view.inputTF.rx.text.distinctUntilChanged().map { [weak self] in
            $0 == self?.viewModel.checkMessage ?? ""
        }
        cell.view.inputTF.rx.text.distinctUntilChanged().subscribe(onNext: { [weak self] value in
            let text = value ?? ""
            if text.length > 0 {
                let p = NSPredicate(format: "SELF MATCHES %@", "^[A-Z\\’\\ \\.]*$")
                if !p.evaluate(with: text) {
                    self?.hud?.text(m: TR("ResetWallet.AlertTitle"), p: .topCenter)
                }
            }
        }).disposed(by: cell.defaultBag)
        temp.asObservable()
            .bind(to: cell.view.doneButton.rx.isEnabled)
            .disposed(by: defaultBag)
        cell.view.doneButton.rx.tap.subscribe(onNext: { [weak self] _ in
            Router.showVerifyPasswordAlert { error in
                if error == nil {
                    self?.deleteWallet()
                }
            }
        }).disposed(by: defaultBag)
        if ServerENV.current == .dev {
            cell.view.touchControl.rx.tap.subscribe(onNext: { [weak self] _ in
                self?.defaultText.accept(ResetWalletViewController.resetWalletMessage)
            }).disposed(by: defaultBag)
        }
    }

    private func deleteWallet() {
        guard let wallet = XWallet.sharedKeyStore.currentWallet else { return }
        FxAPIManager.fx.userLogOut().subscribe(onNext: { _ in
            print("")
        }, onError: { [weak self] e in
            self?.hud?.text(m: e.asWKError().msg, p: .topCenter)
        }).disposed(by: defaultBag)
        let error = XWallet.sharedKeyStore.delete(wallet: wallet)
        if let error = error {
            hud?.text(m: error.localizedDescription)
            Router.resetRootController(wallet: nil, animated: true)
        } else {
            Router.resetRootController(wallet: nil, animated: true).done { _ in
                XWallet.clear(wallet)
            }
        }
    }
}

extension ResetWalletViewController {
    private func bindKeyboard() { NotificationCenter.default.rx
        .notification(UIResponder.keyboardWillShowNotification)
        .takeUntil(rx.deallocated)
        .subscribe(onNext: { [weak self] notif in
            guard let this = self else { return }
            let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let margin = UIScreen.main.bounds.height - endFrame.origin.y
            this.wk.view.listView.snp.updateConstraints { make in
                make.bottom.equalTo(this.view).offset(-margin)
            }
            UIView.animate(withDuration: duration) {
                this.wk.view.listView.setContentOffset(CGPoint(x: 0, y: this.scrollToTop), animated: false)
                this.view.layoutIfNeeded()
            }
            this.lastPosition = this.scrollToTop
        }).disposed(by: defaultBag)
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                this.wk.view.listView.snp.updateConstraints { make in
                    make.bottom.equalTo(this.view)
                }
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
                DispatchQueue.main.async {
                    this.wk.view.listView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                }
            }).disposed(by: defaultBag)
    }
}

extension ResetWalletViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SettingsViewController", "ResetWalletViewController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() { animators["0"] = WKHeroAnimator.Share.push()
    }
}
