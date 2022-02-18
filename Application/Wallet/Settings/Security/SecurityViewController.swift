 
import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == SecurityViewController {
    var view: SecurityViewController.View { return base.view as! SecurityViewController.View }
}

class SecurityViewController: WKViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }

    fileprivate lazy var listBinder = WKStaticTableViewBinder(view: wk.view.tableView)
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindTableView()
        logWhenDeinit()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Settings.Security"))
    }
    
    let wallet = XWallet.sharedKeyStore.currentWallet
    
    private func bindTableView() {
        wk.view.backgroundColor = .white
        listBinder.view.backgroundColor = .white
        
        weak var welf = self
        let isTouchID = LocalAuthManager.shared.isAuthTouch
        listBinder.push(BioTypeCell.self, vm: isTouchID ? TR("Security.Bio.TouchSubTitle") : TR("Security.Bio.FaceSubTitle")) {
            welf?.bind(bioCell: $0)
        }
        listBinder.push(BottomCell.self) { welf?.bind(pwdCell: $0)  }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(32.auto(), 0, .clear))
        listBinder.push(StartVerifyCell.self, vm: TR("Security.Start.SubTitle")) { welf?.bind(verifyCell: $0) }
        
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(32.auto(), 0, .clear))
        listBinder.push(SingleCell.self) { $0.type = .deleteWallet}
        
        listBinder.didSeletedBlock = { (table, idx, cell) in
            guard let cell = cell as? Base else { return }
            table.deselectRow(at: idx, animated: true)
            switch cell.type {
            case .password:
                welf?.setPassword()
            case .deleteWallet:
                welf?.resetWallet()
            default: break
                
            }
        }
    }
  
    private func bind(pwdCell cell: BottomCell) {
        cell.type = .password
        if let _ = XWallet.sharedKeyStore.currentWallet?.wk.accessCode {
            cell.titleLabel.text = TR("Settings.Pwd.Change")
        } else {
            cell.titleLabel.text = TR("Settings.Pwd.New")
        }
        
        XWallet.Event.subscribe(.UpdatePwdTitle, { (_, _) in
            cell.titleLabel.text = TR("Settings.Pwd.Change")
        }, disposedBy: defaultBag)
    }
    
    private func bind(bioCell cell: BioTypeCell) {
        
        cell.switCh.addTarget(self, action: #selector(bioSwitchDidChange(_:)), for: .valueChanged)
        
        LocalAuthManager.shared.userAllowedSingal.subscribe(onNext: { value in
            cell.switCh.isOn = value
        }).disposed(by: cell.reuseBag)
        
        LocalAuthManager.shared.isEnabledChanged.subscribe(onNext: { _ in
            cell.switCh.isOn = false
        }).disposed(by: cell.reuseBag)
    }
    
    private func bind(verifyCell cell: StartVerifyCell) {
        cell.switCh.isOn = wallet?.wk.verificationIsRequired == true
        cell.switchBt.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
                self?.verifySwitchDidChange(cell.switCh)
        }).disposed(by: cell.reuseBag)
    }
     
    //MARK: Action
    @objc private func bioSwitchDidChange(_ sender: UISwitch) {
        guard LocalAuthManager.shared.isEnabled else {
            let authId = TR(LocalAuthManager.shared.isAuthFace ? "FaceId" : "TouchId")
            self.hud?.error(m: TR("Settings.$BiometricsDisable",authId))
            LocalAuthManager.shared.userAllowed = false
            return
        }
        if !sender.isOn {
            guard let wallet = XWallet.sharedKeyStore.currentWallet else { return }
            if let _ = wallet.wk.accessCode {
                Router.showSetBioAlert { (error) in
                    if error == nil {
                        LocalAuthManager.shared.userAllowed = false
                    } else {
                        LocalAuthManager.shared.userAllowed = true
                    }
                }
            } else {
                Router.showBiometricsAlert {[weak self] (error) in
                    if error == nil  {
                         self?.setPassword()
                    }
                    LocalAuthManager.shared.userAllowed = true
                }
            }
        } else {
            Router.showSetBioAlert { (error) in
                LocalAuthManager.shared.userAllowed = error == nil
            }
        }
    }
    
    @objc private func verifySwitchDidChange(_ sender: UISwitch) {
        if sender.isOn { 
            sender.setOn(false, animated: true)
            wallet?.wk.verificationIsRequired = false
        } else {
            Router.showVerifyPasswordAlert {[weak self] (error) in
                sender.setOn(error == nil, animated: true)
                self?.wallet?.wk.verificationIsRequired = sender.isOn
            }
        }
    }
    
    private func setPassword() {
        guard let wallet = XWallet.sharedKeyStore.currentWallet else { return }
        Router.showChangePwdAlert(wallet: wallet) { [weak self](error) in
            guard error == nil else { return }
            XWallet.Event.send(.UpdatePwdTitle)
            self?.hud?.success(m: TR("Settings.Security.ActionSuccess"))
        }
    }
    
    private func resetWallet() {
        guard let wallet = XWallet.sharedKeyStore.currentWallet?.wk else { return }
           Router.pushToResetWallet(wallet: wallet)
       }
}
        

/// hero
extension SecurityViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SettingsViewController", "SecurityViewController"): return animators["0"]
            
        default: return nil
        }
    }
    
    private func bindHero() { 
        animators["0"] = WKHeroAnimator.Share.push()
    }
}
