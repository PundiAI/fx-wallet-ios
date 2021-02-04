//
//
//  XWallet
//
//  Created by May on 2020/12/24.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension OxSwapConfirmViewController {
    
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)

        lazy var startPanel: ActionPannel = {
            let v = ActionPannel(.white)
            v.size = CGSize(width: ScreenWidth, height: ActionPannel.contentHeight)
            return v
        }()
 
        lazy var lockPanel: ActionLockPannel = {
            let v = ActionLockPannel(.white)
            v.size = CGSize(width: ScreenWidth, height: ActionPannel.contentHeight)
            return v
        }()
        
        var islock: Bool = false {
            didSet {
                lockPanel.isHidden = !islock
            }
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            listView.backgroundColor = .clear
            islock = false
        }
        
        private func layoutUI() {
            addSubview(listView)
            addSubview(startPanel)
            addSubview(lockPanel)

           listView.snp.makeConstraints { (make) in
               make.top.equalToSuperview().offset(FullNavBarHeight)
               make.left.right.equalToSuperview()
               make.bottom.equalTo(startPanel.snp.top).offset(-16.auto())
           }
           
            let offset:CGFloat = CGFloat((16.auto()).ifull(6.auto()))
            startPanel.snp.makeConstraints { (make) in
                make.height.equalTo(ActionPannel.contentHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-offset)
           }
            
            lockPanel.snp.makeConstraints { (make) in
                make.height.equalTo(ActionLockPannel.contentHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-offset)
           }
        }
    }
}

extension OxSwapConfirmViewController {
    
    class TokenPanel: UIView {
        
        lazy var contentView = UIView(HDA(0xF0F3F5))
        
        lazy var fromToken = CoinView()
        lazy var arrowIV =  UIImageView()
        lazy var toToken = CoinView()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            contentView.autoCornerRadius = 16
            
            arrowIV.image = IMG("Swap.Confirm")
        }
        
        private func layoutUI() {
            
            addSubview(contentView)
            
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalToSuperview()
                make.top.equalTo(8.auto())
            }
            
            contentView.addSubviews([fromToken, toToken, arrowIV])
            
            fromToken.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(29.auto())
                make.top.equalToSuperview().offset(24.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
                make.top.equalTo(fromToken.snp.bottom).offset(24.auto())
                make.left.equalToSuperview().offset(16.auto())
            }
            
            toToken.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(29.auto())
                make.top.equalTo(arrowIV.snp.bottom).offset(24.auto())
            }
        }
    }
}


extension OxSwapConfirmViewController {
    
    class FeeContent: UIView {

        lazy var pannel: PanelView = PanelView(frame: ScreenBounds)
        
        var rateLabel: UILabel { pannel.rateItem.valueLabel}
        var estimatedLabel: UILabel { pannel.estimatedItem.valueLabel}
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            
        }
        
        private func layoutUI() {
            addSubview(pannel)
            
            pannel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview().offset(24.auto())
                make.bottom.equalToSuperview()
            }
        }
    }
}

