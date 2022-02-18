import WKKit

extension MessageSetViewController {
    class View: UIView {
        
        lazy var tableView = WKTableView(frame: ScreenBounds, style: .plain)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
            tableView.snp.makeConstraints { (make) in
                make.edges.equalTo(UIEdgeInsets(top: FullNavBarHeight + 8.auto() , left: 0, bottom: 0, right: 0))
            }
        }
    }
}


extension MessageSetViewController {
    
    class NotificationCell: SecurityViewController.SingleCell {
        lazy var switchBt = UIButton()
        lazy var switCh: UISwitch = {
            let v = UISwitch()
            v.tintColor = COLOR.switchoff
            v.onTintColor = COLOR.title
            return v
        }()
        
        override func configuration() {
            super.configuration()
            self.selectionStyle = .none
            self.titleLabel.text = TR("Settings.Message.Notification")
            titleLabel.numberOfLines = 0
        }
        
        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            pannel.addSubview(switCh)
            pannel.addSubview(switchBt)
            
            self.type = .startVerification
            titleLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
            }
             
            switCh.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
            
            switchBt.snp.makeConstraints { (make) in
                make.edges.equalTo(switCh)
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 88.auto()
        }
    }
}

extension MessageSetViewController {
    
    class AccountSwitchCell: SecurityViewController.TopCell { 
        lazy var switCh: UISwitch = {
            let v = UISwitch()
            v.tintColor = COLOR.switchoff
            v.onTintColor = COLOR.title
            return v
        }()
        
        override func configuration() {
            super.configuration()
            self.selectionStyle = .none
            
            self.titleLabel.text = TR("Settings.Message.Account")
        }
        
        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            pannel.addSubview(switCh)
            
            
            titleLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview().offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(22.auto())
            }
             
            switCh.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview().offset(4.auto())
                make.right.equalTo(-24.auto())
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 80.auto()
        }
    }
}

extension MessageSetViewController {
    
    class SystemSwitchCell: SecurityViewController.BottomCell {
        
        lazy var switCh: UISwitch = {
            let v = UISwitch()
            v.tintColor = COLOR.switchoff
            v.onTintColor = COLOR.title
            return v
        }()
        
        override func configuration() {
            super.configuration()
            self.selectionStyle = .none
            
            self.titleLabel.text = TR("Settings.Message.System")
        }
        
        override func layoutUI() {
            super.layoutUI()
            icon.isHidden = true
            pannel.addSubview(switCh)
            
            titleLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview().offset(-4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(switCh.snp.left).offset(-10.auto())
                make.height.equalTo(22.auto())
            }
            
            
            switCh.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview().offset(-4.auto())
                make.right.equalTo(-24.auto())
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 80.auto()
        }
    }
}
