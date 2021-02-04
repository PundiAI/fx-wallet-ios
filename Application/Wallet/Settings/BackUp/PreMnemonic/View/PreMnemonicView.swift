//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension PreMnemonicViewController {
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
        lazy var startButton = UIButton().doNormal(title: TR("Button.Start"))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            
            startButton.titleFont = XWallet.Font(ofSize: 18, weight: .bold)
            startButton.titleLabel?.autoFont =  true
            startButton.autoCornerRadius = 28
        }
        
        private func layoutUI() {
            addSubview(listView)
            addSubview(startButton)

            listView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(FullNavBarHeight + 8.auto())
                make.left.right.equalToSuperview()
                make.bottom.equalTo(startButton.snp.top).offset(-16.auto())
            }
            
            startButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    }
}
