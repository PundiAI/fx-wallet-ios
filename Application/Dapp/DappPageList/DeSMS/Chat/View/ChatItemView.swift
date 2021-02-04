//
//  ChatItemView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension ChatViewController {
    
    class ItemView: UIView {
        lazy var avatarIV: ChatAvatarBinder = {
            let v = ChatAvatarBinder(size: CGSize(width: 36, height: 36))
            v.textLabel.font = XWallet.Font(ofSize: 22, weight: .bold)
            return v
        }()
        
        lazy var textLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var dateLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = UIColor.white.withAlphaComponent(0.32)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var resendButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Chat.SendFail")
            v.backgroundColor = .clear
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        fileprivate func configuration() {
            backgroundColor = HDA(0x1d1d1d)
        }

        fileprivate func layoutUI() {}
    }
}

extension ChatViewController {

    class TextItemView: ItemView {
        
        lazy var bubbleLayer = CAShapeLayer()
        
        lazy var statusIV = UIImageView()
        
        override func layoutUI() {
            
            layer.addSublayer(bubbleLayer)
            addSubview(avatarIV)
            addSubview(textLabel)
            addSubview(dateLabel)
            addSubview(statusIV)
        }
        
        func layoutForSender() {
            
            addSubview(resendButton)
            avatarIV.isHidden = true
            bubbleLayer.lineCap = .round
            bubbleLayer.fillColor = HDA(0x0084FF).cgColor
            statusIV.backgroundColor = HDA(0x0084FF)
            dateLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        }
        
        func layoutForReceiver() {
            
            statusIV.isHidden = true
            bubbleLayer.lineCap = .round
            bubbleLayer.fillColor = HDA(0x2E2E2E).cgColor
            
            avatarIV.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.left.equalTo(14)
                make.size.equalTo(CGSize(width: 36, height: 36))
            }
        }
    }
}







extension ChatViewController {

    class GiftItemView: ItemView {
        
        lazy var contentView: UIView = {
            let v = UIView()
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var giftContentView: UIView = {
           
            let v = UIView(size: CGSize(width: 255, height: 90))
            v.backgroundColor = HDA(0x0FF6A00)
            v.gradientBGLayer.size = CGSize(width: 255, height: 90)
            v.gradientBGLayer.colors = [HDA(0xFF3535).cgColor, HDA(0x0FF6A00).cgColor]
            return v
        }()
        
        lazy var tokenLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .bold)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = HDA(0xff6a00)
            v.layer.cornerRadius = tokenWidth * 0.5
            v.layer.masksToBounds = true
            v.layer.borderColor = HDA(0xff7c1f).cgColor
            v.layer.borderWidth = tokenMargin
            return v
        }()
        
        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 24)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var legalAmountLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var giftIV = UIImageView(image: IMG("Chat.Gift_gray"))
        
        lazy var giftTypeLabel: UILabel = {
            let v = UILabel()
//            v.text = "\(TR("Transfer"))  "
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = UIColor.white.withAlphaComponent(0.3)
            v.backgroundColor = HDA(0x2E0E00)
            
            let text = "\(TR("Transfer"))  ."
            let attText = NSMutableAttributedString(string: text)
            attText.addAttributes([.foregroundColor: v.backgroundColor!], range: NSMakeRange(text.count - 1, 1))
            v.attributedText = attText
            v.textAlignment = .right
            return v
        }()

        override func layoutUI() {
            
            addSubview(avatarIV)
            
            giftContentView.addSubview(giftIV)
            giftContentView.addSubview(tokenLabel)
            giftContentView.addSubview(amountLabel)
            giftContentView.addSubview(legalAmountLabel)
            giftContentView.addSubview(textLabel)
            contentView.addSubview(giftContentView)
            
            contentView.addSubview(giftTypeLabel)
            contentView.addSubview(dateLabel)
            addSubview(contentView)
        }
        
        fileprivate var tokenMargin: CGFloat { return 8 }
        fileprivate var tokenWidth: CGFloat { return 54 }
        func layoutToken(_ width: CGFloat) {
            
            if width < tokenWidth - tokenMargin * 2 || tokenLabel.width == width { return }
            
            tokenLabel.layer.cornerRadius = width * 0.5
            tokenLabel.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize(width: width, height: width))
            }
        }
        
        func layoutForSender() {
            
            avatarIV.isHidden = true
            
            layoutForReceiver()
            
            giftContentView.gradientBGLayer.colors = [HDA(0xFF3535).cgColor, HDA(0x0FF6A00).cgColor]
            
            contentView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.right.equalTo(-14)
                make.size.equalTo(CGSize(width: 255, height: 119))
            }
            
            dateLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(contentView).offset(10)
                make.centerY.equalTo(giftTypeLabel)
            }
            
            addSubview(resendButton)
            resendButton.snp.makeConstraints { (make) in
                make.right.equalTo(contentView.snp.left).offset(-8)
                make.centerY.equalTo(contentView)
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
        }
        
        func layoutForReceiver() {
            
//            giftTypeLabel.text = "  \(TR("Transfer"))"
//            giftContentView.gradientBGLayer.colors = [HDA(0xFF3535).cgColor, HDA(0x0FF6A00).cgColor]
            
            avatarIV.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(14)
                make.size.equalTo(CGSize(width: 36, height: 36))
            }
            
            contentView.snp.makeConstraints { (make) in
                make.top.equalTo(avatarIV)
                make.left.equalTo(avatarIV.snp.right).offset(10)
                make.size.equalTo(CGSize(width: 255, height: 119))
            }
            
            giftContentView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(90)
            }
            
            tokenLabel.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.equalTo(14)
                make.size.equalTo(CGSize(width: tokenWidth, height: tokenWidth))
            }
            
            amountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenLabel.snp.top).offset(2)
                make.left.equalTo(tokenLabel.snp.right).offset(12)
                make.right.equalTo(-14)
                make.height.equalTo(29)
            }
            
            legalAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountLabel.snp.bottom).offset(1)
                make.left.right.equalTo(amountLabel)
                make.height.equalTo(16)
            }
            
            textLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(legalAmountLabel.snp.bottom).offset(4)
                make.top.equalTo(amountLabel.snp.bottom).offset(1)
                make.left.right.equalTo(amountLabel)
                make.height.equalTo(16)
            }
            
            giftIV.snp.makeConstraints { (make) in
                make.bottom.right.equalToSuperview()
                make.size.equalTo(CGSize(width: 64, height: 64))
            }
            
            giftTypeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(giftContentView.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            }
            
            dateLabel.snp.makeConstraints { (make) in
                make.left.equalTo(contentView).offset(14)
                make.centerY.equalTo(giftTypeLabel)
            }
        }
    }
}
