//
//  SendChatGitView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/10.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

fileprivate func titleLabel(_ text: String) -> UILabel {
    
    let v = UILabel()
    v.text = text
    v.font = XWallet.Font(ofSize: 14, weight: .bold)
    v.textColor = UIColor.white.withAlphaComponent(0.5)
    v.backgroundColor = .clear
    return v
}

fileprivate func itemContainerView() -> UIView {
    let v = UIView(HDA(0x1D1D1D))
    v.layer.cornerRadius = 22
    v.layer.masksToBounds = true
    v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    v.layer.borderWidth = 1
    return v
}

extension SendChatGiftViewController {
    
    class CryptoCell: WKTableViewCell.TitleCell {
        
        fileprivate lazy var line = UIView(UIColor.white.withAlphaComponent(0.3))
        
        override func initSubView() {
            super.initSubView()
            
            titleLabel.font = XWallet.Font(ofSize: 16, weight: .bold)
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(15)
                make.centerY.equalToSuperview()
            }
            
            addSubview(line)
            line.snp.makeConstraints { (make) in
                make.bottom.equalTo(-0.75)
                make.left.right.equalToSuperview()
                make.height.equalTo(0.75)
            }
        }
        
        override class func height(model: Any?) -> CGFloat { 44 }
    }
}

extension SendChatGiftViewController {
    class View: UIView {
        
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar(size: CGSize(width: ScreenWidth, height: StatusBarHeight + 56))
            v.blur.isHidden = true
            v.backgroundColor = HDA(0x222222)
            v.backButton.image = IMG("Chat.NavLeft")
            v.rightButton.image = IMG("ic_close_white")
            return v
        }()
        var closeButton: UIButton { navBar.rightButton }
        
        fileprivate lazy var navTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("SendGift.Title")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = .white
            return v
        }()
        
        lazy var containerView: UIScrollView = {
            let v = UIScrollView(.clear)
            v.bounces = false
//            v.contentSize = CGSize(width: 0, height: 1050)
            v.contentSize = CGSize(width: 0, height: 820)
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            return v
        }()
        
        fileprivate lazy var contentView = UIView(COLOR.BACKGROUND)
        lazy var hideActionButton = UIButton(.clear)
        
        fileprivate lazy var toTitleLabel = titleLabel(TR("To"))
        lazy var toNameLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var toNameFxLabel = titleLabel("")
        lazy var toAddressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            v.numberOfLines = 2
            return v
        }()
        
        fileprivate lazy var cryptoTitleLabel = titleLabel(TR("Crypto"))
        fileprivate lazy var cryptoContainer = itemContainerView()
        lazy var cryptoNameLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var cryptoArrowIV: UIImageView = {
            let v = UIImageView()
            v.image = IMG("Chat.ArrowDown")
            v.contentMode = .scaleAspectFit
            return v
        }()
        
        lazy var cryptoActionButton = UIButton(.clear)
        
        lazy var cryptoListView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = HDA(0x1D1D1D)
            v.layer.cornerRadius = 22
            v.layer.masksToBounds = true
            v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
            v.layer.borderWidth = 1
            return v
        }()
            
        
        fileprivate lazy var amountTitleLabel = titleLabel(TR("Amount"))
        fileprivate lazy var amountContainer = itemContainerView()
        lazy var amountInputTF: UITextField = {
            
            let v = UITextField()
            v.font = XWallet.Font(ofSize:16)
            v.textColor = .white
            v.tintColor = .white
            v.keyboardType = .decimalPad
            v.backgroundColor = .clear
            v.attributedPlaceholder = NSAttributedString(string: "0.00",
                                                         attributes: [.font: XWallet.Font(ofSize: 16),
                                                                      .foregroundColor: UIColor.white.withAlphaComponent(0.32)])
            return v
        }()
        
        lazy var usableAmountLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        
        fileprivate lazy var messageTitleLabel = titleLabel(TR("Message"))
        lazy var messageInputTV: FxTextView = {
            let v = FxTextView(limit: 100)
            v.backgroundColor = HDA(0x1D1D1D)
            v.interactor.backgroundColor = HDA(0x1D1D1D)
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            v.placeHolderLabel.text = TR("Chat.Placeholder")
            return v
        }()
        
        fileprivate lazy var feeTitleLabel = titleLabel(TR("Fee"))
        lazy var fasterFeeView = FeeItemView(TR("SendGift.Faster"))
        lazy var normalFeeView = FeeItemView(TR("SendGift.Normal"))
        lazy var slowerFeeView = FeeItemView(TR("SendGift.Slower"))
        
        fileprivate lazy var totalTitleLabel = titleLabel(TR("Total"))
        
        lazy var totalPaymentLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var totalLegalPaymentLabel: UILabel = {
            let v = UILabel()
            v.text = "$ --"
            v.font = XWallet.Font(ofSize: 14, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var sendButton: UIButton = {
            let v = UIButton().doGradient(title: TR("Send_U"))
            v.setImage(IMG("Chat.ArrowRight"), for: .normal)
            v.setImage(IMG("Chat.ArrowRight"), for: .highlighted)
            v.titleFont = XWallet.Font(ofSize: 16, weight: .bold)
            v.setTitlePosition(.left, for: .normal)
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
            backgroundColor = HDA(0x272727)
            
            cryptoArrowIV.isHidden = true
            cryptoListView.isHidden = true
            contentView.backgroundColor = HDA(0x272727)
            containerView.backgroundColor = HDA(0x272727)
            
            //MARK: 暂时屏蔽
            feeTitleLabel.isHidden = true
            fasterFeeView.isHidden = true
            normalFeeView.isHidden = true
            slowerFeeView.isHidden = true
            totalLegalPaymentLabel.isHidden = true
        }
        
        private func layoutUI() {
            
            addSubview(containerView)
            containerView.addSubview(contentView)
            
            let navBarHeight = navBar.height
            navBar.navigationArea.addSubview(navTitleLabel)
            addSubview(navBar)
            
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(navBarHeight)
            }
            
            navTitleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(navBar.backButton.snp.right).offset(6)
                make.centerY.equalToSuperview()
            }
            
            contentView.addSubview(hideActionButton)
            
            contentView.addSubview(toTitleLabel)
            contentView.addSubview(toNameLabel)
            contentView.addSubview(toNameFxLabel)
            contentView.addSubview(toAddressLabel)
            
            cryptoContainer.addSubviews([cryptoNameLabel, cryptoArrowIV, cryptoActionButton])
            contentView.addSubview(cryptoTitleLabel)
            contentView.addSubview(cryptoContainer)
            
            amountContainer.addSubview(amountInputTF)
            contentView.addSubview(amountContainer)
            contentView.addSubview(amountTitleLabel)
            contentView.addSubview(usableAmountLabel)
            
            contentView.addSubview(messageTitleLabel)
            contentView.addSubview(messageInputTV)
            
            contentView.addSubview(feeTitleLabel)
            contentView.addSubview(fasterFeeView)
            contentView.addSubview(normalFeeView)
            contentView.addSubview(slowerFeeView)
            
            contentView.addSubview(totalTitleLabel)
            contentView.addSubview(totalPaymentLabel)
            contentView.addSubview(totalLegalPaymentLabel)
            
            contentView.addSubview(sendButton)
            contentView.addSubview(cryptoListView)
            
            containerView.snp.makeConstraints { (make) in
                make.top.equalTo(navBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.size.equalTo(CGSize(width: ScreenWidth, height: 820))
            }
            
            hideActionButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            let padding = 18
            toTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(27)
                make.left.equalTo(padding)
                make.height.equalTo(16)
            }
            
            toNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(toTitleLabel.snp.bottom).offset(10)
                make.left.equalTo(padding)
                make.height.equalTo(29)
            }
            
            toNameFxLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(toNameLabel)
                make.left.equalTo(toNameLabel.snp.right).offset(10)
                make.height.equalTo(20)
            }
            
            toAddressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(toNameLabel.snp.bottom).offset(2)
                make.left.right.equalToSuperview().inset(padding)
            }
            
            cryptoTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(toTitleLabel.snp.bottom).offset(105)
                make.left.equalTo(padding)
                make.height.equalTo(16)
            }
            
            cryptoContainer.snp.makeConstraints { (make) in
                make.centerY.equalTo(cryptoTitleLabel)
                make.right.equalTo(-18)
                make.size.equalTo(CGSize(width: 200, height: 44))
            }
            
            cryptoActionButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            cryptoNameLabel.snp.makeConstraints { (make) in
                make.left.equalTo(15)
                make.centerY.equalToSuperview()
            }
            
            cryptoArrowIV.snp.makeConstraints { (make) in
                make.right.equalTo(-17)
                make.centerY.equalToSuperview()
            }
            
            cryptoListView.snp.makeConstraints { (make) in
                make.top.equalTo(cryptoContainer).offset(-1)
                make.left.right.equalTo(cryptoContainer)
                make.height.equalTo(44)
            }
            
            amountTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(cryptoTitleLabel.snp.bottom).offset(52)
                make.left.equalTo(padding)
                make.height.equalTo(16)
            }
            
            amountContainer.snp.makeConstraints { (make) in
                make.centerY.equalTo(amountTitleLabel)
                make.right.equalTo(-18)
                make.size.equalTo(CGSize(width: 200, height: 44))
            }
            
            amountInputTF.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(15)
            }
            
            usableAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountContainer.snp.bottom).offset(10)
                make.left.equalTo(amountContainer).offset(15)
                make.height.equalTo(16)
            }
            
            messageTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountTitleLabel.snp.bottom).offset(70)
                make.left.equalTo(padding)
                make.height.equalTo(16)
            }
            
            messageInputTV.snp.makeConstraints { (make) in
                make.top.equalTo(messageTitleLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(13)
                make.height.equalTo(120)
            }
            
            feeTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(messageTitleLabel.snp.bottom).offset(160)
                make.left.equalTo(padding)
                make.height.equalTo(16)
            }
            
            fasterFeeView.containerView.gradientBGLayer.size = CGSize(width: ScreenWidth - 8 * 2, height: 44)
            fasterFeeView.snp.makeConstraints { (make) in
                make.top.equalTo(feeTitleLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(44)
            }
            
            normalFeeView.containerView.gradientBGLayer.size = CGSize(width: ScreenWidth - 8 * 2, height: 44)
            normalFeeView.snp.makeConstraints { (make) in
                make.top.equalTo(fasterFeeView.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(44)
            }
            
            slowerFeeView.containerView.gradientBGLayer.size = CGSize(width: ScreenWidth - 8 * 2, height: 44)
            slowerFeeView.snp.makeConstraints { (make) in
                make.top.equalTo(normalFeeView.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(44)
            }
            
            totalTitleLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(slowerFeeView.snp.bottom).offset(58)
                make.top.equalTo(messageTitleLabel.snp.bottom).offset(200)
                make.centerX.equalToSuperview()
                make.height.equalTo(16)
            }
            
            totalPaymentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(totalTitleLabel.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(30)
            }
            
            totalLegalPaymentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(totalPaymentLabel.snp.bottom).offset(4)
                make.centerX.equalToSuperview()
                make.height.equalTo(16)
            }
            
            sendButton.snp.makeConstraints { (make) in
                make.top.equalTo(totalLegalPaymentLabel.snp.bottom).offset(42)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
        }
    }
}
