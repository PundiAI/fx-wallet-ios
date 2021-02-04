//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension FxValidatorOverviewViewController {
    class Cell: FxTableViewCell {
        
        override class func height(model: Any?) -> CGFloat { 71.auto() }
        
        override func layoutUI() {
            contentView.addSubviews([titleLabel, contentLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(40.auto())
                make.height.equalTo(14.auto())
            }
            
            contentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(40.auto())
                make.height.equalTo(17.auto())
            }
        }
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        lazy var contentLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
    }
}
                
