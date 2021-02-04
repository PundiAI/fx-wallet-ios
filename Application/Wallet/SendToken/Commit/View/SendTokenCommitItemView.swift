//
//  SendTokenCommitItemView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/8/12.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension SendTokenCommitViewController {
    class ItemView: UIView {
        
        lazy var background = UIView(UIColor.white.withAlphaComponent(0.08))
        lazy var textLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium))
            v.lineBreakMode = .byTruncatingMiddle
            v.autoFont = true
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
            addSubviews([background, textLabel])
            
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            textLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(background).inset(24.auto())
                make.centerY.equalTo(background)
            }
        }
        
        func addCorner(top: Bool, bottom: Bool) {
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
            
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth - 24.auto() * 2, height: 62.auto())
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16).auto()).cgPath
            background.layer.mask = maskLayer
        }
    }
}


extension SendTokenCommitViewController {
    class NoRecentsCell: FxTableViewCell {
        
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
