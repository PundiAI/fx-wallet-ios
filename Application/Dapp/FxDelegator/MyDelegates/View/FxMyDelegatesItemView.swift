

import WKKit

extension FxMyDelegatesViewController {
    
    class SectionHeader: UITableViewHeaderFooterView {
        
        private lazy var addressBGView = UIView(COLOR.title)
        lazy var totalLabel = UILabel(font: XWallet.Font(ofSize: 18), textColor: .white)
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        private lazy var spaceView = UIView(HDA(0xF0F3F5))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            contentView.backgroundColor = .white
            
            addressBGView.addCorner([.topLeft, .topRight], radius: 20.auto(), size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 62.auto()))
        }
        
        private func layoutUI() {
            contentView.addSubviews([addressBGView, totalLabel, addressLabel, spaceView])
            
            let edge = 24.auto()
            addressBGView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.right.equalToSuperview()
                make.height.equalTo(62.auto())
            }
            
            totalLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressBGView).offset(12.auto())
                make.left.equalTo(addressBGView).offset(edge)
                make.height.equalTo(18.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(addressBGView).offset(-12.auto())
                make.left.right.equalTo(addressBGView).inset(edge)
                make.height.equalTo(18.auto())
            }
            
            spaceView.snp.makeConstraints { (make) in
                make.top.equalTo(addressBGView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
    }
}


extension FxMyDelegatesViewController {
    
    class ItemView: UIView {
        
        lazy var container = UIView(.white, cornerRadius: 16)
        
        lazy var validatorIV = CoinImageView(size: CGSize(width: 40, height: 40).auto()).then {
            $0.relayout(cornerRadius: 4.auto())
            $0.layer.shadowRadius = 8
            $0.layer.shadowOpacity = 0.02
        }
        lazy var validatorNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: HDA(0x71A800))
        private lazy var apyTLabel = UILabel(text: TR("APY"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        private lazy var delegateTLabel = UILabel(text: TR("ValidatorOverview.Delegated"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var delegateAmountLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title).then{ $0.adjustsFontSizeToFitWidth = true }
        private lazy var line = UIView(HDA(0x000000).withAlphaComponent(0.02))
        
        lazy var fxcRewardsTLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var fxcRewardsLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x71A800)).then{ $0.adjustsFontSizeToFitWidth = true }
//        lazy var fxcRewardsPerDayLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.adjustsFontSizeToFitWidth = true }
        private lazy var line1 = UIView(HDA(0x000000).withAlphaComponent(0.02))
        
        lazy var fxUSDRewardsTLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var fxUSDRewardsLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x71A800)).then{ $0.adjustsFontSizeToFitWidth = true }
//        lazy var fxUSDRewardsPerDayLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.adjustsFontSizeToFitWidth = true }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = HDA(0xF0F3F5)
        }
        
        private func layoutUI() {
            
            addSubview(container)
            container.addSubviews([validatorIV, validatorNameLabel, delegateTLabel, delegateAmountLabel, apyLabel, apyTLabel, arrowIV, line])
            container.addSubviews([fxcRewardsTLabel, fxcRewardsLabel, line1])
            container.addSubviews([fxUSDRewardsTLabel, fxUSDRewardsLabel])
            
            container.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16).auto())
            }
            
            validatorIV.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(12.auto())
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            
            let textLeft: CGFloat = 64.auto()
            validatorNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(18.auto())
                make.left.equalTo(textLeft)
                make.height.equalTo(18.auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.top.equalTo(validatorNameLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(validatorIV.snp.right).offset(12.auto())
                make.height.equalTo(14.auto())
            }
            
            apyTLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(apyLabel)
                make.left.equalTo(apyLabel.snp.right).offset(6.auto())
                make.height.equalTo(14.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(validatorIV)
                make.right.equalTo(-12.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            delegateTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(validatorIV.snp.bottom).offset(28.auto())
                make.left.equalTo(textLeft)
                make.height.equalTo(17.auto())
            }
            
            delegateAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(delegateTLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(textLeft)
                make.right.equalTo(-16.auto())
                make.height.equalTo(14.auto())
            }
            
            line.snp.makeConstraints { (make) in
                make.top.equalTo(144.auto())
                make.left.equalTo(textLeft)
                make.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            fxcRewardsTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(16.auto())
                make.left.equalTo(textLeft)
                make.right.equalTo(-16.auto())
                make.height.equalTo(17.auto())
            }
            
            fxcRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxcRewardsTLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(textLeft)
                make.right.equalTo(-16.auto())
                make.height.equalTo(20.auto())
            }
            
//            fxcRewardsPerDayLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(fxcRewardsLabel.snp.bottom).offset(8.auto())
//                make.left.right.equalTo(fxcRewardsLabel)
//                make.height.equalTo(17.auto())
//            }
            
            line1.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(76.auto())
                make.left.equalTo(textLeft)
                make.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            fxUSDRewardsTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(line1.snp.bottom).offset(16.auto())
                make.left.equalTo(textLeft)
                make.right.equalTo(-16.auto())
                make.height.equalTo(17.auto())
            }
            
            fxUSDRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxUSDRewardsTLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(textLeft)
                make.right.equalTo(-16.auto())
                make.height.equalTo(20.auto())
            }
            
//            fxUSDRewardsPerDayLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(fxUSDRewardsLabel.snp.bottom).offset(8.auto())
//                make.left.right.equalTo(fxUSDRewardsLabel)
//                make.height.equalTo(17.auto())
//            }
        }
        
        func relayout(isLast: Bool) {
            if isLast {
                let height: CGFloat = (298 + 16).auto()
                self.addCorner([.bottomLeft, .bottomRight], radius: 24.auto(), size: CGSize(width: ScreenWidth - 24.auto() * 2, height: height))
            } else {
                self.layer.mask = nil
            }
        }
    }
}
        
extension FxMyDelegatesViewController {
    class NoDataCell: FxTableViewCell {
        
        private lazy var background = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        private lazy var iconIV = UIImageView(image: IMG("ic_empty"))
        private lazy var titleLabel = UILabel(text: TR("Empty"), font: XWallet.Font(ofSize: 16, weight: .bold), textColor: HDA(0x080A32))
        private lazy var subtitleLabel = UILabel(text: TR("MyDelegates.NoData"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            
            let subtitleHeight = TR("MyDelegates.NoData").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 8.auto() + (subtitleHeight + 140.auto())
        }
        
        var estimatedHeight: CGFloat { Self.height(model: nil) }
        
        override func layoutUI() {
            
            contentView.addSubview(background)
            background.addSubviews([iconIV, titleLabel, subtitleLabel])
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0).auto())
            }
            
            iconIV.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(88.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(20.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
