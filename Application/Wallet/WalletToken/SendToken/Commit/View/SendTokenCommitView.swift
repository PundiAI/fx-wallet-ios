//
//  SendTokenView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/10.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import XLPagerTabStrip

extension SendTokenCommitViewController {
    class View: UIView {
        lazy var backgroundView = UIView(HDA(0x080A32), cornerRadius: 36)
        
        private lazy var regularHeaderHeight: CGFloat = 277.auto() + StatusBarHeight
        lazy var headerHeight = regularHeaderHeight
        
        lazy var headerCell: UITableViewCell = {
            let v = UITableViewCell()
            v.size = CGSize(width: ScreenWidth, height: headerHeight)
            v.selectionStyle = .none
            v.backgroundColor = .clear
            v.contentView.backgroundColor = .clear
            return v
        }()
        
        lazy var headerContentView = UIView(.clear)
        
        lazy var headerBGView: UIView = {
            let v = UIView(.white)
            v.size = CGSize(width: ScreenWidth, height: headerHeight)
            v.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
            return v
        }()
        
        lazy var loadingView = FxTxLoadingView.loading24().then { $0.loading() }
        lazy var unlockView = UnlockView(frame: .zero)

        private var navBarMask: CALayer?
        lazy var navBar: FxBlurNavBar = {
            let v = FxBlurNavBar.standard()
            v.backgroundColor = .white
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
            v.keyboardType = .emailAddress
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var inputPlaceholder = UILabel(text: TR("SendToken.Commit.Placeholder"),
                                            font: XWallet.Font(ofSize:16),
                                            textColor: HDA(0x080A32).withAlphaComponent(0.5))
        
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
        lazy var mainListTopSpaceView = UIView(.white)
        lazy var mainListView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = UIColor.clear //HDA(0x080A32)
            v.gestureFilter = { _, _ in true }
            v.estimatedRowHeight = 0
            v.estimatedSectionHeaderHeight = 0
            v.estimatedSectionFooterHeight = 0
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
            loadingView.isHidden = true
        }
        
        var isEditing: Bool = false {
            didSet {
                inputBackgroud.borderColor = isEditing ? HDA(0x0552DC) : .clear
            }
        }
        
        var isEditable: Bool = true {
            didSet {
                mainListView.isUserInteractionEnabled = isEditable
                headerContentView.isUserInteractionEnabled = isEditable
            }
        }
        
        
        func loading(_ v: Bool) {
            
            if v { self.endEditing(true) }
            isEditable = !v
            nextButton.isHidden = v
            loadingView.isHidden = !v
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
            
            addSubviews([backgroundView,mainListTopSpaceView, mainListView, searchListView, navBar])
            headerCell.contentView.addSubviews([headerBGView, headerContentView])
            headerContentView.addSubviews([titleLabel, inputBackgroud, inputTF, inputPlaceholder, scanButton, nextButton, loadingView, unlockView])
            
            backgroundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            //header...b
            headerBGView.height = headerHeight
            headerBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(headerHeight)
            }
            
            headerContentView.snp.makeConstraints { (make) in
                make.edges.equalTo(headerBGView)
            }

            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + 8.auto())
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
            
            nextButton.snp.makeConstraints { (make) in
                make.top.equalTo(inputBackgroud.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            loadingView.snp.makeConstraints { (make) in
                make.center.equalTo(nextButton)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            unlockView.snp.makeConstraints { (make) in
                make.top.equalTo(inputBackgroud.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
            
            //header...e
//            mainListView.tableHeaderView = UIView(frame: headerContentView.frame, UIColor.clear) 
            mainListTopSpaceView.snp.makeConstraints { (make) in
                make.width.equalTo(ScreenWidth)
                make.height.equalTo(ScreenHeight * 3)
                make.bottom.equalTo(self.snp.top).offset(1)
            }
            mainListView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            searchListView.isHidden = true
            searchListView.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + (30 + 8).auto() + (32 + 56).auto())
                make.bottom.left.right.equalToSuperview()
            }
        }
        
        func relayoutHeaderIfNeed() {
            
            inputPlaceholder.isHidden = inputTF.text.count > 0
            
            var inputHeight: CGFloat = 56.auto()
            let unlockHeaderHeight: CGFloat = unlockView.isHidden ? 0 : (110.auto() + StatusBarHeight + inputHeight + unlockView.estimatedHeight)
            let regularHeaderHeight = unlockView.isHidden ? self.regularHeaderHeight : unlockHeaderHeight
            var headerHeight = regularHeaderHeight - inputHeight
            
            if inputTF.text.count > 16 {
                let textHeight = inputTF.text.height(ofWidth: inputTF.width, attributes: [.font: XWallet.Font(ofSize:16, weight: .bold)])
                if textHeight > 34 { inputHeight = 78.auto() }
            }
            headerHeight += inputHeight
            
            if abs(inputBackgroud.height - inputHeight) > 1 {
                
                let isInputing = inputTF.isFirstResponder
                inputBackgroud.snp.updateConstraints { (make) in
                    make.height.equalTo(inputHeight)
                }
                if isInputing {
                    
                    isEditable = false
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.inputTF.becomeFirstResponder()
                        self.isEditable = true
                    }
                }
            }
            
            updateHeader(headerHeight)
        }
        
        func relayoutForUnlockIfNeed() {
            unlockView.updateActionHeight()
        }
        
        private func updateHeader(_ height: CGFloat) {
            
            let old = self.headerHeight
            self.headerHeight = height
            if abs(old - height) > 1 {
                self.mainListView.contentOffset = .zero
                
                headerBGView.height = headerHeight
                headerBGView.addCorner([.bottomLeft, .bottomRight], radius: 36.auto())
                headerBGView.snp.updateConstraints { (make) in
                    make.height.equalTo(headerHeight)
                }
                mainListView.reloadData()
            }
        }
        
        func relayoutNavBar(showCorners: Bool) {
            
            if !showCorners {
                navBar.layer.mask = nil
            } else {
                
                if navBarMask == nil {
                    
                    let radius = backgroundView.cornerRadius
                    let bounds = CGRect(x: 0, y: 0, width: navBar.width, height: navBar.height)
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = bounds
                    maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
                    navBarMask = maskLayer
                }
                navBar.layer.mask = navBarMask!
            }
        }
    }
}

//MARK: UnlockView
extension SendTokenCommitViewController {
    class UnlockView: UIView {
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        
        lazy var tipButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_warning_white")
            return v
        }()
        
        private lazy var titleBGView = UIView(COLOR.title)
        private lazy var titleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        
        private lazy var fromTitleLabel = UILabel(text: TR("From"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        private lazy var toTitleLabel = UILabel(text: TR("To"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)

//        private lazy var bridgeAddressTLabel = UILabel(text: TR("CrossChain.AddressTitle"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
//        private lazy var descLabel = UILabel(text: TR("CrossChain.E2F.Tip"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0)
        
        lazy var crossChainLogo = CrossChainLogoView(size: CGSize(width: ScreenWidth - 40.auto() * 2, height: 77.auto()))
        
        lazy var actionView = ApprovePanel(frame: .zero)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        var isE2F = true
        private let topPadding: CGFloat = 32.auto()
        private let titleBGHeight: CGFloat = 40.auto()
        private lazy var crossChainHeight: CGFloat = 179.auto()
        var estimatedHeight: CGFloat {
            return topPadding + crossChainHeight + (32.auto() + actionView.estimatedHeight) + 24.auto()
        }
        
        func relayout(_ txType: FxTransaction.TxType) {
            
            let isE2F = txType == .ethereumToFx || txType == .ethereumToPay
            self.isE2F = isE2F
            crossChainLogo.config(txType)
            if !isE2F { actionView.mode = .regular }
        }
        
        private func configuration() {
            backgroundColor = .clear
            actionView.backgroundColor = .clear
//            actionView.tipLabel.text = ""
        }
        
        private func layoutUI() {
            
            addSubviews([bgView, titleLabel, tipButton])
            addSubviews([fromTitleLabel, toTitleLabel, crossChainLogo, actionView])
            bgView.addSubviews([titleBGView])
            
            bgView.snp.makeConstraints { (make) in
                make.top.equalTo(topPadding)
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(crossChainLogo.snp.bottom).offset(24.auto())
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
                make.right.equalTo(bgView).offset(-16.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            //title...e
            
            //token...b
            fromTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bgView).offset(titleBGHeight + 16.auto())
                make.left.equalTo(bgView).offset(16.auto())
                make.height.equalTo(14.auto())
            }

            toTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bgView).offset(titleBGHeight + 16.auto())
                make.left.equalTo(bgView.snp.centerX).offset(12.auto())
                make.height.equalTo(14.auto())
            }
            
            let csHeight = crossChainLogo.height
            crossChainLogo.snp.makeConstraints { (make) in
                make.top.equalTo(bgView).offset(titleBGHeight + 38.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(csHeight)
            }
            //token...e
            
            actionView.snp.makeConstraints { (make) in
                make.top.equalTo(bgView.snp.bottom).offset(32.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(actionView.estimatedHeight)
            }
        }
        
        fileprivate func updateActionHeight() {
            if actionView.mode == .regular { return }
            
            let height = actionView.estimatedHeight
            if actionView.height != height {
                actionView.snp.updateConstraints { (make) in
                    make.height.equalTo(height)
                }
            }
        }
    }
}





class SendTokenCommitPageBarCell: UICollectionViewCell {
    
    enum Types {
        case recent
        case mine
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layoutUI()
    }
    
    override var isSelected: Bool {
        didSet {
            textLabel.textColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    var type: Types?
    func bind(_ vm: IndicatorInfo) {
        textLabel.text = vm.title
        self.type = vm.userInfo as? Types
    }
    
    private func layoutUI() {
        
        let textHeight = 22
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-textHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(textHeight)
        }
    }
    
    lazy var textLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 18)
        v.textColor = UIColor.white.withAlphaComponent(0.5)
        v.textAlignment = .center
        v.backgroundColor = .clear
        return v
    }()
}


extension SendTokenCommitViewController {
    
    class PageCell: FxTableViewCell {
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(_ view: UIView) {
            self.view = view
            super.init(style: .default, reuseIdentifier: nil)
        }
        
        let view: UIView
        override func getView() -> UIView { view }
        
        var estimatedHeight: CGFloat { ScreenHeight - FullNavBarHeight }
    }
}
