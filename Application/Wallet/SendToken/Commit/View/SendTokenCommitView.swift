//
//  SendTokenView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/10.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SendTokenCommitViewController {
    class View: UIView {
        lazy var backgroundView = UIView(HDA(0x080A32), cornerRadius: 36).then { $0.autoCornerRadius = 36 }
        private lazy var regularHeaderHeight: CGFloat = 277.auto() + StatusBarHeight
        lazy var headerHeight = regularHeaderHeight
        
        lazy var header: UIView = {
            let v = UIView(.white)
            v.size = CGSize(width: ScreenWidth, height: headerHeight)
            v.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
            return v
        }()
        
        lazy var loadingView: UIActivityIndicatorView = {
            let v = UIActivityIndicatorView()
            v.color = COLOR.title
            v.style = .gray
            v.backgroundColor = .clear
            return v
        }()
        lazy var unlockView = UnlockView(frame: .zero)
        
        lazy var headerContentView = UIView(.clear)
        
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.standard()
            v.titleLabel.text = TR("Recipient")
            v.titleLabel.font = XWallet.Font(ofSize: 18)
            return v
        }()
         
        lazy var titleLabel = UILabel(text: TR("SendToken.Commit.Title"),
                                      font: XWallet.Font(ofSize: 24, weight: .bold),
                                      textColor: HDA(0x080A32)).then { $0.autoFont = true }
        
        fileprivate lazy var inputBackgroud: UIView = {
            let v = UIView(size: CGSize(width: ScreenWidth, height: 56.auto()))
            v.backgroundColor = HDA(0xF0F3F5).withAlphaComponent(0.5)
            v.autoCornerRadius = 28
            v.borderColor = .clear
            v.borderWidth = 2
            return v
        }()
        
        lazy var inputTF: UITextView = {
            let v = UITextView()
            v.font = XWallet.Font(ofSize:16, weight: .bold)
            v.textColor = HDA(0x080A32)
            v.tintColor = HDA(0x0552DC)
//            v.attributedPlaceholder = NSAttributedString(string: TR("SendToken.Commit.Placeholder"),
//                                                         attributes: [.font: XWallet.Font(ofSize:16),
//                                                                      .foregroundColor: HDA(0x080A32).withAlphaComponent(0.5)])
            v.keyboardType = .emailAddress
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var inputPlaceholder = UILabel(text: TR("SendToken.Commit.Placeholder"), font: XWallet.Font(ofSize:16), textColor: HDA(0x080A32).withAlphaComponent(0.5))
        
        lazy var scanButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Menu.Scan")
            v.contentHorizontalAlignment = .right
            return v
        }()
        
        lazy var nextButton: UIButton = {
            let v = UIButton() 
            v.title = TR("Next")
            v.bgImage = UIImage.createImageWithColor(color: HDA(0x080A32))
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.disabledBGImage = UIImage.createImageWithColor(color: HDA(0xF0F3F5).withAlphaComponent(0.5))
            v.disabledTitleColor = HDA(0x080A32).withAlphaComponent(0.2)
            v.autoCornerRadius = 28
            v.titleLabel?.autoFont = true
            return v
        }()
        
        lazy var mainListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = UIColor.clear //HDA(0x080A32)
            return v
        }()
        
        lazy var searchListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = .white
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
            backgroundColor = UIColor.clear 
            searchListView.isHidden = true
            unlockView.isHidden = true
        }
        
        var isEditing: Bool = false {
            didSet {
                inputBackgroud.borderColor = isEditing ? HDA(0x0552DC) : .clear
            }
        }
        
        var isEditable: Bool = true {
            didSet {
                header.isUserInteractionEnabled = isEditable
                mainListView.isUserInteractionEnabled = isEditable
            }
        }
        
        
        func loading(_ v: Bool) {
            
            v ? loadingView.startAnimating() : loadingView.stopAnimating()
            if v { self.endEditing(true) }
            isEditable = !v
            nextButton.snp.updateConstraints { (make) in
                make.top.equalTo(inputBackgroud.snp.bottom).offset(v ? 62.auto() : 32.auto())
            }
        }
        
        func showUnlock(_ v: Bool, _ mode: ApprovePanel.Mode = .regular) {
            unlockView.isHidden = !v
            if v {
                if unlockView.isE2F { unlockView.actionView.mode = mode }
                relayoutForUnlockIfNeed()
            }
        }
        
        func showInputError() {
            inputBackgroud.borderColor = HDA(0xFA6237)
        }
        
        private func layoutUI() {
            
            addSubviews([backgroundView, mainListView, header, headerContentView, searchListView])
            headerContentView.addSubviews([navBar, titleLabel, inputBackgroud, inputTF, inputPlaceholder, scanButton, loadingView, nextButton, unlockView])
            
            backgroundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            //header...b
            header.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(headerHeight)
            }
            
            headerContentView.snp.makeConstraints { (make) in
                make.edges.equalTo(header)
            }
            
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(navBar.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(30.auto())
            }
            
            inputBackgroud.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            inputTF.snp.makeConstraints { (make) in
                make.edges.equalTo(inputBackgroud).inset(UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 60).auto())
            }
            
            inputPlaceholder.snp.makeConstraints { (make) in
                make.top.equalTo(inputBackgroud).offset(16.auto())
                make.left.right.equalTo(inputBackgroud).inset(28.auto())
                make.height.equalTo(20)
            }
            
            scanButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(inputBackgroud)
                make.right.equalTo(inputBackgroud).offset(-24.auto())
                make.size.equalTo(CGSize(width: 30, height: 30).auto())
            }
            
            loadingView.snp.makeConstraints { (make) in
                make.top.equalTo(inputBackgroud.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
            }
            
            nextButton.snp.makeConstraints { (make) in
                make.top.equalTo(inputBackgroud.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            unlockView.snp.makeConstraints { (make) in
                make.top.equalTo(inputBackgroud.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
            
            //header...e 
            mainListView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: headerHeight), UIColor.clear)
            mainListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            searchListView.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + (30 + 8).auto() + (32 + 56).auto())
                make.bottom.left.right.equalToSuperview()
            }
        }
        
        func relayoutHeaderIfNeed() {
            
            inputPlaceholder.isHidden = inputTF.text.count > 0
            
            var inputHeight: CGFloat = 56.auto()
            let unlockHeaderHeight: CGFloat = unlockView.isHidden ? 0 : (110.auto() + StatusBarHeight + unlockView.estimatedHeight)
            let regularHeaderHeight = unlockView.isHidden ? self.regularHeaderHeight : unlockHeaderHeight
            var headerHeight = regularHeaderHeight - inputHeight
            if !loadingView.isHidden { headerHeight += 30.auto() }
            
            if inputTF.text.count > 16 {
                let textHeight = inputTF.text.height(ofWidth: inputTF.width, attributes: [.font: XWallet.Font(ofSize:16, weight: .bold)])
                if textHeight > 34 { inputHeight = 78.auto() }
            }
            headerHeight += inputHeight
            
            if abs(inputBackgroud.height - inputHeight) > 1 {
                inputBackgroud.snp.updateConstraints { (make) in
                    make.height.equalTo(inputHeight)
                }
            }
            
            let headerView = mainListView.tableHeaderView
            if headerView != unlockHeader {
                
                if abs((headerView?.height ?? 0) - headerHeight) > 1 {
                    
                    header.height = headerHeight
                    header.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
                    header.snp.updateConstraints { (make) in
                        make.height.equalTo(headerHeight)
                    }
                    
                    mainListView.tableHeaderView = nil
                    headerView?.height = headerHeight
                    mainListView.tableHeaderView = headerView
                }
            } else {
                
                if abs((headerView?.height ?? 0) - headerHeight) > 1 {
                    
                    unlockHeader?.height = headerHeight
                    unlockHeader?.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
                    unlockHeader?.height = headerHeight
                    
                    mainListView.tableHeaderView = nil
                    headerView?.height = headerHeight
                    mainListView.tableHeaderView = headerView
                }
            }
        }
        
        private var unlockHeader: UIView?
        func relayoutForUnlockIfNeed() {
            if unlockHeader != nil { return }
            
            //newHeader...b
            header.removeFromSuperview()
            unlockHeader = UIView(frame: ScreenBounds, .white)
            unlockHeader?.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
            unlockHeader?.addSubview(headerContentView)
            headerContentView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            mainListView.tableHeaderView = nil
            mainListView.tableHeaderView = unlockHeader
            //newHeader...e
            
            //view.relayout...b
            self.addSubview(navBar)
            navBar.backgroundColor = .white
            navBar.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(8.auto() + FullNavBarHeight)
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(30.auto())
            }
            //view.relayout...e
        }
    }
}


extension SendTokenCommitViewController {
    class SectionView: UIView {
        
        let titleLabel = UILabel(font: XWallet.Font(ofSize: 24, weight: .bold))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(frame: CGRect, text: String) {
            super.init(frame: frame)
            
            backgroundColor = COLOR.title
            
            addSubview(titleLabel)
            titleLabel.text = text
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.centerY.equalToSuperview()
            }
        }
    }
}

//MARK: UnlockView
extension SendTokenCommitViewController {
    class UnlockView: UIView {
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        private lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_warning_white")
            return v
        }()
        
        private lazy var titleBGView = UIView(COLOR.title)
        private lazy var titleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        
        private lazy var bridgeAddressTLabel = UILabel(text: TR("CrossChain.AddressTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var bridgeAddressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 2)
        
        private lazy var descLabel = UILabel(text: TR("CrossChain.E2F.Tip"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
        lazy var feeProviderContainer = UIView(.white, cornerRadius: 16)
        lazy var tokenIV = CoinImageView(size: CGSize(width: 32, height: 32).auto())
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        lazy var feeProviderBalanceLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var feeProviderAddressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
        lazy var feeProviderPlaceHolderLabel = UILabel(text: TR("CrossChain.F2E.SelectETHAddress"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 2, bgColor: .white)
        lazy var feeProviderActionButton = UIButton(.clear)
        
        private lazy var feeTitleLabel = UILabel(text: TR("CrossChain.F2E.FeeTitle"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        lazy var feeLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        private lazy var feeErrorLabel = UILabel(text: TR("CrossChain.F2E.InsufficientFunds"), font: XWallet.Font(ofSize: 14, weight: .medium), textColor: HDA(0xFA6237))
        
        lazy var actionView = ApprovePanel(frame: .zero)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private lazy var regularTopHeight: CGFloat = {
            let descHeight = TR("CrossChain.E2F.Tip").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 240.auto() + descHeight
        }()
        
        var isE2F = true
        private let topPadding: CGFloat = 32.auto()
        private let titleBGHeight: CGFloat = 40.auto()
        var estimatedHeight: CGFloat {
            if isE2F { return topPadding + regularTopHeight + (32.auto() + actionView.estimatedHeight) + 16.auto() }
            
            let topHeight = feeErrorLabel.isHidden ? regularTopHeight : regularTopHeight + 24.auto()
            return topPadding + topHeight + (32.auto() + actionView.estimatedHeight) + 16.auto()
        }
        
        func relayout(isE2F: Bool) {
            
            self.isE2F = isE2F
            if isE2F {
                
            } else {
                
                let desc1Height = TR("CrossChain.E2F.Tip").height(ofWidth: ScreenWidth - (24 + 16).auto() * 2, attributes: [.font: XWallet.Font(ofSize: 12, weight: .medium)])
                let desc2Height = TR("CrossChain.F2E.BridgeDesc").height(ofWidth: ScreenWidth - (24 + 16).auto() * 2, attributes: [.font: XWallet.Font(ofSize: 12)])
                regularTopHeight = 340.auto() + desc1Height + desc2Height
                
                relayoutForF2E()
                relayout(isFeeError: false)
            }
        }
        
        private func configuration() {
            backgroundColor = .clear
            actionView.backgroundColor = .clear
        }
        
        private func layoutUI() {
            
            addSubviews([bgView, titleLabel, descLabel, tipButton, bridgeAddressTLabel, bridgeAddressLabel, actionView])
            bgView.addSubviews([titleBGView])
            
            bgView.snp.makeConstraints { (make) in
                make.top.equalTo(topPadding)
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(bridgeAddressLabel.snp.bottom).offset(16.auto())
            }
            
            //title...b
            titleBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(titleBGHeight)
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.height.equalTo(titleBGView)
                make.left.equalTo(bgView).offset(16.auto())
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.left.equalTo(titleLabel.snp.right).offset(8.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            //title...e
            
            //address...b
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bgView).offset((titleBGHeight + 16).auto())
                make.left.right.equalTo(bgView).inset(24.auto())
            }
            
            bridgeAddressTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(descLabel.snp.bottom).offset(24.auto())
                make.left.right.equalTo(bgView).inset(24.auto())
                make.height.equalTo(20.auto())
            }
            
            bridgeAddressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bridgeAddressTLabel.snp.bottom).offset(12.auto())
                make.left.right.equalTo(bgView).inset(24.auto())
            }
            //address...e
            
            actionView.snp.makeConstraints { (make) in
                make.top.equalTo(bgView.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(100.auto())
            }
        }
        
        func relayout(isFeeError: Bool) {
            
            feeErrorLabel.isHidden = !isFeeError
            bgView.snp.updateConstraints { (make) in
                make.bottom.equalTo(feeLabel.snp.bottom).offset(isFeeError ? 45.auto() : 24.auto())
            }
        }
        
        private func relayoutForF2E() {
            
            actionView.mode = .regular
            
            tokenIV.image = IMG("ic_token?")
            
            descLabel.text = TR("CrossChain.F2E.Tip")
            descLabel.font = XWallet.Font(ofSize: 12, weight: .medium)
            descLabel.textColor = HDA(0xFA6237)
            
            bridgeAddressLabel.lineBreakMode = .byTruncatingMiddle
            bridgeAddressTLabel.font = XWallet.Font(ofSize: 12)
            bridgeAddressTLabel.textColor = COLOR.subtitle
            bridgeAddressTLabel.text = TR("CrossChain.F2E.BridgeDesc")
            bridgeAddressTLabel.numberOfLines = 0
            
            addSubviews([feeProviderContainer, feeTitleLabel, feeLabel, feeErrorLabel])
            feeProviderContainer.addSubviews([tokenIV, arrowIV, feeProviderBalanceLabel, feeProviderAddressLabel, feeProviderPlaceHolderLabel, feeProviderActionButton])
            
            bgView.snp.remakeConstraints { (make) in
                make.top.equalTo(topPadding)
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(feeLabel.snp.bottom).offset(24.auto())
            }
            
            bridgeAddressTLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(bgView).offset((titleBGHeight + 16).auto())
                make.left.right.equalTo(bgView).inset(16.auto())
            }
            
            bridgeAddressLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(bridgeAddressTLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(18.auto())
            }
            
            descLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(bridgeAddressLabel.snp.bottom).offset(24.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
            }
            
            feeProviderContainer.snp.makeConstraints { (make) in
                make.top.equalTo(descLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(70.auto())
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.right.equalTo(-8.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            feeProviderBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(20)
            }
            
            feeProviderAddressLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(-16)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(18)
            }
            
            feeProviderPlaceHolderLabel.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(10)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
            }
            
            feeTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(feeProviderContainer.snp.bottom).offset(22.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(15.auto())
            }
            
            feeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(feeTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(18.auto())
            }
            
            feeErrorLabel.snp.makeConstraints { (make) in
                make.top.equalTo(feeLabel.snp.bottom).offset(4.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(18.auto())
            }
            
            actionView.snp.remakeConstraints { (make) in
                make.top.equalTo(bgView.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(actionView.estimatedHeight)
            }
        }
    }
}
