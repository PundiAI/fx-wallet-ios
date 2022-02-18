//
//  FxDelegateView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/26.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxRewardsViewController {
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
            
            addSubviews([listView])
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
        }
    }
}


extension FxRewardsViewController {
    
    class ContentCell: FxTableViewCell {
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        
        private lazy var validatorContentView = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
        lazy var validatorIV = CoinImageView(size: CGSize(width: 48, height: 48).auto()).then {
            $0.relayout(cornerRadius: 4.auto())
            $0.layer.shadowRadius = 8
            $0.layer.shadowOpacity = 0.02
        }
        lazy var validatorNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var validatorAddressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
        lazy var statusButton = FxValidatorStatusButton(size: CGSize(width: 100, height: 18).auto())
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        private lazy var fxcRewardsBGIV = UIImageView(image: IMG("FxStaking.RewardsBG"))
        private lazy var fxcRewardsIV = UIButton(.white, cornerRadius: 16).then{
            $0.image = IMG("ic_rewards")
            $0.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5).auto()
            $0.isUserInteractionEnabled = false
        }
        lazy var fxcRewardsTLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var fxcRewardsLabel = UILabel(font: XWallet.Font(ofSize: 20, weight: .medium), textColor: COLOR.title, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var fxUSDRewardsBGIV = UIImageView(image: IMG("FxStaking.RewardsBG"))
        private lazy var fxUSDRewardsIV = UIButton(.white, cornerRadius: 16).then{
            $0.image = IMG("ic_rewards")
            $0.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5).auto()
            $0.isUserInteractionEnabled = false
        }
        lazy var fxUSDRewardsTLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var fxUSDRewardsLabel = UILabel(font: XWallet.Font(ofSize: 20, weight: .medium), textColor: COLOR.title, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        override class func height(model: Any?) -> CGFloat { 385.auto() }
        
        override func layoutUI() {
            
            contentView.addSubview(bgView)
            
            bgView.addSubviews([fxcRewardsBGIV, fxcRewardsIV, fxcRewardsTLabel, fxcRewardsLabel])
            bgView.addSubviews([fxUSDRewardsBGIV, fxUSDRewardsIV, fxUSDRewardsTLabel, fxUSDRewardsLabel])
            
            bgView.addSubviews([validatorContentView, line])
            validatorContentView.addSubviews([validatorIV, validatorAddressLabel, validatorNameLabel, statusButton])
            
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            // reward...b
            
            fxcRewardsBGIV.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(117.auto())
            }

            fxcRewardsIV.snp.makeConstraints { (make) in
                make.top.equalTo(fxcRewardsBGIV).offset(16.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }

            fxcRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxcRewardsIV.snp.bottom).offset(8.auto())
                make.left.right.equalTo(fxcRewardsBGIV).inset(16.auto())
                make.height.equalTo(24.auto())
            }
            
            fxcRewardsTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxcRewardsLabel.snp.bottom).offset(4.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            fxUSDRewardsBGIV.snp.makeConstraints { (make) in
                make.top.equalTo(fxcRewardsBGIV.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(117.auto())
            }

            fxUSDRewardsIV.snp.makeConstraints { (make) in
                make.top.equalTo(fxUSDRewardsBGIV).offset(16.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }

            fxUSDRewardsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxUSDRewardsIV.snp.bottom).offset(8.auto())
                make.left.right.equalTo(fxUSDRewardsBGIV).inset(16.auto())
                make.height.equalTo(24.auto())
            }
            
            fxUSDRewardsTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxUSDRewardsLabel.snp.bottom).offset(4.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            // reward...e
            
            line.snp.makeConstraints { (make) in
                make.top.equalTo(282.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            // validator...b
            validatorContentView.snp.makeConstraints { (make) in
                make.top.equalTo(line.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(70.auto())
            }
            
            let edge: CGFloat = 16.auto()
            validatorIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(edge)
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            validatorNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(validatorIV.snp.right).offset(edge)
                make.height.equalTo(19.auto())
            }
            
            validatorAddressLabel.snp.makeConstraints { (make) in
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
            // validator...e
        }
    }
}
