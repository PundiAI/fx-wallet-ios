//
//  SettingsView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SettingsViewController {
    class View: UIView { 
        lazy var navBar = FxBlurNavBar()
        var backButton: UIButton { navBar.backButton }
        
        fileprivate lazy var tableHeaderView = UIView(size: CGSize(width: ScreenWidth, height: 88.auto()))
        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Settings.Title")
            v.font = XWallet.Font(ofSize: 40, weight: .bold)
            v.autoFont = true
            v.textColor = .black
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var titleAnimator: ScrollScaleAnimator = {
            let v = ScrollScaleAnimator(offset: FullNavBarHeight)
            let s: CGFloat = 0.5
            titleLabel.sizeToFit()
            v.add(PanScaleAnimator(view: titleLabel, endY: StatusBarHeight + (NavBarHeight - titleLabel.height * s) * 0.5, scale: s))
            return v
        }()
        
        fileprivate lazy var versionLabel: UILabel = {
            let v = UILabel()
            
            let version = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
            let shortVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
            #if DEBUG
            v.text = "Beta \(shortVersion) (\(version)) \(ServerENV.current.rawString) \n \(NetworkServer.hosts.api)"
            #else
            v.text = "Beta \(shortVersion) (\(version))"
            #endif
            v.font = XWallet.Font(ofSize: 10)
            v.autoFont = true
            v.textColor = UIColor.black.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.textAlignment = .center
            v.numberOfLines = 2
            v.baselineAdjustment = .alignBaselines
            return v
        }()
        
        lazy var tableView = WKTableView(frame: ScreenBounds, style: .plain)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = HDA(0x0A0E1D) //COLOR.settingbg
            navBar.blur.isHidden = true
            navBar.backgroundColor = UIColor.white
            backButton.tintColor = UIColor.black
            tableView.backgroundColor = UIColor.white
        }
        
        private func layoutUI() {
            
            addSubviews([tableView, navBar, titleLabel])
            
            let height = titleLabel.text?.height(ofWidth: ScreenWidth - 24.auto() * 2, attributes: [.font : XWallet.Font(ofSize: 40, weight: .bold)]) ?? 48
            
            tableHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 40.auto() + height.auto() + FullNavBarHeight)
            tableView.tableHeaderView = tableHeaderView
            tableView.tableFooterView = versionLabel.then { $0.frame = CGRect(x: 0, y: 0, width: 0, height: 72) }
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            tableView.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
            titleLabel.wk.adjust(frame: CGRect(x: 24.auto(), y: FullNavBarHeight +  8.auto(), width: 0, height: 48))
        }
    }
}


extension SettingsViewController {
    class Cell: FxTableViewCell {
        
        enum Types {
            case backUpMnemonic
            case viewConsensus
            case biometrics
            case deleteWallet
            case language
            case asset
            case currency
            case merchantOption
            case security
            case password
            case debug_token
            case debug_log
            case debug_web
            case message_set
            case newtrok
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 72.auto()
        }
        
        var type = Types.backUpMnemonic {
            didSet {
                switch type {
                case .backUpMnemonic:
                    titleLabel.text = TR("Settings.BackUp")
                case .viewConsensus:
                    titleLabel.text = TR("Settings.ViewConsensus")
                case .biometrics:
                    titleLabel.text = TR(LocalAuthManager.shared.isAuthFace ? "FaceId" : "TouchId")
                case .deleteWallet:
                    titleLabel.text = TR("Settings.ResetWallet")
                case .language:
                    titleLabel.text = TR("Settings.Language")
                case .currency:
                    titleLabel.text = TR("Settings.Currency")
                case .merchantOption:
                    titleLabel.text = TR("Settings.Merchant")
                case .security:
                    titleLabel.text = TR("Settings.Security")
                case .password:
                    if let _ = XWallet.sharedKeyStore.currentWallet?.wk.accessCode {
                        titleLabel.text = TR("Settings.Pwd.Change")
                    } else {
                        titleLabel.text = TR("Settings.Pwd.New")
                    }
                case .asset:
                    titleLabel.text = TR("Settings.Asset")
                case .debug_token:
                    titleLabel.text = TR("Settings.Debug.NoticeToken")
                case .debug_log:
                    titleLabel.text = TR("Settings.Debug.ShowLog")
                case .debug_web:
                    titleLabel.text = TR("Web Test")
                case .message_set:
                    titleLabel.text = TR("Settings.Message.Settings")
                case .newtrok:
                    titleLabel.text = TR("Setting.Newtrok.Title")
                }
            }
        }
        
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18)
            v.textColor = COLOR.title
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var redDot: UIView = {
            let v = UIView()
            v.backgroundColor = COLOR.reddot
            v.autoCornerRadius = 5
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var icon: UIImageView = {
            let v = UIImageView()
            v.image = IMG("setting.nextB")
            return v
        }()
        
        lazy var pannel: UIView = {
            let v = UIView(COLOR.settingbc)
            return v
        }()
        
        override func layoutUI() { 
            contentView.addView(pannel)
            pannel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            
            pannel.addSubviews([titleLabel, icon, redDot])
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            
            icon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
            
            redDot.isHidden = true
            redDot.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(icon.snp.left).offset(-8.auto())
                make.size.equalTo(CGSize(width: 10, height: 10).auto())
            }
            
            
        }
    }
}

extension SettingsViewController {
    class TopCell: Cell {
        
        override class func height(model: Any?) -> CGFloat { return 80.auto() }
        
        override func layoutUI() {
            super.layoutUI()
            
            titleLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview().offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            
            icon.snp.remakeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.right.equalTo(-24.auto())
            }
            
            redDot.isHidden = true
            redDot.snp.remakeConstraints { (make) in
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.right.equalTo(icon.snp.left).offset(-24.auto())
                make.size.equalTo(CGSize(width: 10, height: 10).auto())
            }
             
            pannel.autoCornerRadius = 16
            if #available(iOS 11.0, *) {
                pannel.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
            }
        }
    }
}

extension SettingsViewController {
    class BottomCell: Cell {
        
        override class func height(model: Any?) -> CGFloat { return 80.auto() }
        
        override func layoutUI() {
            super.layoutUI()
            
            titleLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview().offset(-4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            
            icon.snp.remakeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview().offset(-4.auto())
                make.right.equalTo(-24.auto())
            }
            
            redDot.isHidden = true
            redDot.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview().offset(-4.auto())
                make.right.equalTo(icon.snp.left).offset(-24.auto())
                make.size.equalTo(CGSize(width: 10, height: 10).auto())
            }
            
            pannel.autoCornerRadius = 16
            
            if #available(iOS 11.0, *) {
                pannel.layer.maskedCorners = [CACornerMask.layerMinXMaxYCorner, CACornerMask.layerMaxXMaxYCorner]
            }  
        }
    }
}

extension SettingsViewController {
    class SingleCell: Cell {
        
        override class func height(model: Any?) -> CGFloat { return 88.auto() }
        
        override func layoutUI() {
            super.layoutUI()
            pannel.autoCornerRadius = 16
        }
    }
}


extension SettingsViewController {
    class BioCell: Cell {
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var switCh: UISwitch = {
            let v = UISwitch()
            v.tintColor = COLOR.switchoff
            v.onTintColor = COLOR.title
            return v
        }()
        
        override func configuration() {
            super.configuration()
            self.selectionStyle = .none
        }
        
        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            self.type = .biometrics
            contentView.addSubview(subTitleLabel)
            contentView.addSubview(switCh)
            
            titleLabel.snp.remakeConstraints { (make) in
                make.bottom.equalTo(contentView.snp.centerY).offset(-4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(20.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(contentView.snp.centerY).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(20.auto())
            }
            
            switCh.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
            
            subTitleLabel.text = TR("Use your face to sign transactions")
        }
    }
}


extension SettingsViewController {
    class HeroDebugCell: Cell {
        
        lazy var switCh: UISwitch = {
            let v = UISwitch()
            v.tintColor = COLOR.switchoff
            v.onTintColor = COLOR.title
            return v
        }()
        
        override func layoutUI() {
            super.layoutUI()
            titleLabel.text = TR("Hero Debug View") 
            contentView.addSubview(switCh)
            switCh.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }
    }
}


extension SettingsViewController {
    class TopHeaderCell: FxTableViewCell {
        
        override class func height(model: Any?) -> CGFloat { return 28.auto() }
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        override func layoutUI() {
            
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
                make.bottom.equalTo(-8.auto())
                make.height.equalTo(20.auto())
            }
        }
    }
}


extension SettingsViewController {
    class SectionHeaderCell: TopHeaderCell {
        
        override class func height(model: Any?) -> CGFloat { return 60.auto() }
        
        override func layoutUI() {
            super.layoutUI()
        }
    }
}

extension SettingsViewController {
    
    class LanguageCell: TopCell {
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.textAlignment = .right
            v.backgroundColor = .clear
            return v
        }()
        
        override func configuration() {
            super.configuration()
            self.selectionStyle = .none
        }
        
        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            self.type = .language
            pannel.addSubview(subTitleLabel)
            subTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }
    }
}




extension SettingsViewController {
    
    class VariableCell: BottomCell {
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subTiptitle
            v.numberOfLines = 0
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            if let value = model as? String, value.length > 0 {
                let width = ScreenWidth - (24 + 51).auto()
                let height = value.height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
                return (24 + 20 + 8).auto() + height + (24 + 8).auto()
            }
            return 80.auto()
        }
        
        override func update(model: Any?) {
            if let value = model as? String, value.length > 0 {
                subTitleLabel.text = value
                subTitleLabel.isHidden = false
            } else {
                subTitleLabel.text = ""
                subTitleLabel.isHidden = true
                
                titleLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(24.auto())
                    make.right.equalTo(-51.auto())
                }
                icon.snp.remakeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 24, height: 24).auto())
                    make.centerY.equalToSuperview()
                    make.right.equalTo(-24.auto())
                }
            }
        }
        
        override func layoutUI() {
            super.layoutUI()
            self.type = .backUpMnemonic
            addSubview(subTitleLabel)
            
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(24.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
            }
            
            
            icon.snp.remakeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview().offset(-4.auto())
                make.right.equalTo(-24.auto())
            }
            
            redDot.isHidden = true
        }
    }
}

extension SettingsViewController {
    
    class AssetCell: SingleCell {
        
        enum DataType {
            case update
            case updating
            case updated
        }
        
        var dataType = DataType.updated {
            didSet {
                switch dataType {
                case .update:
                    stateButton.title = TR("Settings.Asset.StateUpdate")
                    stateButton.autoCornerRadius = 22
                    stateButton.setBackgroundImage(UIImage.createImageWithColor(color: COLOR.title), for: .normal)
                    stateButton.titleColor = .white
                case .updating:
                    stateButton.title = TR("Settings.Asset.StateUpdating")
                    stateButton.autoCornerRadius = 22
                    stateButton.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0xE7E8EB)), for: .normal)
                    stateButton.titleColor = COLOR.title.withAlphaComponent(0.2)
                case .updated:
                    stateButton.title = TR("Settings.Asset.Stateupdated")
                    stateButton.autoCornerRadius = 0
                    stateButton.setBackgroundImage(UIImage.createImageWithColor(color: .clear), for: .normal)
                    stateButton.titleColor = COLOR.subtitle
                }
                relayout()
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            if let value = model as? String, value.length > 0 {
                let width = TR("Settings.Asset").size(with: .zero, font: XWallet.Font(ofSize: 18)).width - 2
                let font:UIFont = UILabel().then {
                       $0.font = XWallet.Font(ofSize: 14)
                       $0.text = value
                       $0.autoFont = true }.font
                let height = value.height(ofWidth: width, attributes: [.font: font])
                return (8 + 24 + 22 + 8).auto() + height + (24 + 8).auto()
            }
            return 88.auto()
        }
        
        override func update(model: Any?) {
            if let value = model as? String {
                subTitleLabel.text = value
            }
        }
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subTiptitle
            v.autoFont = true
            v.numberOfLines = 3
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var stateButton: UIButton = {
            let v = UIButton()
            v.titleLabel?.font = XWallet.Font(ofSize: 18)
            return v
        }()
        
        override func configuration() {
            super.configuration()
            self.selectionStyle = .none
        }
        
        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            self.type = .language
            pannel.addSubviews([subTitleLabel, stateButton])
            
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(pannel).offset((24 + 8).auto())
                make.left.equalToSuperview().offset(24.auto())
                make.right.equalTo(stateButton.snp.left).offset(-10.auto())
                make.height.equalTo(22.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.right.equalTo(titleLabel.snp.right)
            }
            
            stateButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.centerY.equalToSuperview()
                make.height.equalTo(44.auto())
            }
        }
        
        private func relayout() {
            let sizeThatFits = stateButton.titleLabel?.sizeThatFits(CGSize.zero) ?? CGSize.zero
            let titleSizeThatFits = titleLabel.sizeThatFits(.zero)
            switch dataType {
            case .updated,
                 .updating:
                titleLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(pannel)
                    make.left.equalToSuperview().offset(24.auto())
                    make.height.equalTo(22.auto())
                }
                subTitleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel)
                    make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                    make.width.equalTo(titleSizeThatFits.width)
                }
                subTitleLabel.isHidden = true
                let width =  dataType == .updating ? sizeThatFits.width + 44.auto() :  sizeThatFits.width
                
                stateButton.snp.remakeConstraints { (make) in
                     make.right.equalToSuperview().offset(-24.auto())
                     make.width.equalTo(width)
                     make.centerY.equalTo(titleLabel.snp.centerY)
                     make.height.equalTo(44.auto())
                 }
                    break
            default:
                subTitleLabel.isHidden = false
                titleLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(pannel).offset((24 + 8).auto())
                    make.left.equalToSuperview().offset(24.auto())
                    make.right.equalTo(stateButton.snp.left).offset(-10.auto())
                    make.height.equalTo(22.auto())
                }
                subTitleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel)
                    make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                    make.width.equalTo(titleSizeThatFits.width)
                }
                stateButton.snp.remakeConstraints { (make) in
                    make.width.equalTo(sizeThatFits.width + 44.auto())
                    make.right.equalToSuperview().offset(-24.auto())
                    make.centerY.equalToSuperview()
                    make.height.equalTo(44.auto())
                }
                break
            }
        }
    }
}
