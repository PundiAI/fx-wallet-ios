 
import WKKit


//MARK: View
extension WalletBackUpAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("WC.Warning"))
        private lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("Security.AlertTitle"), font: XWallet.Font(ofSize: 24, weight: .medium), alignment: .center)
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        
        lazy var errorTextBGView = UIView(UIColor.white.withAlphaComponent(0.08), cornerRadius: 16.auto())
        
        
        private lazy var noticeLabel = UILabel(text: TR("Security.AlertContent"), font: XWallet.Font(ofSize: 14), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
        
            let width = ScreenWidth - 24.auto() * 4  - 32.auto()
            let noticeHeight = TR("Security.AlertContent").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (0 + 56).auto() + (16 + 29).auto() + (16.auto() + noticeHeight) + 16.auto() + 32.auto()
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, titleLabel, errorTextBGView, noticeLabel])
            
//            errorTextBGView.addView(noticeLabel)
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(0.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(20.auto())
                make.height.equalTo(29.auto())
            }
            
            errorTextBGView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview().inset(40.auto())
            }
            
            errorTextBGView.snp.makeConstraints { (make) in
                make.edges.equalTo(noticeLabel).inset(UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16).auto())
            }
        }
    }
}


extension WalletBackUpAlertController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var backUpButton: UIButton { rightActionButton }
            
        var stillSkipButton: UIButton { leftActionButton }
        
        override func configuration() {
            super.configuration()
            leftActionButton.title = TR("Button.StillSkip")
            rightActionButton.title = TR("Button.BackUp")
        }
    }
}


//MARK: View
extension WalletBackUpAlertSecondController {
    class ContentCell: FxTableViewCell {
        
        private lazy var tipBackground = UIView(.white, cornerRadius: 28)
        private lazy var tipIV = UIImageView(image: IMG("WC.Warning"))
        private lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("Security.AlertTitle2"), font: XWallet.Font(ofSize: 24, weight: .medium), alignment: .center)
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        private lazy var noticeLabel = UILabel(text: TR("Security.AlertContent2"), font: XWallet.Font(ofSize: 14), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
        
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight = TR("Security.AlertContent2").height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (0 + 56).auto() + (16 + 29).auto() + (16.auto() + noticeHeight) + 16.auto()
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, titleLabel, noticeLabel])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(0.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(20.auto())
                make.height.equalTo(29.auto())
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension WalletBackUpAlertSecondController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var skipButton: UIButton { rightActionButton }
            
        var cancelButton: UIButton { leftActionButton }
        
        private var timer: Timer?
        
        func bind() {
            timer?.invalidate()
            start()
        }
         
        func reset() {
            rightActionButton.title = TR("Button.Skip")
            rightActionButton.backgroundColor = UIColor.white
            rightActionButton.setTitleColor(COLOR.title, for: .normal)
            timer?.invalidate()
        }
        
        func start() {
            let index = 5
            let currentTime = NSDate().timeIntervalSince1970
            rightActionButton.isUserInteractionEnabled = false
            updateText(index)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self](t) in
                guard let this = self else { t.invalidate(); return }
                let now =  NSDate().timeIntervalSince1970
                var tagIndx  =  index - Int(now - currentTime)
                if tagIndx <= 0 { tagIndx = 0 }
                this.updateText(tagIndx)
                if tagIndx == 0 {
                    this.timerOut()
                }
            })
        }
        
        func updateText(_ idx: Int) {
            rightActionButton.title =  "\(TR("Button.Skip"))(\(idx)s)"
            rightActionButton.backgroundColor = HDA(0x31324A).withAlphaComponent(0.5)
            rightActionButton.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: .normal)
        }
        
        func timerOut() {
            reset()
            rightActionButton.isUserInteractionEnabled = true
        }
        
        
        override func configuration() {
            super.configuration()
            leftActionButton.title = TR("Button.Skip.Cancel")
            rightActionButton.title = TR("Button.Skip")
            bind()
        }
    }
}
