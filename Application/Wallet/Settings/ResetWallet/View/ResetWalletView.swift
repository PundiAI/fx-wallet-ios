//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension ResetWalletViewController {
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
            addSubview(listView)
            listView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(FullNavBarHeight)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }
}
