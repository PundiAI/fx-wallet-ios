//
//
//  XWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension FxValidatorListViewController {
    class ItemView: UIView {
        
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
            
        }
    
    }
}
        


extension FxValidatorListViewController {
    
    class ValidatorItemView: UIView {
        
        lazy var indexLabel = UILabel(font: XWallet.Font(ofSize: 12, weight: .medium), textColor: COLOR.subtitle)
        lazy var tokenIV = CoinImageView(size: CGSize(width: 32, height: 32).auto())
        lazy var nameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var apyLabel = UILabel(font: XWallet.Font(ofSize: 16), textColor: HDA(0x71A800))
        
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = HDA(0xF0F3F5)
        }
        
        private func layoutUI() {
            addSubviews([indexLabel, tokenIV, nameLabel, apyLabel])
            
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(44.auto())
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }

            indexLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(16.auto())
            }

            nameLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.snp.centerY)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalToSuperview().offset(-16.auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.centerY)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalToSuperview().offset(-16.auto())
            }
        }
        
        func layoutCorner(_ c: (Bool, Bool)?, size: CGSize) {
            guard let (top, bottom) = c, top || bottom else {
                layer.mask = nil
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
            addCorner(corners, size: size)
        }
    }
}



extension FxValidatorListViewController {
    class NoDataCell: FxTableViewCell {
        
        private lazy var background: UIView = {
            let v = UIView(HDA(0xF0F3F5))
            v.addCorner([.bottomLeft, .bottomRight], size: CGSize(width: ScreenWidth - (24 * 2).auto(), height: NoDataCell.height(model: nil)))
            return v
        }()
        
        private lazy var titleLabel = UILabel(text: TR("NoData"), font: XWallet.Font(ofSize: 16, weight: .bold), textColor: HDA(0x080A32))
        private lazy var subtitleLabel = UILabel(text: TR("TokenList.NoResultNotice"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        override class func height(model: Any?) -> CGFloat {
            
            let subtitleHeight = TR("TokenList.NoResultNotice").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 48.auto() + subtitleHeight + 20.auto()
        }
        
        override func layoutUI() {
            
            contentView.addSubviews([background, titleLabel, subtitleLabel])
            background.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(20.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(20.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
