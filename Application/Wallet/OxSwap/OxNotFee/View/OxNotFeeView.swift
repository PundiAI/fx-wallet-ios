//
//
//  XWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension OxNotFeeViewController {
    
    class ItemView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.autoFont = true
            v.textAlignment = .left
            return v
        }()
        
        lazy var valueLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: .white)
            v.autoFont = true
            v.textAlignment = .right
            return v
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            logWhenDeinit()
            layoutUI()
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, valueLabel])
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16.auto())
                make.top.bottom.equalToSuperview()
            }
            
            valueLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16.auto())
                make.top.bottom.equalToSuperview()
                make.left.equalTo(titleLabel.snp.right).offset(20.auto())
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class PanelView: UIView {
        static var contentHeight:CGFloat { 114.auto() }
        var payItem: ItemView = ItemView(frame: .zero)
        var balanceItem: ItemView = ItemView(frame: .zero)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            payItem.titleLabel.text = TR("Ox.NotFee.Title2")
            balanceItem.titleLabel.text = TR("Ox.NotFee.Title3")
            backgroundColor = HDA(0xFFFFFF).withAlphaComponent(0.08)
            autoCornerRadius = 16
        }
        
        private func layoutUI() {
            addSubviews([payItem, balanceItem])
            
            payItem.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(48.auto())
                make.bottom.equalTo(self.snp.centerY)
            }
            
            balanceItem.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(48.auto())
                make.top.equalTo(self.snp.centerY)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class ContentCell: FxTableViewCell {
        static var messageString0 = TR("Ox.NotFee.Title")
        static var messageString1 = TR("Ox.NotFee.SubTitle")
        
        
        private lazy var tipBackground: UIView =  {
            let v = UIView(.white)
            v.autoCornerRadius = 28
            return v
        }()
        
        private lazy var tipIV = UIImageView(image: IMG("ic_not_notify"))
        
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: ContentCell.messageString0,
                            font: XWallet.Font(ofSize: 20, weight: .medium), textColor: .white)
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: ContentCell.messageString1,
                            font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
        
        private lazy var pannel: PanelView = {
            let v = PanelView(frame: .zero)
            return v
        }()
        
        var payLabel: UILabel { pannel.payItem.valueLabel}
        var balanceLabel: UILabel { pannel.balanceItem.valueLabel}
        
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2 * 2
            
            let font:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = messageString0
                $0.autoFont = true }.font
            
            let noticeHeight1 = ContentCell.messageString0.height(ofWidth: width, attributes: [.font:font])
            
            let font2:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14, weight: .medium)
                $0.text = messageString0
                $0.autoFont = true }.font
            
            let noticeHeight2 = ContentCell.messageString1.height(ofWidth: width, attributes: [.font:font2])
            
            let contentHeight = (32 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2) + 24.auto()
            return contentHeight + PanelView.contentHeight + 16.auto()
        }
        
        override func layoutUI() {
            contentView.addSubviews([tipBackground, tipIV, noticeLabel1, noticeLabel2, pannel])
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            pannel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(PanelView.contentHeight)
                make.top.equalTo(noticeLabel2.snp.bottom).offset(32.auto())
            }
        }
    }
}

extension OxNotFeeViewController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        
        var confirmButton: UIButton { submitButton }
        
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Ok.Thanks")
        }
    }
}
