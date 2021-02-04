//
//
//  XWallet
//
//  Created by May on 2020/10/14.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension SwapConfirmViewController {
    
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var startButton = UIButton().doNormal(title: TR("Button.ConfirmSwap"))
        
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
            startButton.autoCornerRadius = 28
        }
        
        private func layoutUI() {
            addSubview(listView)
            addSubview(startButton)

           listView.snp.makeConstraints { (make) in
               make.top.equalToSuperview().offset(FullNavBarHeight)
               make.left.right.equalToSuperview()
               make.bottom.equalTo(startButton.snp.top).offset(-16.auto())
           }
           
           startButton.snp.makeConstraints { (make) in
               make.left.right.equalToSuperview().inset(24.auto())
               make.height.equalTo(56.auto())
               make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
           }
        }
    }
}
        



extension SwapConfirmViewController {
    
    class CoinView: UIView {
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 24, height: 24).auto())
        
        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            v.textAlignment = .right
            return v
        }()
        
        lazy var tokenLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
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
        }
        
        private func layoutUI() {
            addSubviews([tokenIV, amountLabel, tokenLabel])
            tokenIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
            }
            
            amountLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.height.equalTo(29.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
            }
            
            tokenLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.height.equalTo(19.auto())
                make.right.equalToSuperview()
            }
        }
    }
}




extension SwapConfirmViewController {
    
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
                make.top.equalToSuperview().offset(16.auto())
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




extension SwapConfirmViewController {
    class SwapTipView: UIView {
    
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
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
        }
        
        private func layoutUI() {
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview().offset(16.auto())
            }
        }
    }
}

