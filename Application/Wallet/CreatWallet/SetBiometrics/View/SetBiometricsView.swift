 
import WKKit

extension SetBiometricsViewController {
    
    class View: WelcomeCreateView {
        
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        
        lazy var bioImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60.auto(), height: 60.auto()))
        
        lazy var bioLabel = UILabel(font: XWallet.Font(ofSize: 16),
                                    textColor: COLOR.title,
                                    alignment: .center,
                                         bgColor: .clear).then {$0.autoFont = true}
        
        lazy var backUpButton = UIButton().doNormal(title: TR("First.SetBio.Button.SetNow"))
        lazy var notNowButton = UIButton().doNormal(title: TR("Skip"))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            
            let isTouchID = LocalAuthManager.shared.isAuthTouch
            let msg = isTouchID ? TR("Security.Bio.TouchTitle") : TR("Security.Bio.FaceTitle")
            let icon = isTouchID ? IMG("Bio.Touchid.Whitebg") : IMG("Bio.Faceid.Whitebg")
            
            titleLabel.text = msg
            subtitleLabel.text = TR("Security.Bio.SubTitle")
            
            bioLabel.text = msg
            bioImage.image = icon
            
            backUpButton.autoCornerRadius = 28
            backUpButton.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            backUpButton.titleLabel?.autoFont = true
            
            notNowButton.titleFont = XWallet.Font(ofSize: 16)
            notNowButton.titleLabel?.autoFont = true
            notNowButton.autoCornerRadius = 28
            
            notNowButton.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0xF0F3F5)), for: .normal)
            notNowButton.setTitleColor(.black, for: .normal)
        }
        
        private func layoutUI() {
            self.pannel.removeFromSuperview()
            
            addSubview(navBar)
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            addSubview(bioImage)
            addSubview(bioLabel)
            
            addSubview(backUpButton)
            addSubview(notNowButton)
            
            bioLabel.frame = CGRect(x: 24.auto(), y: 0, width: ScreenWidth - 24.auto() * 2, height: 20.auto())
            
            backUpButton.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
                make.bottom.equalTo(notNowButton.snp.top).offset(-16.auto())
            }
            
            notNowButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews() 
            let top = backUpButton.top - subtitleLabel.bottom  - CGFloat(20.auto() + 60.auto())
            let offTop = (top / 2) - CGFloat(8.auto()) - 20
            bioImage.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 60, height: 60).auto())
                make.centerX.equalToSuperview()
                make.top.equalTo(subtitleLabel.snp.bottom).offset(offTop)
            }

            bioLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bioImage.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(20.auto())
            }
        }
    }
}
        
