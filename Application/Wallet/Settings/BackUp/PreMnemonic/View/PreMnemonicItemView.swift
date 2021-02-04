//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension PreMnemonicViewController {
    class ItemView: BackUpNoticeViewController.ItemView {
        
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
        

extension PreMnemonicViewController {
    
    class MnemonicTagView: UIView {
        
        lazy var tagList: VITagListView = {
            let v = VITagListView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 24.auto() * 2, height: ScreenHeight))
            v.minHeight = ImportWalletViewController.View.MIN_HEIHGT
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
            tagList.tagInputField.isHidden = true
            tagList.isUserInteractionEnabled = false
            tagList.autoCornerRadius = 16
            tagList.backgroundColor = COLOR.title.withAlphaComponent(0.03)
        }
        
        private func layoutUI() {
            addSubview(tagList)
            tagList.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
        }
    }
}
