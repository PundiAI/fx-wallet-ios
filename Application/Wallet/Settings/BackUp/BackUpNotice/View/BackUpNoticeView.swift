//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit


extension UILabel {
    static func title() -> UILabel {
        let v = UILabel(.clear)
        v.font = XWallet.Font(ofSize: 24, weight: .bold)
        v.autoFont = true
        v.textColor = COLOR.title
        return v
    }
    
    static func subtitle() -> UILabel {
        let v = UILabel(.clear)
        v.font = XWallet.Font(ofSize: 16)
        v.autoFont = true
        v.numberOfLines = 0
        v.textColor = COLOR.subtitle
        return v
    }
}

extension BackUpNoticeViewController {
    
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
        lazy var startButton = UIButton().doNormal(title: TR("Button.Start"))
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("BackUpNotice.Warnning"),
                            font: XWallet.Font(ofSize: 14),
                            textColor: COLOR.notic)
            v.numberOfLines = 2
            v.autoFont = true
            v.backgroundColor = .clear
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
            
            startButton.titleFont = XWallet.Font(ofSize: 18, weight: .bold)
            startButton.titleLabel?.autoFont =  true
            startButton.autoCornerRadius = 28
            
            TR("BackUpNotice.Warnning").lineSpacingLabel(titleLabel)
            titleLabel.autoFont = true 
        }
        
        private func layoutUI() {
            addSubview(listView)
            addSubview(startButton)
            addSubview(titleLabel)

            listView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(FullNavBarHeight + 8.auto())
                make.left.right.equalToSuperview()
                make.bottom.equalTo(startButton.snp.top).offset(-16.auto())
            }
            
            startButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(titleLabel.snp.top).offset(-8.auto())
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            
            let offset = 16.auto().ifull(-8.auto())
            
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-offset)
            }
        }
    }
}
        
