 
import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == MessageSetViewController {
    var view: MessageSetViewController.View { return base.view as! MessageSetViewController.View }
}

extension MessageSetViewController {
    class NotifModel {
        private let wallet: WKWallet
        var updateSubject:PublishSubject<()> = PublishSubject<()>()
        var enable:Bool = true
            
        init(wallet:WKWallet) {
            self.wallet = wallet
        }

        var globalState:Bool {
            set {
                wallet.pushState = newValue
                updateSubject.onNext(())
            }
            get { wallet.pushState }
        }
        
        var accountState:Bool {
            set {
                wallet.accountPushState = newValue
                updateSubject.onNext(())
            }
            get { wallet.accountPushState }
        }
        
        var systemState:Bool {
            set {
                wallet.systePushState = newValue
                updateSubject.onNext(())
            }
            get { wallet.systePushState }
        }
    }
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = MessageSetViewController(wallet: wallet)
        return vc
    }
}

class MessageSetViewController: WKViewController {
    private let wallet: WKWallet
    private let vmodel: NotifModel
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        self.vmodel = NotifModel(wallet: wallet)
        super.init(nibName: nil, bundle: nil)
    }  
    var tableView:WKTableView { wk.view.tableView }
    
    override func loadView() { view = View(frame: ScreenBounds) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
        logWhenDeinit()
        bindEvent()
        refreshStatus()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Settings.Message.Settings"))
    }
    
    private func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] (setting) in
            DispatchQueue.main.async {
                switch setting.authorizationStatus {
                case .notDetermined, .denied:
                    self?.vmodel.enable = false
                case .authorized, .provisional, .ephemeral:
                    self?.vmodel.enable = true
                    WKRemoteServer.didRequestRemoteNotif = 1
                @unknown default:
                    self?.vmodel.enable = false
                } 
                self?.tableView.reloadData()
            }
        }
    }
    
    private func bindEvent() {
        XWallet.Event.subscribe(.AppDidBecomeActive, {[weak self] (_, _) in
            self?.refreshStatus()
        }, disposedBy: defaultBag)
        
        self.vmodel.updateSubject.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: defaultBag)
    }
    
    private func bindTableView() {
        wk.view.backgroundColor = .white
        tableView.backgroundColor = .white
        weak var welf = self
        tableView.viewModels = { section in
            guard let model = welf?.vmodel else {
                return section
            }
            
            section.push(NotificationCell.self) { welf?.bind($0)}
            section.push(WKSpacingCell.self, m: WKSpacing(32.auto(), 0, .clear))
            
            if model.enable && model.globalState {
                section.push(AccountSwitchCell.self) {
                    welf?.bind($0)
                }
                section.push(SystemSwitchCell.self) {
                    welf?.bind($0)
                }
            }
            return section
        }
    }
    
    private func bind(_ cell: NotificationCell) {
        cell.switCh.isOn = vmodel.globalState && vmodel.enable
        cell.switchBt.rx.tap.flatMap({ (_) -> Observable<Int> in
            return WKRemoteServer.request()
        }).subscribe(onNext: {[weak self] result in
            switch result {
            case 1:
                let isOn = cell.switCh.isOn
                cell.switCh.isOn = !isOn
                self?.vmodel.enable = true
                self?.updatePushState(!isOn, nil)
            case -1:
                cell.switCh.isOn = false
                self?.openNoticeAlert {
                    cell.switCh.isOn = false
                }
            default:
                break
            }
             
        }).disposed(by: cell.reuseBag)
    }
    
    private func bind(_ cell: AccountSwitchCell) {
        cell.switCh.isOn = vmodel.accountState
        cell.switCh.addTarget(self, action: #selector(accountSwitchDidChange(_:)), for: .valueChanged)
    }
    
    private func bind(_ cell: SystemSwitchCell) {
        cell.switCh.isOn = vmodel.systemState
        cell.switCh.addTarget(self, action: #selector(systemSwitchDidChange(_:)), for: .valueChanged)
    }
    
    //MARK: Action
    private func updatePushState(_ b: Bool, _ completed:( (Bool)->Void )?) {
        self.hud?.waiting()
        APIManager.fx.pushSetStatus(type: .all, isOn: b).subscribe(onNext: { [weak self] (json) in
            guard let weakself = self else { return }
            weakself.hud?.hide()
            weakself.vmodel.globalState = b
            completed?(true)
        }, onError: { [weak self](e) in
            self?.hud?.hide()
            self?.hud?.text(m: e.asWKError().msg)
            self?.vmodel.globalState = !b
            completed?(false)
        }).disposed(by: self.defaultBag)
    }
  
    @objc private func accountSwitchDidChange(_ sender: UISwitch) {
        self.hud?.waiting()
        let isOn = sender.isOn
        APIManager.fx.pushSetStatus(type: .account, isOn: isOn).subscribe(onNext: { [weak self] (json) in
            guard let weakself = self else { return }
            weakself.hud?.hide()
            weakself.vmodel.accountState = isOn
        }, onError: { [weak self](e) in
            self?.hud?.hide()
            self?.hud?.text(m: e.asWKError().msg)
            self?.wallet.accountPushState = !isOn
        }).disposed(by: self.defaultBag)
    }
    
    @objc private func systemSwitchDidChange(_ sender: UISwitch) {
        self.hud?.waiting()
        let isOn = sender.isOn
        APIManager.fx.pushSetStatus(type: .system, isOn: isOn).subscribe(onNext: { [weak self] (json) in
            guard let weakself = self else { return }
            weakself.hud?.hide()
            weakself.vmodel.systemState = isOn
        }, onError: { [weak self](e) in
            self?.hud?.hide()
            self?.hud?.text(m: e.asWKError().msg)
            self?.wallet.systePushState = !isOn
        }).disposed(by: self.defaultBag)
    }
    
    
    func openNoticeAlert( _ completed:( ()->Void )? = nil) {
        let alert = UIAlertController(
            title: TR("Notice.alert.Tip"),
            message: TR("Notice.alert.SubTip"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: TR("NotNow"), style: UIAlertAction.Style.default, handler: { (_) in
            completed?()
        }))
        
        alert.addAction(UIAlertAction(title: TR("Settings.Title"), style: UIAlertAction.Style.default, handler: { (_) in
            completed?()
            if let url = URL(string: "App-Prefs:root=NOTIFICATIONS_ID"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))

        present(alert, animated: true, completion: nil)
    }
}
        
