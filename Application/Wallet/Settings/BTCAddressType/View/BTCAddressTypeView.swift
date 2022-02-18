//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua
//  Copyright © 2017 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import TrustWalletCore

extension BTCAddressTypeViewController {
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
        }
        
        private func layoutUI() {
            
            addSubviews([listView])
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
        }
    }
}
        
extension BTCAddressTypeViewController {
    class Cell: FxTableViewCell {
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 16), textColor: COLOR.subtitle)
        
        private lazy var bgView = UIView(COLOR.settingbc, cornerRadius: 16)
        lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 18), textColor: COLOR.title).then{ $0.lineBreakMode = .byTruncatingMiddle }
        lazy var pathLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
         
        lazy var checkIV = UIImageView(image: IMG("ic_check"))
        
        var purpose: Purpose?
        
        override class func height(model: Any?) -> CGFloat { (44 + 114).auto() }
        
        override func layoutUI() {
            checkIV.isHidden = true
            contentView.addSubviews([titleLabel, bgView])
            bgView.addSubviews([addressLabel, pathLabel, checkIV])
            
            let edge: CGFloat = 24.auto()
            bgView.snp.makeConstraints { (make) in
                make.top.equalTo(44.auto())
                make.left.right.equalToSuperview().inset(edge)
                make.height.equalTo(114.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(bgView.snp.top).offset(-16.auto())
                make.left.equalTo(edge)
                make.height.equalTo(20.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(34.auto())
                make.left.equalTo(edge)
                make.right.equalTo(-72.auto())
                make.height.equalTo(20.auto())
            }
            
            pathLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(edge)
                make.height.equalTo(20.auto())
            }
            
            checkIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-edge)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
    }
}
