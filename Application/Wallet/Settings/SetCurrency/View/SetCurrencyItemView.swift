//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension SetCurrencyViewController {
    class ItemView: UIView {
        
        lazy var selectIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(XWallet.Font(ofSize: 18), COLOR.title.withAlphaComponent(0.6), .left)
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
            selectIcon.image = IMG("selectedB")
        }
        
        private func layoutUI() {
            addSubview(selectIcon)
            addSubview(titleLabel)
            
            selectIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalTo(16.auto())
                make.centerY.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.top.bottom.equalToSuperview()
                make.left.equalTo(selectIcon.snp.right).offset(8.auto())
            }
        }
    }
}

extension SetCurrencyViewController {
    
    class SectionView: UIView {
        let titleLabel = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(titleLabel)
            backgroundColor = HDA(0xF9FAFB)
            titleLabel.textColor = COLOR.subtitle
            titleLabel.font = XWallet.Font(ofSize: 16)
            titleLabel.snp.makeConstraints { (make) in
                make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: 48.auto(), bottom: 0, right: 0))
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



