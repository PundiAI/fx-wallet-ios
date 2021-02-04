//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import UIKit

extension AllPurchaseViewController {
    class View: UIView {
        lazy var listView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
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
            backgroundColor = .white
        }
        
        private func layoutUI() {
            addSubview(listView)
            listView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 24.auto()), .clear)
            listView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 8.auto()), .clear)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
        }
    }
}
        
