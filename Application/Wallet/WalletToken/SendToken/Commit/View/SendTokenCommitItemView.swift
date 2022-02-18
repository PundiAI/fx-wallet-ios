//
//  SendTokenCommitItemView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

//MARK: Recent
extension SendTokenCommitRecentPageListBinder {
    class Cell: FxTableViewCell {
        
        lazy var background = UIView(UIColor.white.withAlphaComponent(0.08))
        lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white).then{ $0.lineBreakMode = .byTruncatingMiddle }
        lazy var timeLabel = UILabel(font: XWallet.Font(ofSize: 12, weight: .medium), textColor: UIColor.white.withAlphaComponent(0.5))
        lazy var remarkLabel = UIButton().then{
            $0.backgroundColor = HDA(0x0552DC)
            $0.titleFont = XWallet.Font(ofSize: 12)
            $0.titleColor = .white
            $0.titleLabel?.lineBreakMode = .byTruncatingTail
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 8.auto()
        }
        
        lazy var coinTypeView = CoinTypeView().then{ $0.style = .lightContent }
        
        override func configuration() {
            backgroundColor = COLOR.title
            remarkLabel.isHidden = true
        }
        
        override func layoutUI() {
            contentView.addSubviews([background, addressLabel, coinTypeView, remarkLabel, timeLabel])
            
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.right.equalTo(background).inset(24.auto())
                make.height.equalTo(19.auto())
            }
            
            coinTypeView.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(background).offset(24.auto())
                make.size.equalTo(CGSize(width: 0, height: 16.auto()))
            }
            
            remarkLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(coinTypeView)
                make.left.equalTo(coinTypeView.snp.right).offset(16.auto())
                make.height.equalTo(16.auto())
                make.width.greaterThanOrEqualTo(40)
                make.width.lessThanOrEqualTo(100)
            }
            
            timeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(40.auto())
                make.left.equalTo(background).offset(24.auto())
                make.height.equalTo(16.auto())
            }
        }
        
        func relayout(hasName: Bool, hasRemark: Bool) {
            remarkLabel.isHidden = hasName || !hasRemark
//            coinTypeView.isHidden = hasName
//            
//            timeLabel.snp.updateConstraints { (make) in
//                make.top.equalTo(addressLabel.snp.bottom).offset(hasName ? 16.auto() : 40.auto())
//            }
        }
        
        func addCorner(top: Bool, bottom: Bool, height: CGFloat) {
            guard top || bottom else {
                background.layer.mask = nil
                return
            }
            
            var corners: UIRectCorner = []
            if top, bottom {
                corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            } else if top {
                corners = [.topLeft, .topRight]
            } else if bottom {
                corners = [.bottomLeft, .bottomRight]
            }
            
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth - 24.auto() * 2, height: height)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16).auto()).cgPath
            background.layer.mask = maskLayer
        }
    }
}

extension SendTokenCommitRecentPageListBinder {
    class NoDataCell: FxTableViewCell {
        
        private lazy var background = UIView(UIColor.white.withAlphaComponent(0.08), cornerRadius: 16)
        private lazy var titleLabel = UILabel(text: TR("NoData"), font: XWallet.Font(ofSize: 16, weight: .medium))
        private lazy var subtitleLabel = UILabel(text: TR("SendToken.Commit.NoRecents"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5), lines: 0, alignment: .center)
        lazy var estimatedHeight: CGFloat = {
            
            let subtitleHeight = TR("SendToken.Commit.NoRecents").height(ofWidth: ScreenWidth - 24.auto(), attributes: [.font: XWallet.Font(ofSize: 14)])
            return (44 + 8).auto() + subtitleHeight + 20.auto()
        }()
        
        override func layoutUI() {
            
            addSubviews([background, titleLabel, subtitleLabel])
            
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(background).inset(24.auto())
                make.centerX.equalTo(background)
                make.height.equalTo(20)
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(background).inset(24.auto())
            }
        }
        
    }
}


//MARK: Mine
extension SendTokenCommitMinePageListBinder {
    class Header: UITableViewHeaderFooterView {
        
        lazy var chainNameLabel = UILabel(font: XWallet.Font(ofSize: 20, weight: .medium), textColor: .white)
        lazy var chainView: ChainTypeButton = {
            let v = ChainTypeButton()
            v.style = .lightContent
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
            backgroundColor = COLOR.title
            contentView.backgroundColor = COLOR.title
        }
        
        private func layoutUI() {
            contentView.addSubviews([chainNameLabel, chainView])
            
            chainNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.equalTo(48.auto())
                make.height.equalTo(24.auto())
            }
            
            chainView.snp.makeConstraints { (make) in
                make.bottom.equalTo(chainNameLabel)
                make.left.equalTo(chainNameLabel.snp.right).offset(8.auto())
                make.height.equalTo(16.auto())
            }
        }
    }
}


extension SendTokenCommitMinePageListBinder {
    class Cell: FxTableViewCell {
        
        lazy var background = UIView(UIColor.white.withAlphaComponent(0.08))
        lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white).then{ $0.lineBreakMode = .byTruncatingMiddle }
        
        lazy var remarkLabel = UIButton().then{
            $0.backgroundColor = HDA(0x0552DC)
            $0.titleFont = XWallet.Font(ofSize: 12)
            $0.titleColor = .white
            $0.titleLabel?.lineBreakMode = .byTruncatingTail
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 8.auto()
        }
        
        override func configuration() {
            backgroundColor = .clear
        }
        
        override func layoutUI() {
            contentView.addSubviews([background, addressLabel, remarkLabel])
            
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(background).offset(24.auto())
                make.left.right.equalTo(background).inset(24.auto())
                make.height.equalTo(19.auto())
            }
            
            remarkLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(addressLabel)
                make.height.equalTo(16.auto())
                make.width.greaterThanOrEqualTo(40)
                make.width.lessThanOrEqualTo(100)
            }
        }
        
        func addCorner(top: Bool, bottom: Bool, height: CGFloat) {
            guard top || bottom else {
                background.layer.mask = nil
                return
            }
            
            var corners: UIRectCorner = []
            if top, bottom {
                corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            } else if top {
                corners = [.topLeft, .topRight]
            } else if bottom {
                corners = [.bottomLeft, .bottomRight]
            }
            
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth - 24.auto() * 2, height: height)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16).auto()).cgPath
            background.layer.mask = maskLayer
        }
    }
}
