//
//  SelectWalletConnectAccountView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/15.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SelectWalletConnectAccountController {
    class View: SelectAccountViewController.View {
        
        override func configuration() {
            super.configuration()
            
            self.titleLabel.text = TR("WalletConnect.TSelectAddress")
            self.listView.estimatedRowHeight = 36.auto()
            self.listView.estimatedSectionHeaderHeight = 101
            self.listView.estimatedSectionFooterHeight = 24.auto()
        }
    }
}

extension SelectWalletConnectAccountController {
    class HeaderItemView: UIView {
        
        lazy var containerView = UIView(COLOR.title, cornerRadius: 16)

        lazy var numberLabel = UILabel(font: XWallet.Font(ofSize: 12), textColor: UIColor.white.withAlphaComponent(0.5))
        lazy var balanceLabel = UILabel(text: "--", font: XWallet.Font(ofSize: 18, weight: .medium), textColor: .white)
        lazy var addressLabel: UILabel = {
            let v = UILabel(text: "--", font: XWallet.Font(ofSize: 14), textColor: .white)
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        lazy var coinTypeView = CoinTypeView().then{ $0.style = .lightContent }
        fileprivate lazy var remarkBackground = UIView(HDA(0x0552DC), cornerRadius: 11)
        lazy var remarkLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: UIColor.white, alignment: .center, bgColor: .clear)
        lazy var actionButton = UIButton(.clear)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            remarkLabel.isHidden = true
            remarkBackground.isHidden = true
        }
        
        func layoutUI() {
            addSubview(containerView)
            containerView.addSubviews([numberLabel, addressLabel, balanceLabel, remarkBackground, remarkLabel, coinTypeView, actionButton])
            
            containerView.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(101)
            }
            
            actionButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            numberLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(53)
                make.right.equalTo(-16)
                make.height.equalTo(22)
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(balanceLabel.snp.bottom).offset(5)
                make.left.right.equalTo(balanceLabel)
                make.height.equalTo(17)
            }
            
            remarkLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(addressLabel).offset(4.auto())
                make.height.equalTo(22.auto())
            }
            
            coinTypeView.snp.makeConstraints { (make) in
                make.centerY.equalTo(remarkBackground)
                make.left.equalTo(addressLabel)
                make.size.equalTo(CGSize(width: 0, height: 16.auto()))
            }
            
            remarkBackground.snp.makeConstraints { (make) in
                make.edges.equalTo(remarkLabel).inset(UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8))
                make.width.greaterThanOrEqualTo(50)
                make.width.lessThanOrEqualTo(100)
            }
        }
        
        func relayout(hideRemark: Bool) {
            remarkLabel.isHidden = hideRemark
            remarkBackground.isHidden = hideRemark
//            balanceLabel.snp.updateConstraints { (make) in
//                make.top.equalTo(hideRemark ? 29 : 16)
//            }
            
            coinTypeView.snp.remakeConstraints { (make) in
                make.centerY.equalTo(remarkBackground)
                make.size.equalTo(CGSize(width: 0, height: 16.auto()))
                if hideRemark {
                    make.left.equalTo(addressLabel)
                } else {
                    make.left.equalTo(remarkBackground.snp.right).offset(8.auto())
                }
            }
        }
        
    }
}

extension SelectWalletConnectAccountController {
    class FooterItemView: UIView {
        
        lazy var topView = UIView(.white)
        lazy var arrowIV = UIImageView(image: IMG("ic_arrow_down_black"))
        lazy var countLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
        lazy var actionButton = UIButton(.clear)
        
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
        
        func layoutUI() {
            
            addSubview(topView)
            topView.addSubviews([arrowIV, countLabel, actionButton])
            
            topView.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.left.equalTo(24.auto())
                make.height.equalTo(46.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            countLabel.snp.makeConstraints { (make) in
                make.left.equalTo(arrowIV.snp.right).offset(4.auto())
                make.centerY.equalToSuperview()
            }
        }
        
        func relayout(expand: Bool) {
            if topView.isHidden { return }
            
            UIView.animate(withDuration: 0.2) {
                self.arrowIV.transform = expand ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
            }
        }
    }
}


extension SelectWalletConnectAccountController {
    class ItemView: UIView {
        
        lazy var coinIV = UIImageView(.white, cornerRadius: 12)
        lazy var balanceLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 16), textColor: COLOR.title)
            v.adjustsFontSizeToFitWidth = true
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
            addSubviews([coinIV, balanceLabel])
            
            coinIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(coinIV.snp.right).offset(12.auto())
                make.right.equalTo(-12.auto())
            }
        }
    }
}

