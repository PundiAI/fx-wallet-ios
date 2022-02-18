//
//  TokenInfoHistorylItemView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension TokenInfoHistoryListBinder {
    
    class ItemView: UIView {
        
        private lazy var line = UIView(HDA(0x373737).withAlphaComponent(0.4))
        
        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = HDA(0x080A32)
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var hxLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        lazy var typeLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x080A32)
            v.backgroundColor = .clear
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
            self.backgroundColor = .white
        }
        
        private func layoutUI() {
            self.addSubviews([line])
            line.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            
            self.addSubviews([amountLabel, hxLabel, typeLabel])
            amountLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(16.auto())
                make.right.equalTo(hxLabel.snp.left).offset(-16.auto())
                make.height.equalTo(20.auto())
            }
            
            hxLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(amountLabel.snp.right).offset(16.auto())
                make.right.equalTo(typeLabel.snp.left).offset(-16.auto())
                make.height.equalTo(20.auto())
            }
            
            typeLabel.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualTo(100.auto())
                make.right.equalToSuperview().offset(-16.auto())
                make.height.equalTo(20.auto())
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            typeLabel.sizeToFit()
        }
    }
}


extension TokenInfoHistoryListBinder {
    
    class ETHView: UIView {
        
        lazy var txTypeIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = HDA(0xF4F4F4)
            v.autoCornerRadius = 24
            return v
        }()
        
        lazy var txIcon: UIImageView = {
            let v = UIImageView()
            return v
        }()
        
        lazy var moneyLabel = UILabel(text: TR("~"), font: XWallet.Font(ofSize: 18, weight: .medium)).then { $0.textColor = COLOR.title }
        lazy var functionLabel = UILabel(text: TR("~"), font: XWallet.Font(ofSize: 14)).then { $0.textColor = COLOR.title }
        
        lazy var infoContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var feeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var stateContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 5.auto()
            v.alignment = .center
            v.distribution = .equalCentering
            return v
        }()
        
        lazy var timeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            v.backgroundColor = .clear
            return v
        }()
        
        
        
        lazy var sepLine = UIView(HDA(0xEBEEF0))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            self.backgroundColor = .white
            functionLabel.adjustsFontSizeToFitWidth = true
        }
        
        private func layoutUI() {
            addSubviews([txTypeIcon, moneyLabel, functionLabel, infoContainer, feeLabel, stateContainer, timeLabel])
            
            txTypeIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
                make.left.equalTo(self.snp.left).offset(24.auto())
                make.top.equalTo(self.snp.top).offset(16.auto())
            }
            
            txTypeIcon.addSubview(txIcon)
            txIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.center.equalToSuperview()
            }
            
            moneyLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(19.auto())
                make.height.equalTo(22.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
            }
            
            functionLabel.snp.makeConstraints { (make) in
                make.top.equalTo(moneyLabel.snp.bottom).offset(2.auto())
                make.height.equalTo(17.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
                make.right.equalTo(self.snp.right).offset(-16.auto())
            }
            
            infoContainer.snp.makeConstraints { (make) in
                make.height.equalTo(24.auto())
                make.left.equalTo(moneyLabel.snp.left)
                make.top.equalTo(functionLabel.snp.bottom).offset(16.auto())
            }
            
            feeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22.auto())
                make.left.right.equalTo(moneyLabel)
                make.top.equalTo(infoContainer.snp.bottom).offset(2.auto())
            }
            
            stateContainer.snp.makeConstraints { (make) in
                make.height.equalTo(22.auto())
                make.left.equalTo(moneyLabel.snp.left)
                make.bottom.equalTo(self.snp.bottom).offset(-16.auto())
            }
            
            timeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.right.equalTo(self.snp.right).offset(-16.auto())
                make.bottom.equalTo(self.snp.bottom).offset(-16.auto())
            }
        }
        
        func relayoutForTx(_ txType: TxType = .invalid) {
            switch txType {
            case .transIn:
                feeLabel.isHidden = true
            case .transOut:
                feeLabel.isHidden = false
            default:
                break
            }
        }
        
        func defaultLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.text = text
            return v
        }
        
        func titleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func subTitleLabel(text: String, textColor: UIColor = COLOR.title) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = textColor
            v.text = text
            return v
        }
        
        func addressTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x0552DC)
            v.text = text
            v.textAlignment = .right
            return v
        }
        
        func contractButton(text: String) -> UIButton {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 22.auto()))
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = COLOR.title
            v.backgroundColor =  HDA(0xF0F3F5)
            v.autoCornerRadius = 11
            v.title = text
            v.isUserInteractionEnabled = false
            v.contentEdgeInsets = UIEdgeInsets(top: 2, left: 11, bottom: 2, right: 11).auto()
            return v
        }
        
        func stateLabel(text: String, state: TokenInfoTxInfo.TxState = .cancel) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            var textcolor = COLOR.title
            switch state {
            case .success, .pending:
                textcolor = COLOR.title
            case .failed:
                textcolor = HDA(0xFA6237)
            case .cancel:
                textcolor = COLOR.title.withAlphaComponent(0.2)
            }
            v.textColor = textcolor
            v.text = text
            return v
        }
        
        func tagButton(text: String) -> UIButton {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 22.auto()))
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = .white
            v.backgroundColor = HDA(0x0552DC)
            v.autoCornerRadius = 11
            v.title = text
            v.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
            v.isUserInteractionEnabled = false
            v.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            return v
        }
        
        func contractLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.backgroundColor = HDA(0xF0F3F5)
            v.autoCornerRadius = 11
            v.textAlignment = .center
            v.text = text
            return v
        }
        
        func waittingView() -> FxTxLoadingView  {
            return FxTxLoadingView.loading16().then { $0.loading() }
        }
        
        func alertView() -> UIImageView  {
            let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 24.auto(), height: 24.auto()))
            v.image = IMG("Tx.Info")
            return v
        }
        
//        func helpView() -> UIImageView  {
//            let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 24.auto(), height: 24.auto()))
//            v.image = IMG("infoB")
//            return v
//        }
        func helpView() -> HelpView  {
            let v = HelpView(frame: CGRect(x: 0, y: 0, width: 100.auto(), height: 24.auto()))
            return v
        }
    }
}

extension TokenInfoHistoryListBinder {
    
    class BTCView: UIView {
        
        lazy var txTypeIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = HDA(0xF4F4F4)
            v.autoCornerRadius = 24
            //            v.contentMode = .scaleAspectFit
            return v
        }()
        
        lazy var txIcon: UIImageView = {
            let v = UIImageView()
            return v
        }()
        
        lazy var moneyContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var addressContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .vertical
            v.spacing = 0.auto()
            v.alignment = .fill
            v.distribution = .fillProportionally
            return v
        }()
        
        lazy var stateContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 5.auto()
            v.alignment = .center
            v.distribution = .fillProportionally
            return v
        }()
        
        lazy var timeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var sepLine = UIView(HDA(0xEBEEF0))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            self.backgroundColor = .white
        }
        
        private func layoutUI() {
            addSubviews([txTypeIcon, moneyContainer, stateContainer, timeLabel, sepLine])
            
            txTypeIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
                make.left.equalTo(self.snp.left).offset(24.auto())
                make.top.equalTo(self.snp.top).offset(16.auto())
            }
            
            txTypeIcon.addSubview(txIcon)
            txIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.center.equalToSuperview()
            }
            
            moneyContainer.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(19.auto())
                make.height.equalTo(22.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
            }
            
            stateContainer.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.left.equalTo(moneyContainer.snp.left)
                make.top.equalTo(moneyContainer.snp.bottom).offset(4.auto())
            }
            
            timeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.right.equalTo(self.snp.right).offset(-24.auto())
                make.bottom.equalTo(stateContainer.snp.bottom)
            }
            
            sepLine.snp.makeConstraints { (make) in
                make.left.equalTo(moneyContainer.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(0.5)
                //                make.top.equalToSuperview().offset(79.auto())
                make.top.equalTo(stateContainer.snp.bottom).offset(20.auto())
            }
            addSubview(addressContainer)
            addressContainer.snp.makeConstraints { (make) in
                make.left.equalTo(moneyContainer.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
                make.top.equalTo(sepLine.snp.bottom)
                make.bottom.equalToSuperview()
                make.height.greaterThanOrEqualTo(38.auto())
            }
        }
        
        func defaultLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.text = text
            return v
        }
        
        func titleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func subTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func addressTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x0552DC)
            v.text = text
            v.textAlignment = .right
            return v
        }
        
        func stateLabel(text: String, state: TokenInfoTxInfo.TxState = .cancel) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            var textcolor = COLOR.title
            switch state {
            case .success, .pending:
                textcolor = COLOR.title
            case .failed:
                textcolor = HDA(0xFA6237)
            case .cancel:
                textcolor = COLOR.title.withAlphaComponent(0.2)
            }
            v.textColor = textcolor
            v.text = text
            return v
        }
        
        func tagButton(text: String) -> UIButton {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 22.auto()))
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = .white
            v.backgroundColor = HDA(0x0552DC)
            v.autoCornerRadius = 11
            v.title = text
            v.contentEdgeInsets = UIEdgeInsets(top: 2, left: 11, bottom: 2, right: 11).auto()
            return v
        }
        
        func contractLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.backgroundColor = HDA(0xF0F3F5)
            
            v.autoCornerRadius = 11
            v.textAlignment = .center
            v.text = text
            return v
        }
        
        func waittingView() -> FxTxLoadingView  {
            return FxTxLoadingView.loading16().then { $0.loading() }
        }
        
        func alertView() -> UIImageView  {
            let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 24.auto(), height: 24.auto()))
            v.image = IMG("Tx.Info")
            return v
        }
        
//        func helpView() -> UIImageView  {
//            let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 24.auto(), height: 24.auto()))
//            v.image = IMG("infoB")
//            return v
//        }
        func helpView() -> HelpView  {
            let v = HelpView(frame: CGRect(x: 0, y: 0, width: 100.auto(), height: 24.auto()))
            return v
        }
    }
}


extension TokenInfoHistoryListBinder {
    
    class ChainView: UIView {
        
        lazy var cIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = UIColor.white
            v.autoCornerRadius = 8
            v.clipsToBounds = true
            return v
        }()
        
        //        let tokenIconView = UIImageView(frame: CGRect.zero).then {
        //            $0.autoCornerRadius = 8
        //            $0.backgroundColor = UIColor.white
        //            $0.clipsToBounds = true
        //            $0.image = IMG("ethereum32")
        //        }
        
        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = COLOR.title
            v.textAlignment = .left
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
        
        private func configuration() {
            self.backgroundColor = HDA(0xF0F3F5)
            self.cornerRadius = 16
        }
        
        private func layoutUI() {
            addSubviews([cIcon, nameLabel])
            
            cIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
                make.left.equalTo(self.snp.left).offset(12.auto())
                make.top.equalTo(self.snp.top).offset(12.auto())
            }
            
            nameLabel.snp.makeConstraints { (make) in
                make.height.equalTo(17.auto())
                make.left.right.equalToSuperview().inset(12.auto())
                make.top.equalTo(cIcon.snp.bottom).offset(4.auto())
            }
        }
    }
    
    
    class ChainPannel: UIView {
        
        lazy var fromChain: ChainView = {
            let v = ChainView()
            return v
        }()
        
        lazy var covertIcon: UIImageView = {
            let v = UIImageView()
            return v
        }()
        
        lazy var toChain: ChainView = {
            let v = ChainView()
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
            self.backgroundColor = .white
            covertIcon.image = IMG("Tx.CrossChainB")
        }
        
        private func layoutUI() {
            addSubviews([fromChain, covertIcon, toChain])
            
            fromChain.snp.makeConstraints { (make) in
                make.height.equalTo(77.auto())
                make.left.equalToSuperview().offset(88.auto())
                make.width.equalTo(120.auto())
                make.centerY.equalToSuperview()
            }
            
            covertIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview()
                make.left.equalTo(fromChain.snp.right)
            }
            
            toChain.snp.makeConstraints { (make) in
                make.height.equalTo(77.auto())
                make.left.equalTo(covertIcon.snp.right)
                make.width.equalTo(fromChain.snp.width)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    class CorssChainView: UIView {
        
        lazy var txTypeIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = HDA(0xF4F4F4)
            v.autoCornerRadius = 24
            return v
        }()
        
        lazy var txIcon: UIImageView = {
            let v = UIImageView()
            return v
        }()
        
        lazy var fromMoneyContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var fromMoneyLabel = UILabel(text: TR("~"), font: XWallet.Font(ofSize: 18, weight: .medium)).then { $0.textColor = COLOR.title }
        lazy var toMoneyLabel = UILabel(text: TR("~"), font: XWallet.Font(ofSize: 18, weight: .medium)).then { $0.textColor = COLOR.title }
        
        lazy var fromInfoContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var feeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var bridgeFeeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var fromStateContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 5.auto()
            v.alignment = .center
            v.distribution = .equalCentering
            return v
        }()
        
        lazy var fromTimeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            v.backgroundColor = .clear
            return v
        }()
  
        lazy var crossChainLogo = CrossChainLogoView(size: CGSize(width: ScreenWidth - 40.auto() * 2, height: 77.auto()))
        
        lazy var toMoneyContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var toInfoContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var toStateContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 5.auto()
            v.alignment = .center
            v.distribution = .equalCentering
            return v
        }()
        
        lazy var toTimeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
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
        
        private func configuration() {
            self.backgroundColor = .white
            crossChainLogo.fromTokenContainer.backgroundColor = HDA(0xF0F3F5)
            crossChainLogo.toTokenContainer.backgroundColor = HDA(0xF0F3F5)
        }
        
        private func layoutUI() {
            addSubviews([txTypeIcon, txIcon,  fromMoneyLabel, fromInfoContainer, feeLabel, bridgeFeeLabel, fromStateContainer, fromTimeLabel])
            
            txTypeIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
                make.left.equalTo(self.snp.left).offset(24.auto())
                make.top.equalTo(self.snp.top).offset(16.auto())
            }
            
            txTypeIcon.addSubview(txIcon)
            txIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.center.equalToSuperview()
            }
            
            fromMoneyLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(19.auto())
                make.height.equalTo(22.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
                make.right.equalToSuperview().offset(-24.auto())
            }
            
            fromInfoContainer.snp.makeConstraints { (make) in
                make.height.equalTo(24.auto())
                make.left.equalTo(fromMoneyLabel.snp.left)
                make.top.equalTo(fromMoneyLabel.snp.bottom).offset(2.auto())
            }
            
            
            feeLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(fromMoneyLabel)
                make.height.equalTo(22.auto())
                make.top.equalTo(fromInfoContainer.snp.bottom).offset(2.auto())
            }
            
            bridgeFeeLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(fromMoneyLabel)
                make.height.equalTo(22.auto())
                make.top.equalTo(fromInfoContainer.snp.bottom).offset(2.auto())
            }
            
            bridgeFeeLabel.isHidden = true
            
            
            fromStateContainer.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.left.equalTo(feeLabel.snp.left)
                make.top.equalTo(feeLabel.snp.bottom).offset(8.auto())
            }
            
            fromTimeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.right.equalTo(self.snp.right).offset(-24.auto())
                make.bottom.equalTo(fromStateContainer.snp.bottom)
            }
            
            addSubviews([crossChainLogo])
            
            crossChainLogo.snp.makeConstraints { (make) in
                make.height.equalTo(77.auto())
                make.left.equalToSuperview().offset(88.auto())
                //                make.left.right.equalToSuperview()
                make.right.equalToSuperview().offset(-24.auto())
                make.top.equalTo(fromStateContainer.snp.bottom).offset(24.auto())
            }
            
            
            addSubviews([toMoneyLabel, toInfoContainer, toStateContainer, toTimeLabel])
            
            
            toMoneyLabel.snp.makeConstraints { (make) in
                make.top.equalTo(crossChainLogo.snp.bottom).offset(24.auto())
                make.height.equalTo(22.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
            }
            
            toInfoContainer.snp.makeConstraints { (make) in
                make.height.equalTo(24.auto())
                make.left.equalTo(toMoneyLabel.snp.left)
                make.top.equalTo(toMoneyLabel.snp.bottom).offset(2.auto())
            }
            
            toStateContainer.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.left.equalTo(toInfoContainer.snp.left)
                make.top.equalTo(toInfoContainer.snp.bottom).offset(8.auto())
            }
            
            toTimeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.right.equalTo(self.snp.right).offset(-24.auto())
                make.bottom.equalTo(toStateContainer.snp.bottom)
            }
        }
        
        func defaultLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.text = text
            return v
        }
        
        func titleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func subTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func addressTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x0552DC)
            v.text = text
            v.textAlignment = .right
            return v
        }
        
        func stateLabel(text: String, state: TokenInfoTxInfo.TxState = .cancel) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            var textcolor = COLOR.title
            switch state {
            case .success, .pending:
                textcolor = COLOR.title
            case .failed:
                textcolor = HDA(0xFA6237)
            case .cancel:
                textcolor = COLOR.title.withAlphaComponent(0.2)
            }
            v.textColor = textcolor
            v.text = text
            return v
        }
        
        func subTitleLabel(text: String, textColor: UIColor = COLOR.title) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = textColor
            v.text = text
            return v
        }
        
        func tagButton(text: String) -> UIButton {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 22.auto()))
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = .white
            v.backgroundColor = HDA(0x0552DC)
            v.autoCornerRadius = 11
            v.title = text
            v.contentEdgeInsets = UIEdgeInsets(top: 2, left: 11, bottom: 2, right: 11).auto()
            return v
        }
        
        
        
        func contractLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.backgroundColor = HDA(0xF0F3F5)
            
            v.autoCornerRadius = 11
            v.textAlignment = .center
            v.text = text
            return v
        }
        
        func contractButton(text: String) -> UIButton {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 22.auto()))
            v.titleFont = XWallet.Font(ofSize: 14)
            v.backgroundColor =  HDA(0xF0F3F5)
            v.autoCornerRadius = 11
            v.title = text
            v.titleColor = text == Node.Chain.functionX.rawValue ? HDA(0x0552DC) : COLOR.title
            v.isUserInteractionEnabled = false
            v.contentEdgeInsets = UIEdgeInsets(top: 2, left: 11, bottom: 2, right: 11).auto()
            return v
        }
        
        func waittingView() -> FxTxLoadingView  {
            return FxTxLoadingView.loading16().then { $0.loading() }
        }
        
        func alertView() -> UIImageView  {
            let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 24.auto(), height: 24.auto()))
            v.image = IMG("Tx.Info")
            return v
        }
        
        func helpView() -> HelpView  {
            let v = HelpView(frame: CGRect(x: 0, y: 0, width: 100.auto(), height: 24.auto()))
            return v
        }
        
    }
}


class HelpView: UIView {
    
    lazy var tipIcon: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    lazy var tipLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 14, weight: .medium)
        v.textColor = COLOR.title
        v.textAlignment = .left
        v.backgroundColor = .clear
        return v
    }()
    
    lazy var tapBtn: UIButton = {
        let v = UIButton()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        logWhenDeinit()
        configuration()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configuration() {
        tipIcon.image = IMG("infoB")
        tipLabel.text = TR("Help")
    }
    
    private func layoutUI() {
        addSubviews([tipIcon, tipLabel, tapBtn])
        tipIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 24, height: 24).auto())
            make.left.equalTo(self.snp.left)
            make.centerY.equalToSuperview()
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16.auto())
            make.left.equalTo(tipIcon.snp.right)
            make.centerY.equalToSuperview()
        }
        
        tapBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
