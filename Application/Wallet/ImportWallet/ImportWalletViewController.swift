import HDWalletKit
import PromiseKit
import RxCocoa
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
extension WKWrapper where Base == ImportWalletViewController {
    var view: ImportWalletViewController.View { return base.view as! ImportWalletViewController.View }
}

class ImportWalletViewController: WKViewController {
    var margin: CGFloat = 0
    var hAnimator: WKHeroAnimator!
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bindHero()
    }

    lazy var animator: WNavTitlePanScaleAnimator = { let v = WNavTitlePanScaleAnimator(wk.view.titleLabel, endOrigin: CGPoint(x: (ScreenWidth - wk.view.titleLabel.width * 0.5) * 0.5,
                                                                                                                              y: 58 + StatusBarHeight + (NavBarHeight - wk.view.titleLabel.height * 0.5) * 0.5), maxOffset: 58)
    return v
    }()

    override func navigationItems(_ navigationBar: WKNavigationBar) { navigationBar.isHidden = true }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        bindKeyboard()
        logWhenDeinit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wk.view.tagList.tagInputField.resignFirstResponder()
    }

    private func bind() {
        wk.view.tagHeightChangeSubject.filterNil()
            .subscribe(onNext: { [weak self] _, height in
                let _height = max(height, ImportWalletViewController.View.MIN_HEIHGT)
                self?.wk.view.tagList.snp.updateConstraints { make in
                    make.height.equalTo(_height)
                }
                self?.wk.view.layoutIfNeeded()
                let bottom = self?.wk.view.nextBtn.bottom ?? 0
                let contentSize = CGSize(width: ScreenWidth, height: bottom + 24.auto())
                self?.wk.view.contentView.contentSize = contentSize
                self?.wk.view.realview.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: contentSize.height)
            }).disposed(by: defaultBag)

        wk.view.tagChangeSubject.map { (words) -> Bool in
            if ServerENV.current == .dev {
                return true
            } else {
                return [12, 24].contains(words.count)
            }
        }.subscribe(onNext: { [weak self] enable in
            self?.wk.view.tipView.selectedSubject.accept(enable)
            self?.wk.view.nextBtn.isEnabled = enable
        }).disposed(by: defaultBag)

        wk.view.tagChangeSubject.map { (item) -> Bool in
            [12, 24].contains(item.count)
        }.subscribe(onNext: { [weak self] value in
            if value == false { return }
            guard let contentView = self?.wk.view.contentView else { return }
            let bottomOffset = CGPoint(x: 0, y: contentView.contentSize.height - contentView.bounds.size.height + contentView.contentInset.bottom)
            contentView.setContentOffset(bottomOffset, animated: true)
        }).disposed(by: defaultBag)
        wk.view.nextBtn.action { [weak self] in
            self?.importWallet()
        }
        wk.view.nextBtnControl.action { [weak self] in
            self?.importWallet()
        }
        wk.view.closeButton.action { [weak self] in
            self?.stopAction()
        }
        animator.bind(wk.view.contentView)
        wk.view.contentView.rx.didScroll.subscribe(onNext: { [weak self] _ in
            guard let contentY = self?.wk.view.contentView.contentOffset.y, let view = self?.wk.view else { return }
            if contentY >= 58 {
                view.navBar.backgroundColor = UIColor.white
                view.navBar.titleLabel.text = view.titleLabel.text
            } else {
                view.navBar.backgroundColor = UIColor.clear
                view.navBar.titleLabel.text = ""
            }
        }).disposed(by: defaultBag)
    }

    private func stopAction() { Router.showBackAlert()
    }

    private func importWallet() {
        if ServerENV.current == .dev {
            if let tags = wk.view.tagList.tags, tags.count == 0 {
                let menu = "jealous gauge loyal discover potato subway display vacuum aisle initial hedgehog burst flee slab bargain try acquire glimpse inject spawn index picnic input lucky"
                wk.view.tagList.tagArray = NSMutableArray(array: menu.components(separatedBy: " "))
                wk.view.tagList._reloadPreData(false)
                return
            }
        }
        guard let tags = wk.view.tagList.tags else { return }
        let mnemonic = tags.joined(separator: " ")
        var __wallet: Wallet?
        if let wallet = XWallet.currentWallet, wallet.wk.mnemonic == mnemonic {
            __wallet = wallet
        } else {
            guard let wallet = XWallet.sharedKeyStore.import(mnemonic: mnemonic) else {
                hud?.text(m: TR("Import.Action.Failure"), p: .topCenter)
                let errorTags = checkWordLists(words: tags)
                wk.view.tagList.errorAlert(errorTags)
                return
            }
            __wallet = wallet
        }
        guard let _wallet = __wallet?.wk else {
            return
        }
        hud?.waiting()
        importName(_wallet.mnemonic).subscribe(onNext: { [weak self] json in
            self?.hud?.hide()
            let ticket = json["ticket"].stringValue
            if ticket.length > 0 {
                _wallet.registerType = .importT
                Router.pushToSetNickName(wallet: _wallet, ticket: ticket)
            } else {
                let nickName = json["nickName"].stringValue
                let secret = json["secret"].stringValue
                let userId = json["userId"].stringValue
                _wallet.nickName = nickName
                _wallet.secret = secret
                _wallet.userId = userId
                _wallet.createCompleted = .importNickname
                _wallet.registerType = .importT
                self?.wk.view.tagList.tagInputField.resignFirstResponder()
                Router.pushToImportNamed(wallet: _wallet)
            }
        }, onError: { [weak self] e in
            self?.hud?.hide()
            self?.hud?.text(m: e.asWKError().msg, d: 2, p: .topCenter)
        }).disposed(by: defaultBag)
    }

    private func importName(_ mnemonic: String) -> Observable<JSON> {
        return NetworkServer.encrypt.fetchEncrypt().flatMap { (_) -> Observable<JSON> in
            APIManager.fx.fetchSignInfo()
        }.flatMap { self.steptwo($0, mnemonic) }
    }

    private func steptwo(_ json: JSON, _ mnemonic: String) -> Observable<JSON> {
        let singNum = json["singNum"].stringValue
        let singAuthInfo = json["singAuthInfo"].stringValue
        let params = SetNickNameViewController.getAddressAndPubKey(mnemonic: mnemonic)
        return APIManager.fx.addressVerify(address: params.0,
                                           addressPubKey: params.1,
                                           signAuthNum: singNum,
                                           singAuthInfo: singAuthInfo,
                                           privateKey: params.2)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension ImportWalletViewController {
    private func bindKeyboard() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] note in guard let this = self,
                    this.presentedViewController == nil else { return }
                let endFrame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y
                this.margin = margin
                this.wk.view.layoutIfNeeded()
                let contentSize = CGSize(width: ScreenWidth, height: this.wk.view.nextBtn.bottom + 24.auto())
                this.wk.view.contentView.contentSize = contentSize
                UIView.animate(withDuration: 0.2) {
                    this.wk.view.contentView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                                         bottom: endFrame.height, right: 0)
                }
            }).disposed(by: defaultBag)
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.wk.view.contentView.contentInset = UIEdgeInsets.zero
                }
            }).disposed(by: defaultBag)
    }
}

extension ImportWalletViewController {
    private func checkWordLists(words: [String]) -> [String] {
        var temp: [String] = []
        for word in words {
            let eng = WordList.english.words
            if !eng.contains(word) {
                temp.append(word)
            }
        }
        return temp
    }
}

extension ImportWalletViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("WelcomeCreateWalletViewController", "ImportWalletViewController"): return animators["0"]
        case ("ImportWalletViewController", "ImportNamedViewController"): return animators["1"]
        default: return nil
        }
    }

    private func bindHero() { weak var welk = self
        let onSuspendBlock: (WKHeroAnimator) -> Void = { _ in
            welk?.wk.view.navBar.hero.modifiers = nil
            welk?.wk.view.titleLabel.hero.modifiers = nil
            welk?.wk.view.subtitleLabel.hero.modifiers = nil
            welk?.wk.view.tagList.hero.modifiers = nil
            welk?.wk.view.tipView.hero.modifiers = nil
            welk?.wk.view.nextBtn.hero.modifiers = nil
            welk?.wk.view.navBar.titleLabel.hero.modifiers = nil
        }
        animators["0"] = WKHeroAnimator({ _ in
            welk?.wk.view.navBar.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(y: -1000), .useGlobalCoordinateSpace]
            welk?.wk.view.tagList.hero.modifiers = [.translate(y: 1000), .useGlobalCoordinateSpace]
            welk?.wk.view.tipView.hero.modifiers = [.fade, .translate(y: 30), .useGlobalCoordinateSpace]
            welk?.wk.view.nextBtn.hero.modifiers = [.fade, .translate(y: ScreenWidth), .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
        animators["1"] = WKHeroAnimator({ _ in welk?.wk.view.navBar.backButton.hero.modifiers = [.translate(x: 0), .useGlobalCoordinateSpace]
            welk?.wk.view.titleLabel.hero.modifiers = [.translate(x: -1 * ScreenWidth), .useGlobalCoordinateSpace]
            welk?.wk.view.subtitleLabel.hero.modifiers = [.translate(x: -1 * ScreenWidth), .useGlobalCoordinateSpace]
            welk?.wk.view.tagList.hero.modifiers = [.translate(x: -1 * ScreenWidth), .useGlobalCoordinateSpace]
            welk?.wk.view.tipView.hero.modifiers = [.fade, .translate(x: -1 * ScreenWidth), .useGlobalCoordinateSpace]
            welk?.wk.view.nextBtn.hero.modifiers = [.fade, .translate(x: -1 * ScreenWidth), .useGlobalCoordinateSpace]
        }, onSuspend: onSuspendBlock)
    }
}
