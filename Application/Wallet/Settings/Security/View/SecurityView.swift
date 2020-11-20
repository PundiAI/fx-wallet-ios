import WKKit
extension SecurityViewController {
    class View: UIView {
        lazy var tableView = UITableView(frame: ScreenBounds, style: .plain)
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .white
        }

        private func layoutUI() {
            addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.edges.equalTo(UIEdgeInsets(top: FullNavBarHeight + 8.auto(), left: 0, bottom: 0, right: 0))
            }
        }
    }
}

extension SecurityViewController {
    class Cell: FxTableViewCell {
        enum Types {
            case backUpMnemonic
            case viewConsensus
            case biometrics
            case deleteWallet
            case language
            case currency
            case merchantOption
            case security
            case password
            case debug_token
            case debug_log
        }

        override class func height(model _: Any?) -> CGFloat {
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
                case .debug_token:
                    titleLabel.text = TR("Settings.Debug.NoticeToken")
                case .debug_log:
                    titleLabel.text = TR("Settings.Debug.ShowLog")
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
            pannel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            pannel.addSubviews([titleLabel, icon])
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            icon.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }
    }
}

extension SecurityViewController {
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
            selectionStyle = .none
        }

        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            type = .biometrics
            contentView.addSubview(subTitleLabel)
            contentView.addSubview(switCh)
            titleLabel.snp.remakeConstraints { make in
                make.bottom.equalTo(contentView.snp.centerY).offset(-4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(20.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(contentView.snp.centerY).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(20.auto())
            }
            switCh.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
            subTitleLabel.text = TR("Use your face to sign transactions")
        }
    }
}

extension SecurityViewController {
    class Base: FxTableViewCell {
        enum Types {
            case biometrics
            case deleteWallet
            case password
            case startVerification
        }

        var type = Types.biometrics {
            didSet {
                switch type {
                case .biometrics:
                    titleLabel.text = TR(LocalAuthManager.shared.isAuthFace ? "FaceId" : "TouchId")
                case .deleteWallet:
                    titleLabel.text = TR("Settings.ResetWallet")
                case .startVerification:
                    titleLabel.text = TR("Security.Start.Title")
                case .password:
                    if let _ = XWallet.sharedKeyStore.currentWallet?.wk.accessCode {
                        titleLabel.text = TR("Settings.Pwd.Change")
                    } else {
                        titleLabel.text = TR("Settings.Pwd.New")
                    }
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

        lazy var icon: UIImageView = {
            let v = UIImageView()
            v.image = IMG("setting.nextB")
            return v
        }()

        lazy var pannel: UIView = {
            let v = UIView(COLOR.settingbc)
            return v
        }()

        override class func height(model _: Any?) -> CGFloat {
            return 72.auto()
        }

        override func layoutUI() {
            contentView.addView(pannel)
            pannel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            pannel.autoCornerRadius = 16
            pannel.addSubviews([titleLabel, icon])
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            icon.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }
    }
}

extension SecurityViewController {
    class TopCell: Base {
        override class func height(model _: Any?) -> CGFloat { return 80.auto() }
        override func layoutUI() {
            super.layoutUI()
            titleLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview().offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            icon.snp.remakeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.right.equalTo(-24.auto())
            }
            if #available(iOS 11.0, *) {
                pannel.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
            } else {}
        }
    }
}

extension SecurityViewController {
    class BottomCell: Base {
        override class func height(model _: Any?) -> CGFloat { return 80.auto() }
        override func layoutUI() {
            super.layoutUI()
            titleLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview().offset(-4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
            }
            icon.snp.remakeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview().offset(-4.auto())
                make.right.equalTo(-24.auto())
            }
            if #available(iOS 11.0, *) {
                pannel.layer.maskedCorners = [CACornerMask.layerMinXMaxYCorner, CACornerMask.layerMaxXMaxYCorner]
            } else {}
        }
    }
}

extension SecurityViewController {
    class SingleCell: Base {
        override class func height(model _: Any?) -> CGFloat { return 88.auto() }
        override func layoutUI() {
            super.layoutUI()
        }
    }
}

extension SecurityViewController {
    class StartVerifyCell: SingleCell {
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            v.numberOfLines = 0
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
            selectionStyle = .none
        }

        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            pannel.addSubview(subTitleLabel)
            pannel.addSubview(switCh)
            type = .startVerification
            titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset((24 + 8).auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(22.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
            }
            switCh.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }

        override class func height(model: Any?) -> CGFloat {
            if let rs = model as? String {
                let width = ScreenWidth - (24 * 2).auto() - (24 + 68).auto()
                let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }

                let height = rs.height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14),
                                                                    .paragraphStyle: style])
                return (8 + 24 + 22 + 4).auto() + height + (24 + 8).auto()
            }
            return 88.auto()
        }

        override func update(model: Any?) {
            if let rs = model as? String {
                subTitleLabel.text = rs
            }
        }
    }

    class BioTypeCell: TopCell {
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            v.numberOfLines = 0
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
            selectionStyle = .none
        }

        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            type = .biometrics
            pannel.addSubview(subTitleLabel)
            pannel.addSubview(switCh)
            titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset((24 + 8).auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(22.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.width.equalTo((ScreenWidth - (24 * 2).auto()) / 2)
                make.bottom.equalToSuperview().offset(-24.auto())
            }
            switCh.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }

        override class func height(model: Any?) -> CGFloat {
            if let rs = model as? String {
                let width = (ScreenWidth - (24 * 2).auto()) / 2
                let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }

                let height = rs.height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14),
                                                                    .paragraphStyle: style])
                return (8 + 24 + 22 + 4).auto() + height + 24.auto()
            }
            return 88.auto()
        }

        override func update(model: Any?) {
            if let rs = model as? String {
                subTitleLabel.text = rs
            }
        }
    }
}
