//
//  BroadcastTxCommittingView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension BroadcastTxAlertController {
    class CommittingView: UIView {
        
        let containerView = UIView(COLOR.BACKGROUND)
        
        lazy var imageView: UIImageView = {
            
            let v = UIImageView()
            v.image = IMG("WC.Connected")
            return v
        }()
        
        lazy var imageBackgroundView: UIView = {
            let v = UIView(COLOR.BACKGROUND)
            v.layer.cornerRadius = 98
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var animationView = WalletHaloAnimationView(frame: CGRect(x: 0, y: 0, width: 196, height: 196))
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .clear
            listView.isScrollEnabled = false
            animationView.backgroundColor = .clear
        }

        private func layoutUI() {
            
            containerView.size = CGSize(width: ScreenWidth - 8 * 2, height: 457)
            addSubview(containerView)
            addSubview(imageBackgroundView)
            addSubview(animationView)
            addSubview(imageView)
            containerView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(457)
            }
            
            let imageHeight: CGFloat = 265
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo(containerView.snp.top).offset(-imageHeight * 0.5)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: imageHeight, height: imageHeight))
            }
            
            animationView.snp.makeConstraints { (make) in
                make.center.equalTo(imageView)
                make.size.equalTo(CGSize(width: 196, height: 196))
            }
            
            imageBackgroundView.snp.makeConstraints { (make) in
                make.center.equalTo(imageView)
                make.size.equalTo(CGSize(width: 196, height: 196))
            }
            
            containerView.addSubview(listView)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}


extension BroadcastTxAlertController {
    class CommittingDescCell: WKTableViewCell {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("BroadcastTx.CommittingDesc")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.numberOfLines = 0
            v.textAlignment = .center
            v.backgroundColor = .clear
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            return TR("BroadcastTx.CommittingDesc").height(ofWidth: ScreenWidth - 18 * 2, attributes: [.font: XWallet.Font(ofSize: 16)])
        }
        
        override public func initSubView() {
            layoutUI()
            configuration()
            
            logWhenDeinit()
        }
        
        private func configuration() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
        }
        
        private func layoutUI() {
            
            self.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
            }
        }
    }
}
