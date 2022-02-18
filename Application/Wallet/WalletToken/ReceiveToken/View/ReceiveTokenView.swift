//
//  ReceiveTokenView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/10.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension ReceiveTokenViewController {
    class View: UIView {
        lazy var titleView = CoinTitleView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 160, height: NavBarHeight))
        var titleLabel: UILabel { titleView.nameLabel }
        var tokenButton : CoinTypeView { titleView.tokenButton }
        
        lazy var container: UIScrollView = {
            let v = UIScrollView(.white)
            v.showsVerticalScrollIndicator = false
            return v
        }()
        
        lazy var contentView = UIView(.clear)
        lazy var backgoundView = UIView(.white)
        
        lazy var qrCodeIV = UIImageView()
        lazy var qrCodeBorderView = UIView(.white)
        lazy var qrCodeContainer = UIView()
        lazy var qrCodeBackContainer = UIView(HDA(0x080A32), cornerRadius: 36)
        
        lazy var userNameLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 24, weight: .bold))
            v.textAlignment = .center
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 16), textColor: UIColor.white.withAlphaComponent(0.5))
            v.numberOfLines = 0
            v.textAlignment = .center
            return v
        }()
        
        lazy var shareButton: UIButton = {
            let v = UIButton(HDA(0x080A32), cornerRadius: 28)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.title = TR("ReceiveToken.Share")
            v.titleColor = .white
            return v
        }()
        lazy var copyButton: UIButton = {
            let v = UIButton(HDA(0xF0F3F5), cornerRadius: 28)
            v.titleFont = XWallet.Font(ofSize: 16)
            v.title = TR("Copy")
            v.titleColor = HDA(0x080A32)
            return v
        }()
        
        lazy var tipButton: UIButton = {
            let v = UIButton(.clear)
            v.size = CGSize(width: ScreenWidth - 24 * 2, height: 30)
            v.setImage(IMG("ic_tip"), for: .normal)
            v.setImage(IMG("ic_tip"), for: .highlighted)
            v.title = TR("ReceiveToken.Tip")
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = HDA(0x080A32)
            v.setTitlePosition(.right, withAdditionalSpacing: 6)
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
            backgroundColor = .clear
        }
        
        private func layoutUI() {
            
            addSubview(container)
            container.addSubview(backgoundView)
            container.addSubview(contentView) 
            backgoundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            qrCodeContainer.autoCornerRadius = 36
            contentView.addSubviews([qrCodeBackContainer, qrCodeContainer, tipButton, shareButton, copyButton])
            qrCodeContainer.addSubviews([userNameLabel, qrCodeBorderView, qrCodeIV, addressLabel])
            
            container.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.size.equalTo(CGSize(width: ScreenWidth, height: ScreenHeight > 812 ? ScreenHeight : 812))
            }
            
            qrCodeBackContainer.snp.makeConstraints { (make) in
                make.edges.equalTo(qrCodeContainer)
            }
            
            qrCodeContainer.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto() + FullNavBarHeight)
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(423.auto())
            }
            
            userNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(qrCodeContainer.snp.top).offset(40.auto())
                make.left.right.equalTo(qrCodeContainer).inset(24.auto())
                make.height.equalTo(30.auto())
            }
            
            qrCodeIV.snp.makeConstraints { (make) in
                make.center.equalTo(qrCodeContainer)
                make.size.equalTo(CGSize(width: 200, height: 200).auto())
            }
            
            qrCodeBorderView.snp.makeConstraints { (make) in
                make.edges.equalTo(qrCodeIV).inset(UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(qrCodeIV.snp.bottom).offset(24.auto())
                make.left.right.equalTo(qrCodeContainer).inset(32.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.top.equalTo(qrCodeContainer.snp.bottom).offset(10.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(30.auto())
            }
            
            shareButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(copyButton.snp.top).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            copyButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(-(safeAreaInsets.bottom + 16.auto()))
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    }
}

