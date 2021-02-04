//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension BackUpNowViewController {
    class View: WelcomeCreateView {
        
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        
        lazy var backUpButton = UIButton().doNormal(title: TR("BackUpNow.Button.NowTitle"))
        
        lazy var notNowButton = UIButton().doNormal(title: TR("BackUpNow.Button.NotNowTitle"))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            
            titleLabel.text = TR("BackUpNow.Title")
            subtitleLabel.text = TR("BackUpNow.SubTitle")
            
            backUpButton.autoCornerRadius = 28
            backUpButton.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            backUpButton.titleLabel?.autoFont = true
            
            
            notNowButton.titleFont = XWallet.Font(ofSize: 16)
            notNowButton.titleLabel?.autoFont = true
            notNowButton.autoCornerRadius = 28
            
            notNowButton.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0xF0F3F5)), for: .normal)
            notNowButton.setTitleColor(.black, for: .normal)
        }
        
        private func layoutUI() {
            self.pannel.removeFromSuperview()
            
            addSubview(navBar)
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            addSubview(backUpButton)
            addSubview(notNowButton)
            
            backUpButton.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
                make.bottom.equalTo(notNowButton.snp.top).offset(-16.auto())
            }
            
            notNowButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    
    }
}
        
