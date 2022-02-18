//
//  SettingsViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import Hero
import RxCocoa
import RxSwift

extension WKWrapper where Base == SettingsViewController {
    var view: Base.View { return base.view as! Base.View }
}

class SettingsViewController: WKViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        logWhenDeinit(tag: "Settings")
    }

    private var wallet: WKWallet? { XWallet.sharedKeyStore.currentWallet?.wk }
    
    private var assetsValue: (Int, [Coin])?
    private var needUpdateAssetsCount: Int { CoinService.current.needUpdateCount }
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindList()
        bindTitleAnimator()
        
        fetchAssetsChangeStatus()
    }
    
    override func bindNavBar() {
        navigationBar.isHidden = true
        wk.view.backButton.action { [weak self] in
            Router.pop(self) 
        }
        wk.view.backButton.tintColor = .black
    }
    
    private func bindList() {
            
        weak var welf = self
        let listView = wk.view.tableView
         
        listView.viewModels = { section in
            guard let this = welf else { return section }
            
            section.push(TopHeaderCell.self) { $0.titleLabel.text = TR("Settings.SectionHeader.Account") }
            section.push(TopCell.self) { $0.type = .security }
            
            let isBackupedValue = this.wallet?.isBackuped ?? false
            let tip = isBackupedValue ? "" : TR("Settings.BackUp.Tip")
            section.push(VariableCell.self, m: tip) { welf?.bind(mnemonicCell: $0) }
            
            section.push(SectionHeaderCell.self) { $0.titleLabel.text = TR("Settings.SectionHeader.Asset") } 
            let value = this.needUpdateAssetsCount > 0 ? TR("Settings.Asset.SubTitle$", this.needUpdateAssetsCount.s) : ""
            section.push(AssetCell.self, m: value) { welf?.bind(assetCell: $0) }
   
            section.push(SectionHeaderCell.self) { $0.titleLabel.text = TR("Settings.SectionHeader.General") }
            section.push(LanguageCell.self) {
                $0.type = .language
                $0.subTitleLabel.text = WKLocale.Shared.language.title
            }
            section.push(Cell.self) { $0.type = .message_set }
            section.push(BottomCell.self) { $0.type = .newtrok }
            
            
            section.push(SectionHeaderCell.self) { $0.titleLabel.text = TR("BTC") }
            section.push(SingleCell.self) { $0.type = .btcAddress }
            section.push(WKSpacingCell.self, m: WKSpacing(32.auto(), 0, .clear))
            
            return section
        }
        
        listView.didSeletedBlock = {(table, idx) in
            guard let cell = table.cellForRow(at: idx as IndexPath) as? Cell else { return }
            table.deselectRow(at: idx as IndexPath, animated: true)
            switch cell.type {
            case .backUpMnemonic:
                welf?.backUpMnemonic()
            case .security:
                Router.pushToSecurity()
            case .deleteWallet:
                welf?.resetWallet()
            case .viewConsensus:
                welf?.viewConsensus()
            case .language:
                Router.showSetLanguageAlert { (item) in
//                    guard let language = item else { return }
                }
            case .currency:
                welf?.hud?.text(m: TR("Coming soon!"))
            case .merchantOption:
                welf?.hud?.text(m: TR("Coming soon!"))
            case .message_set:
                welf?.setMessage()
            case .newtrok:
                Router.showSettingNewtrok()
            case .btcAddress:
                welf?.pushToBTCAddressType()
            default: break
            }
        }
        
        wallet?.event.isBackuped.subscribe(onNext: { [weak self] (isBackuped) in
            self?.wk.view.tableView.reloadData()
        }).disposed(by: defaultBag)
    }
    
    private func bindTitleAnimator() {
        wk.view.titleAnimator.bind(wk.view.tableView)
    }
    
    private func bind(mnemonicCell cell: VariableCell) {
        cell.type = .backUpMnemonic
    }
    
    private func bind(assetCell cell: AssetCell) {
        cell.type = .asset
        cell.dataType = needUpdateAssetsCount > 0 ? .update : .updated
        cell.stateButton.rx.tap.subscribe(onNext: { [weak self](_) in
            guard cell.dataType == .update else { return }
            cell.dataType = .updating
            if let value = self?.assetsValue {
                CoinService.current.sync(batchNum: value.0, items: value.1)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self?.wk.view.tableView.reloadData()
                }
            }
        }).disposed(by: cell.reuseBag)
    }
    
    private func fetchAssetsChangeStatus() {
        
        let service = CoinService.current
        service.fetchLatestItems.elements.take(1).subscribe(onNext: { [weak self] value in
            guard value.coinList.count > 0 else { return }
            
            self?.assetsValue = value
            self?.wk.view.tableView.reloadData()
        }).disposed(by: defaultBag)
        service.fetchLatestItems.execute()
    }
    
    private func bind(bioCell cell: BioCell) {
        
        cell.switCh.addTarget(self, action: #selector(bioSwitchDidChange(_:)), for: .valueChanged)
        
        LocalAuthManager.shared
            .userAllowedSingal
            .subscribe(onNext: { cell.switCh.isOn = $0 })
            .disposed(by: cell.reuseBag)
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
            LocalAuthManager.shared.userAllowed = false
        } else {
            Router.showVerifyPasswordAlert() { error in
                LocalAuthManager.shared.userAllowed = error == nil
            }
        }
    }
    
    private func backUpMnemonic() { 
        guard let _wallet = wallet else { return }
        Router.pushToBackUpNotice(wallet: _wallet)
    }
    
    private func viewConsensus() {
//        guard let _wallet = wallet else { return }
//        Router.pushViewConsensus(wallet: _wallet)
    }
    
    private func resetWallet() {
        guard let _wallet = wallet else { return }
        Router.pushToResetWallet(wallet: _wallet)
    }
    
    private func setCurrency() {
        guard let _wallet = wallet else { return }
        Router.pushToSetCurrency(wallet: _wallet)
    }
    
    private func setMessage() {
        guard let _wallet = wallet else { return }
        Router.pushToMessageSet(wallet: _wallet)
    }
    
    private func pushToBTCAddressType() {
        guard let wallet = self.wallet else { return }
        Router.pushToBTCAddressType(wallet: wallet)
    }
}
