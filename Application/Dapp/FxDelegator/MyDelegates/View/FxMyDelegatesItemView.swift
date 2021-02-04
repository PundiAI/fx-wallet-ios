//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension FxMyDelegatesViewController {
    
    class ListHeader: UITableViewHeaderFooterView {
        
        private lazy var addressBGView = UIView(COLOR.title)
        lazy var balanceLabel = UILabel(font: XWallet.Font(ofSize: 18), textColor: .white)
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
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
            contentView.addSubviews([addressBGView, balanceLabel, addressLabel])
            
            let edge = 24.auto()
            addressBGView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.right.equalToSuperview()
                make.height.equalTo(62.auto())
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressBGView).offset(12.auto())
                make.left.equalTo(addressBGView).offset(edge)
                make.height.equalTo(18.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(addressBGView).offset(-12.auto())
                make.left.right.equalTo(addressBGView).inset(edge)
                make.height.equalTo(18.auto())
            }
        }
        
    }
}


extension FxMyDelegatesViewController {
    
    class ItemView: UIView {
        
        lazy var validatorIV = CoinImageView(size: CGSize(width: 40, height: 40).auto()).relayout(cornerRadius: 4.auto())
        lazy var validatorNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var delegateAmountLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var rewardsAmountLabel = UILabel(font: XWallet.Font(ofSize: 12), textColor: HDA(0x0552DC))
        private lazy var line = UIView(HDA(0xEBEEF0))
        
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: HDA(0x71A800))
        private lazy var apyTLabel = UILabel(text: TR("APY"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
       
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
            
            addSubviews([validatorIV, validatorNameLabel, delegateAmountLabel, rewardsAmountLabel, apyLabel, apyTLabel, arrowIV, line])
            
            validatorIV.snp.makeConstraints { (make) in
                make.top.equalTo(26.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            
            validatorNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(26.auto())
                make.left.equalTo(validatorIV.snp.right).offset(16.auto())
                make.height.equalTo(16.auto())
            }
            
            delegateAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(validatorNameLabel.snp.bottom).offset(6.auto())
                make.left.equalTo(validatorIV.snp.right).offset(16.auto())
                make.height.equalTo(14.auto())
            }
            
            rewardsAmountLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(delegateAmountLabel)
                make.left.equalTo(delegateAmountLabel.snp.right).offset(8.auto())
                make.height.equalTo(12.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.top.equalTo(80.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(arrowIV)
                make.left.equalTo(validatorIV.snp.right).offset(16.auto())
            }
            
            apyTLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(apyLabel)
                make.left.equalTo(apyLabel.snp.right).offset(8.auto())
            }
            
            line.snp.makeConstraints { (make) in
                make.bottom.right.equalToSuperview()
                make.left.equalTo(80.auto())
                make.height.equalTo(1)
            }
        }
        
        func relayout(isLast: Bool) {
            line.isHidden = isLast
            if isLast {
                self.addCorner([.bottomLeft, .bottomRight], radius: 20.auto(), size: CGSize(width: ScreenWidth - 24.auto() * 2, height: 120.auto()))
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
