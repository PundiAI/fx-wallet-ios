

import WKKit

extension FxMyDelegatesViewController {
    class View: UIView {
        
        lazy var header = HeaderView()
        lazy var listView = WKTableView(frame: ScreenBounds, style: .grouped)
        
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
            
            addSubviews([listView])
            
            header.size = CGSize(width: ScreenWidth, height: header.estimatedHeight)
            listView.tableHeaderView = header
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: CGFloat(16.auto().ifull(50.auto()))), .white)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 24.auto(), bottom: 0, right: 24.auto()))
            }
        }
    }
}
        


//MARK: HeaderView
extension FxMyDelegatesViewController {
    class HeaderView: UIView {
        
        lazy var estimatedHeight: CGFloat = (8 + 447 + 24).auto()
        
        lazy var rewardsShadow = UIView(.white).then{
            $0.wk.displayShadow()
            $0.layer.shadowOffset = .zero
            $0.layer.cornerRadius = 16.auto()
            $0.layer.shadowRadius = 4
        }
        
        private lazy var rewardsContainer = UIView(.white, cornerRadius: 16)
        private lazy var rewardsBGIV = UIImageView(image: IMG("FxDelegate.RewardsBG"))
        private lazy var rewardsTitleLabel = UILabel(text: TR("MyDelegates.TotalRewards"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: COLOR.title)
        private lazy var rewardsIVContainer = UIView(.white, cornerRadius: 24)
        private lazy var rewardsIV = UIImageView(image: IMG("ic_rewards"))
        
        lazy var fxcLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center)
        lazy var fxcRewardsLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 20, weight: .medium), textColor: COLOR.title, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
//        lazy var fxcRewardsPerDayLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        lazy var fxUSDLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center)
        lazy var fxUSDRewardsLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 20, weight: .medium), textColor: COLOR.title, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
//        lazy var fxUSDRewardsPerDayLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var delegatedTitleLabel = UILabel(text: TR("MyDelegates.TotalDelegated"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var delegatedLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        
        private lazy var availableTitleLabel = UILabel(text: TR("MyDelegates.AvailableToDelegate"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var availableLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)

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
            
            addSubviews([rewardsShadow, rewardsContainer])
            addSubviews([delegatedTitleLabel, delegatedLabel])
            addSubviews([availableTitleLabel, availableLabel])
            rewardsContainer.addSubviews([rewardsBGIV, rewardsIVContainer, rewardsIV, rewardsTitleLabel, fxcLabel, fxcRewardsLabel, fxUSDLabel, fxUSDRewardsLabel])
            
            rewardsShadow.backgroundColor = .blue
            rewardsShadow.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(245.auto())
            }
            
            rewardsContainer.snp.makeConstraints { (make) in
                make.edges.equalTo(rewardsShadow).inset(UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1))
            }
            
            rewardsBGIV.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            rewardsIVContainer.snp.makeConstraints { (make) in
                make.top.equalTo(38.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            rewardsIV.snp.makeConstraints { (make) in
                make.center.equalTo(rewardsIVContainer)
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            rewardsTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsIVContainer.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(29.auto())
            }
            
            fxcLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsTitleLabel.snp.bottom).offset(32.auto())
                make.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(17.auto())
            }
            
            fxcRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxcLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(16.auto())
                make.right.equalTo(fxcLabel).offset(-16.auto())
                make.height.equalTo(20.auto())
            }
            
//            fxcRewardsPerDayLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(fxcRewardsLabel.snp.bottom).offset(8.auto())
//                make.left.right.equalTo(fxcRewardsLabel)
//                make.height.equalTo(17.auto())
//            }
            
            fxUSDLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsTitleLabel.snp.bottom).offset(32.auto())
                make.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(17.auto())
            }
            
            fxUSDRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxUSDLabel.snp.bottom).offset(4.auto())
                make.right.equalTo(-16.auto())
                make.left.equalTo(fxUSDLabel).offset(16.auto())
                make.height.equalTo(20.auto())
            }
            
//            fxUSDRewardsPerDayLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(fxUSDRewardsLabel.snp.bottom).offset(8.auto())
//                make.left.right.equalTo(fxUSDRewardsLabel)
//                make.height.equalTo(17.auto())
//            }
            
            let edge: CGFloat = 24.auto()
            delegatedTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(rewardsShadow.snp.bottom).offset(32.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            delegatedLabel.snp.makeConstraints { (make) in
                make.top.equalTo(delegatedTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
            
            availableTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(delegatedLabel.snp.bottom).offset(32.auto())
                make.left.equalTo(edge)
                make.height.equalTo(17.auto())
            }
            
            availableLabel.snp.makeConstraints { (make) in
                make.top.equalTo(availableTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(19.auto())
            }
        }
    }
}
