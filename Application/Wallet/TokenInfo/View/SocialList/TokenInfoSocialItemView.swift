//
//  TokenInfoSocialItemView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension TokenInfoSocialListBinder {
    class NewsCell: FxTableViewCell {
        
        let estimatedHeight: CGFloat = 138.auto()
        
        private lazy var backgroundIV = UIImageView(image: IMG("Social_News"))
        private lazy var titleLabel = UILabel(text: TR("Social.News"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: .white)
        private lazy var subtitleLabel = UILabel(text: TR("Social.NewsSubtitle"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
        private lazy var subtitleLabel2 = UILabel(text: TR("Social.NewsSubtitle2"), font: XWallet.Font(ofSize: 12), textColor: .white)
        override func layoutUI() {
            backgroundIV.contentMode = .scaleAspectFit
            addSubviews([backgroundIV, titleLabel, subtitleLabel, subtitleLabel2])
            
            backgroundIV.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(backgroundIV).offset(32.auto())
                make.left.equalTo(backgroundIV).offset(24.auto())
                make.height.equalTo(30.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(3.auto())
                make.left.equalTo(backgroundIV).offset(24.auto())
                make.height.equalTo(18.auto())
            }
            
            subtitleLabel2.snp.makeConstraints { (make) in
                make.bottom.equalTo(-20.auto())
                make.left.equalTo(backgroundIV).offset(24.auto())
                make.height.equalTo(18.auto())
            }
        }
    }
}

extension TokenInfoSocialListBinder {
    
    class HeaderView: UIView {
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(isSocial: Bool) {
            super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 45.auto()))
            titleLabel.text = TR(isSocial ? "Social" : "Social.Extended")
            
            self.backgroundColor = .clear
            
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.bottom.equalTo(-16.auto())
                make.height.equalTo(21.auto())
            }
        }
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 18), textColor: .white)
    }
}

extension TokenInfoSocialListBinder {
    
    class ItemView: UIView {
        
        lazy var iconIV = UIImageView(.clear, cornerRadius: 24)
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: .white)
        lazy var subtitleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
        private lazy var arrowIV = UIImageView(image: IMG("Social_Arrow"))
        private lazy var line = UIView(HDA(0x373737).withAlphaComponent(0.4))
        private lazy var bgView = UIView(UIColor.white.withAlphaComponent(0.08), cornerRadius: 16)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = COLOR.title
            bgView.isHidden = true
        }
        
        private func layoutUI() {
            addSubviews([bgView, iconIV, titleLabel, subtitleLabel, arrowIV, line])
            
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            iconIV.snp.makeConstraints { (make) in
                make.left.equalTo(32.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(14.auto())
                make.left.equalTo(iconIV.snp.right).offset(8.auto())
                make.height.equalTo(22.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.equalTo(iconIV.snp.right).offset(8.auto())
                make.height.equalTo(18.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-32.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            line.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(48.auto())
                make.height.equalTo(1)
            }
        }
        
        func selected() {
            
            bgView.isHidden = false
            line.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.bgView.isHidden = true
                self.line.isHidden = false
            }
        }
    }
}
