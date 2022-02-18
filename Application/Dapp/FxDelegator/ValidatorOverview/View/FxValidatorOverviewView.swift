

import WKKit

extension FxValidatorOverviewViewController {
    class View: UIView {
        
        private lazy var bottomMask = UIView(HDA(0xF0F3F5).withAlphaComponent(0.8))
        private lazy var bottomBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        private lazy var line = UIView(HDA(0xFAFAFB))
        lazy var delegateButton: UIButton = {
            let v = UIButton()
            v.title = TR("BroadcastTx.Delegate")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.autoCornerRadius = 28
            v.backgroundColor = COLOR.title
            return v
        }()
        
        lazy var undelegateButton: UIButton = {
            let v = UIButton()
            v.title = TR("FXDelegator.UnDelegate")
            v.titleFont = XWallet.Font(ofSize: 16)
            v.titleColor = COLOR.title
            v.autoCornerRadius = 28
            v.backgroundColor = HDA(0xF0F3F5)
            return v
        }()
        
        lazy var rewardsButton: UIButton = {
            let v = UIButton(size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 56.auto()))
            v.addGradient()
            v.title = TR("FXDelegator.Rewards")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = HDA(0x0552DC)
            v.autoCornerRadius = 28
            v.image = IMG("ic_rewards")
            return v
        }()
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var listHeader = HeaderView(size: CGSize(width: ScreenWidth, height: 400.auto()))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            bottomMask.isHidden = true
        }
        
        private func layoutUI() {
            
            addSubviews([listView, bottomBlur, line, delegateButton, bottomMask])
            
            let blurHeight: CGFloat = 16.auto() + 56.auto() + CGFloat(16.auto().ifull(50.auto()))
            listView.tableHeaderView = self.listHeader
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: blurHeight), .white)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
            
            bottomBlur.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(blurHeight)
            }
            
            line.snp.makeConstraints { (make) in
                make.top.equalTo(bottomBlur)
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            delegateButton.snp.makeConstraints { (make) in
                make.top.equalTo(bottomBlur).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            bottomMask.snp.makeConstraints { (make) in
                make.edges.equalTo(bottomBlur)
            }
        }
         
        func relayoutForMutilActions() {
            guard undelegateButton.superview == nil else { return }
            
            let blurHeight: CGFloat = (16.auto() + 56.auto()) * 2 + CGFloat(16.auto().ifull(50.auto()))
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: blurHeight), .white)
            let halfWidth: CGFloat = (ScreenWidth - 16.auto() - 24.auto() * 2) * 0.5

            addSubviews([undelegateButton, rewardsButton])

            bottomBlur.snp.updateConstraints { (make) in
                make.height.equalTo(blurHeight)
            }

            delegateButton.snp.remakeConstraints { (make) in
                make.top.equalTo(bottomBlur).offset(16.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: halfWidth, height: 56.auto()))
            }

            undelegateButton.snp.remakeConstraints { (make) in
                make.top.equalTo(bottomBlur).offset(16.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: halfWidth, height: 56.auto()))
            }

            rewardsButton.snp.makeConstraints { (make) in
                make.top.equalTo(delegateButton.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    
        func relayout(isActive: Bool) {
            self.bringSubviewToFront(bottomMask)
            bottomMask.isHidden = isActive
        }
    }
}

//MARK: HeaderView
extension FxValidatorOverviewViewController {
    class HeaderView: UIView {
        
        lazy var delegatedContentHeight: CGFloat = 237.auto()
        lazy var myDelegateContentView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        private lazy var myDelegateTitleLabel = UILabel(text: TR("ValidatorOverview.Delegated"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var myDelegateLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        private lazy var line4 = UIView(HDA(0xEBEEF0))
        
        lazy var fxcRewardsTLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var fxcRewardsLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x71A800))
//        lazy var fxcRewardsPerDayLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        private lazy var line5 = UIView(HDA(0xEBEEF0))
        
        lazy var fxUSDRewardsTLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var fxUSDRewardsLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x71A800))
//        lazy var fxUSDRewardsPerDayLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        
        lazy var infoContentView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        
        lazy var validatorIV = CoinImageView(size: CGSize(width: 48, height: 48).auto()).then{
            $0.relayout(cornerRadius: 4.auto())
            $0.layer.shadowRadius = 8
            $0.layer.shadowOpacity = 0.02
        }
        lazy var validatorNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var validatorAddressButton: UIButton = {
            
            let v = UIButton()
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleLabel?.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        lazy var statusButton = FxValidatorStatusButton(size: CGSize(width: 100, height: 18).auto())
        private lazy var line1 = UIView(HDA(0xEBEEF0))
        
        private lazy var descTitleLabel = UILabel(text: TR("Description"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var validatorDescLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        lazy var validatorLinkButton: UIButton = {
            let v = UIButton()
            v.title = unknownAmount
            v.titleColor = HDA(0x0552DC)
            v.titleFont = XWallet.Font(ofSize: 14)
            v.contentHorizontalAlignment = .left
            v.titleLabel?.adjustsFontSizeToFitWidth = true
            return v
        }()
        private lazy var line2 = UIView(HDA(0xEBEEF0))
        
        private lazy var stakeTitleLabel = UILabel(text: TR("ValidatorOverview.TotalStake"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var stakeLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var votingPowerLabel = UILabel(text: TR("ValidatorOverview.VotingPower$", unknownAmount), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        private lazy var line3 = UIView(HDA(0xEBEEF0))
        
        private lazy var rewardsTitleLabel = UILabel(text: TR("FXDelegator.Rewards"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var rewardsLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x71A800))
        
        private lazy var infoBGView = UIView(.white).then{
            $0.wk.displayShadow()
            $0.layer.shadowOffset = .zero
            $0.layer.cornerRadius = 16.auto()
            $0.layer.shadowRadius = 20
        }
        
        var foldHeight: CGFloat { 36.auto() + 1 }
        lazy var foldButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_arrow_down_black")
            v.title = TR("ValidatorOverview.More")
            v.selectedTitle = TR("ValidatorOverview.Less")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            v.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            return v
        }()
        
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
            
            addSubviews([infoBGView, infoContentView, foldButton])
            
            infoContentView.addSubviews([validatorIV, validatorAddressButton, validatorNameLabel, statusButton, line1])
            infoContentView.addSubviews([descTitleLabel, validatorDescLabel, validatorLinkButton, line2])
            infoContentView.addSubviews([stakeTitleLabel, stakeLabel, votingPowerLabel, line3])
            infoContentView.addSubviews([rewardsTitleLabel, rewardsLabel])
            
            infoBGView.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(-16.auto())
            }
            
            infoContentView.snp.makeConstraints { (make) in
                make.edges.equalTo(infoBGView).inset(UIEdgeInsets(top: 1, left: 1, bottom: 36.auto(), right: 1))
            }
            
            foldButton.snp.makeConstraints { (make) in
                make.top.equalTo(infoContentView.snp.bottom)
                make.left.right.equalTo(infoContentView)
                make.height.equalTo(36.auto())
            }
            
            //info...b
            
            let edge: CGFloat = 16.auto()
            validatorIV.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.equalTo(edge)
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            validatorNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(28.auto())
                make.left.equalTo(validatorIV.snp.right).offset(edge)
                make.height.equalTo(19.auto())
            }
            
            validatorAddressButton.snp.makeConstraints { (make) in
                make.top.equalTo(validatorNameLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(validatorIV.snp.right).offset(edge)
                make.right.equalTo(-edge)
                make.height.equalTo(17.auto())
            }

            statusButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(validatorNameLabel)
                make.left.equalTo(validatorNameLabel.snp.right).offset(4.auto())
                make.height.equalTo(18.auto())
            }
            
            line1.snp.makeConstraints { (make) in
                make.top.equalTo(88.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            descTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line1.snp.bottom).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(18.auto())
            }
            
            validatorDescLabel.snp.makeConstraints { (make) in
                make.top.equalTo(descTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(edge)
            }
            
            validatorLinkButton.snp.makeConstraints { (make) in
                make.top.equalTo(validatorDescLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(20.auto())
            }
            
            line2.snp.makeConstraints { (make) in
                make.top.equalTo(validatorLinkButton.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            
            stakeTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line2).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            stakeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(stakeTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            votingPowerLabel.snp.makeConstraints { (make) in
                make.top.equalTo(stakeLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            line3.snp.makeConstraints { (make) in
                make.top.equalTo(votingPowerLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            
            
            rewardsTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line3).offset(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            rewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            //info...e
        }
        
        func relayout(expand: Bool) {
            
            UIView.animate(withDuration: 0.2) {
                self.foldButton.imageView?.transform = expand ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
            }
        }
        
        func relayoutForMyDelegate() {
            guard myDelegateContentView.superview == nil else { return }
            
            addSubviews([myDelegateContentView])
            myDelegateContentView.addSubviews([myDelegateTitleLabel, myDelegateLabel, line4])
            myDelegateContentView.addSubviews([fxcRewardsTLabel, fxcRewardsLabel, line5])
            myDelegateContentView.addSubviews([fxUSDRewardsTLabel, fxUSDRewardsLabel])
            
            myDelegateContentView.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(delegatedContentHeight)
            }
            
            infoBGView.snp.updateConstraints { (make) in
                make.top.equalTo(delegatedContentHeight + 24.auto())
            }
            
            let edge: CGFloat = 16.auto()
            myDelegateTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            myDelegateLabel.snp.makeConstraints { (make) in
                make.top.equalTo(myDelegateTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            line4.snp.makeConstraints { (make) in
                make.top.equalTo(76.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            fxcRewardsTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line4.snp.bottom).offset(16.auto())
                make.left.equalTo(edge)
                make.right.equalTo(-16.auto())
                make.height.equalTo(17.auto())
            }
            
            fxcRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxcRewardsTLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.right.equalTo(-16.auto())
                make.height.equalTo(20.auto())
            }
            
//            fxcRewardsPerDayLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(fxcRewardsLabel.snp.bottom).offset(8.auto())
//                make.left.right.equalTo(fxcRewardsLabel)
//                make.height.equalTo(17.auto())
//            }
            
            line5.snp.makeConstraints { (make) in
                make.top.equalTo(line4.snp.bottom).offset(76.auto())
                make.left.equalTo(edge)
                make.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            fxUSDRewardsTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line5.snp.bottom).offset(16.auto())
                make.left.equalTo(edge)
                make.right.equalTo(-16.auto())
                make.height.equalTo(17.auto())
            }
            
            fxUSDRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxUSDRewardsTLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(edge)
                make.right.equalTo(-16.auto())
                make.height.equalTo(20.auto())
            }
            
//            fxUSDRewardsPerDayLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(fxUSDRewardsLabel.snp.bottom).offset(8.auto())
//                make.left.right.equalTo(fxUSDRewardsLabel)
//                make.height.equalTo(17.auto())
//            }
        }
    }
}

//MARK: StatusButton
class FxValidatorStatusButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        logWhenDeinit()
        
        configuration()
    }
    
    var isActive = false {
        didSet {
            
            titleColor = HDA(isActive ? 0x0552DC : 0xFA6237)
            
            let text = "  \(TR(isActive ? "FXDelegator.Active" : "FXDelegator.Inactive"))  "
            self.setAttributedTitle(NSAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 12, weight: .medium), .foregroundColor: titleColor!]), for: .normal)
            self.setAttributedTitle(NSAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 12, weight: .medium), .foregroundColor: disabledTitleColor ?? .white]), for: .disabled)
            disabledBGImage = UIImage.createImageWithColor(color: titleColor!)
        }
    }
    
    @objc private func onClick() {
        
        wk.viewController?.hud?.text(m: TR(isActive ? "FXDelegator.ValidatorIsActive" : "FXDelegator.ValidatorIsInactive"), d: 2)
        self.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.isEnabled = true
        }
    }
    
    //MARK: Utils
    private func configuration() {
        
        autoCornerRadius = 9
        titleFont = XWallet.Font(ofSize: 12)
        titleColor = HDA(0x0552DC)
        disabledTitleColor = .white
        
        bgImage = UIImage.createImageWithColor(color: HDA(0x000000).withAlphaComponent(0.04))
        disabledBGImage = UIImage.createImageWithColor(color: HDA(0x0552DC))
        self.bind(self, action: #selector(onClick), forControlEvents: .touchUpInside)
        self.isActive = true
    }
    
}
