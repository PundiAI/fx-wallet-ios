

import WKKit

extension FxStakingOverviewViewController {
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
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
            
            self.addSubview(listView)
            listView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 34.auto(), right: 0)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
        }
    }
}
        
//MARK: AccountCell
extension FxStakingOverviewViewController {
    
    class AccountCell: FxTableViewCell {
        
        enum State {
            case normal
            case selected
        }
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        private lazy var emptyIV = UIImageView(size: CGSize(width: 48, height: 48).auto()).then{ $0.image = IMG("ic_empty") }
        private lazy var emptyTitleLabel = UILabel(text: TR("FxStaking.Overview.EmptyTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 0, alignment: .center)
        private lazy var emptyDescLabel = UILabel(text: TR("FxStaking.Overview.EmptyDesc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0, alignment: .center)
        
        lazy var addressContainer = UIView(.white, cornerRadius: 16)
        private lazy var addressIV = UIImageView(.clear, cornerRadius: 16).then{ $0.image = IMG("ic_token?") }
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        private lazy var addressTitleLabel = UILabel(text: TR("NPXSSwap.Submit.WalletAddress"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
        lazy var addressPlaceHolderLabel = UILabel(text: TR("FxStaking.SelectAddress"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 2, bgColor: .white)
        lazy var addressActionButton = UIButton(.clear)
        
        lazy var rewardsContainer = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
        private lazy var rewardsBGIV = UIImageView(image: IMG("FxStaking.RewardsBG"))
        private lazy var rewardsIV = UIButton(.white, cornerRadius: 16).then{
            $0.image = IMG("ic_rewards")
            $0.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5).auto()
            $0.isUserInteractionEnabled = false
        }
        private lazy var rewardsTitleLabel = UILabel(text: TR("FxStaking.Overview.TotalRewards"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        lazy var rewardsLabel = UILabel(text: "\(unknownAmount) FX", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var legalRewardsLabel = UILabel(text: "$\(unknownAmount)", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.subtitle).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var regularHeight: CGFloat = {
            
            let emptyTitleHeight = TR("FxStaking.Overview.EmptyTitle").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium)])
            let emptyDescHeight = TR("FxStaking.Overview.EmptyDesc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 238.auto() + emptyTitleHeight + emptyDescHeight
        }()
        
        var estimatedHeight: CGFloat { state == .normal ? regularHeight : 211.auto() }
        override class func height(model: Any?) -> CGFloat { return (model as? AccountCell)?.estimatedHeight ?? 0 }
        
        var state = State.normal {
            didSet {
                guard state == .selected, rewardsContainer.isHidden else { return }
                
                addressIV.isHidden = true
                addressPlaceHolderLabel.isHidden = true
                emptyIV.isHidden = true
                emptyDescLabel.isHidden = true
                emptyTitleLabel.isHidden = true
                rewardsContainer.isHidden = false
                
                addressTitleLabel.snp.updateConstraints { (make) in
                    make.left.equalTo(16.auto())
                }
                
                addressLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(16.auto())
                }
            }
        }
        
        override func configuration() {
            super.configuration()
            
            rewardsContainer.isHidden = true
        }
        
        override func layoutUI() {
            
            contentView.addSubviews([bgView, emptyIV, emptyTitleLabel, emptyDescLabel])
            contentView.addSubviews([addressContainer, rewardsContainer])
            addressContainer.addSubviews([arrowIV, addressIV, addressTitleLabel, addressLabel, addressPlaceHolderLabel, addressActionButton])
            rewardsContainer.addSubviews([rewardsBGIV, rewardsIV, rewardsTitleLabel, rewardsLabel, legalRewardsLabel])
            
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            //address.b
            addressContainer.snp.makeConstraints { (make) in
                make.top.equalTo(bgView).offset(16.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(70.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.right.equalTo(-8.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            addressIV.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            addressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(15.auto())
                make.left.equalTo(56.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(19.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(-15.auto())
                make.left.equalTo(56.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(17.auto())
            }
            
            addressPlaceHolderLabel.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(10)
                make.left.equalTo(56.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
            }
            
            addressActionButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            //address.e
            
            
            //empty...b
            emptyIV.snp.makeConstraints { (make) in
                make.top.equalTo(addressContainer.snp.bottom).offset(40.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            emptyTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(emptyIV.snp.bottom).offset(16.auto())
                make.left.right.equalTo(bgView).inset(24.auto())
            }
            
            emptyDescLabel.snp.makeConstraints { (make) in
                make.top.equalTo(emptyTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(bgView).inset(24.auto())
            }
            //empty...e
            
            
            
            //rewards...b
            rewardsContainer.snp.makeConstraints { (make) in
                make.top.equalTo(addressContainer.snp.bottom).offset(16.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(93.auto())
            }
            
            rewardsBGIV.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            rewardsIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            rewardsTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(56.auto())
                make.height.equalTo(17.auto())
            }
            
            rewardsLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(56.auto())
                make.height.equalTo(19.auto())
            }
            
            legalRewardsLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(-16.auto())
                make.left.equalTo(56.auto())
                make.height.equalTo(17.auto())
            }
            //rewards...e
        }
    }
}

//MARK: StakingCell
extension FxStakingOverviewViewController {
    
    class StakingCell: FxTableViewCell {
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        
        private lazy var tokenBGView = UIView(COLOR.title)
        lazy var tokenIV = UIImageView(size: CGSize(width: 24, height: 24).auto())
        lazy var tokenLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), alignment: .right)
        
        private lazy var avaStakeTitleLabel = UILabel(text: TR("FxStaking.Overview.AvailabletoStake"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var avaStakeLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var legalAvaStakeLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var avaStakeActionButton = actionButton(title: TR("FxStaking.Overview.Stake"))
        
        private lazy var stakedTitleLabel = UILabel(text: TR("FxStaking.Overview.Staked"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var stakedLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var legalStakedLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var stakedActionButton = actionButton(title: TR("FxStaking.Overview.Redeem"))
        
        private lazy var rewardsTitleLabel = UILabel(text: TR("FxStaking.Overview.Rewards"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var rewardsLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var legalRewardsLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var rewardsActionButton = actionButton(title: TR("FxStaking.Overview.Claim"))
        
        private lazy var lockedTitleLabel = UILabel(text: TR("FxStaking.Overview.Locked"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var lockedLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var legalLockedLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        
        private func actionButton(title: String) -> UIButton {
            let v = UIButton()
            v.backgroundColor = .white
            v.title = title
            v.titleFont = XWallet.Font(ofSize: 16, weight: .medium)
            v.titleColor = COLOR.title
            v.autoCornerRadius = 18
            return v
        }
        
        override class func height(model: Any?) -> CGFloat { 428.auto() }
        
        override func layoutUI() {
            
            avaStakeActionButton.isEnabled = false
            avaStakeActionButton.backgroundColor = COLOR.disabled
            avaStakeActionButton.disabledTitleColor = COLOR.title.withAlphaComponent(0.1)
//            self.disabledTitleColor = COLOR.title.withAlphaComponent(0.1)
//            setBackgroundImage(UIImage.createImageWithColor(color: COLOR.title), for: .normal)
//            setBackgroundImage(UIImage.createImageWithColor(color: COLOR.disabled), for: .disabled)
            
            contentView.addSubviews([bgView])
            bgView.addSubview(tokenBGView)
            tokenBGView.addSubviews([tokenIV, tokenLabel, apyLabel])
            
            bgView.addSubviews([avaStakeTitleLabel, avaStakeLabel, legalAvaStakeLabel, avaStakeActionButton])
            bgView.addSubviews([stakedTitleLabel, stakedLabel, legalStakedLabel, stakedActionButton])
            bgView.addSubviews([rewardsTitleLabel, rewardsLabel, legalRewardsLabel, rewardsActionButton])
            bgView.addSubviews([lockedTitleLabel, lockedLabel, legalLockedLabel])
            
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            //title...b
            tokenBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40.auto())
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            tokenLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-20.auto())
            }
            //title...e
            
            avaStakeTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenBGView.snp.bottom).offset(24.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
            
            avaStakeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(avaStakeTitleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(avaStakeActionButton.snp.left).offset(-8.auto())
                make.height.equalTo(19.auto())
            }
            
            legalAvaStakeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(avaStakeLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(avaStakeActionButton.snp.left).offset(-8.auto())
                make.height.equalTo(17.auto())
            }
            
            avaStakeActionButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(avaStakeLabel)
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 93, height: 36).auto())
            }
            
            
            
            stakedTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenBGView.snp.bottom).offset(117.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
            
            stakedLabel.snp.makeConstraints { (make) in
                make.top.equalTo(stakedTitleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(stakedActionButton.snp.left).offset(-8.auto())
                make.height.equalTo(19.auto())
            }
            
            legalStakedLabel.snp.makeConstraints { (make) in
                make.top.equalTo(stakedLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(stakedActionButton.snp.left).offset(-8.auto())
                make.height.equalTo(17.auto())
            }
            
            stakedActionButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(stakedLabel)
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 93, height: 36).auto())
            }
            
            
            rewardsTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenBGView.snp.bottom).offset(210.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
            
            rewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsTitleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(rewardsActionButton.snp.left).offset(-8.auto())
                make.height.equalTo(19.auto())
            }
            
            legalRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.right.equalTo(rewardsActionButton.snp.left).offset(-8.auto())
                make.height.equalTo(17.auto())
            }
            
            rewardsActionButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(rewardsLabel)
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 93, height: 36).auto())
            }
            
            lockedTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenBGView.snp.bottom).offset(303.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
            
            lockedLabel.snp.makeConstraints { (make) in
                make.top.equalTo(lockedTitleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(19.auto())
            }
            
            legalLockedLabel.snp.makeConstraints { (make) in
                make.top.equalTo(lockedLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
        }
        
    }
}
