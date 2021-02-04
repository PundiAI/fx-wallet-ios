//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension CryptoBankTxHistoryViewController {
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .grouped)
        
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
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight + 8.auto(), left: 24.auto(), bottom: 0, right: 24.auto()))
            }
        }
    }
}
