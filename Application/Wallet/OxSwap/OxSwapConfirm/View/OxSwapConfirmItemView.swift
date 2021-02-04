//
//
//  XWallet
//
//  Created by May on 2020/12/25.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension OxSwapConfirmViewController {
    
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

extension OxSwapConfirmViewController {
    class ItemView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
            v.autoFont = true
            v.textAlignment = .left
            return v
        }()
        
        lazy var valueLabel: UILabel = {
            let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
            v.autoFont = true
            v.textAlignment = .right
            return v
        }()
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            logWhenDeinit()
            layoutUI()
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, valueLabel])
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16.auto())
                make.top.bottom.equalToSuperview()
            }
            
            valueLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16.auto())
                make.top.bottom.equalToSuperview()
                make.left.equalTo(titleLabel.snp.right).offset(20.auto())
            }
        }
    }
    
    class PanelView: UIView {
        static var contentHeight:CGFloat { (131 - 33).auto() }
        lazy var rateItem: ItemView = ItemView(frame: ScreenBounds)
        lazy var estimatedItem: ItemView = ItemView(frame: ScreenBounds)
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            logWhenDeinit()
            
            configuration()
            layoutUI()

        }
        
        private func configuration() {
            
            rateItem.titleLabel.text = TR("Ox.Order.Rate")
            estimatedItem.titleLabel.text = TR("Ox.Order.Fee")
            self.backgroundColor = HDA(0xF0F3F5)
            self.autoCornerRadius = 16
        }
        
        private func layoutUI() {
            addSubviews([rateItem, estimatedItem])
            
            rateItem.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(17.auto())
                make.bottom.equalTo(self.snp.centerY).offset(-8.auto())
            }
            
            estimatedItem.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(17.auto())
                make.top.equalTo(self.snp.centerY).offset(8.auto())
            }
        }
    }
}
        
extension OxSwapConfirmViewController {
    
    class ActionPannel: UIView {
        
        static let contentHeight: CGFloat = 97.auto()
        
        lazy var startButton = UIButton().doNormal(title: TR("Ox.Order.Button"))
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR(""), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
            v.autoFont = true
            v.textAlignment = .center
            return v
        }()
        
        var timerOut: Bool = false {
            didSet {
                if timerOut {
                    titleLabel.textColor = HDA(0xFA6237)
                    titleLabel.text = TR("Ox.Order.TimerOut")
                    startButton.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0xF0F3F5)), for: .normal)
                    startButton.titleColor = COLOR.title
                    startButton.borderWidth = 2
                    startButton.borderColor = COLOR.title
                    startButton.title = TR("Ox.Order.Refresh")
                    startButton.setImage(IMG("Swap.Refresh"), for: .normal)
                    startButton.imagePosition(at: .right, space: 10)
                } else {
                    startButton.setBackgroundImage(UIImage.createImageWithColor(color: COLOR.title), for: .normal)
                    startButton.titleColor = .white
                    startButton.borderWidth = 0
                    titleLabel.textColor = COLOR.title
                    startButton.title = TR("Ox.Order.Button")
                    startButton.setImage(nil, for: .normal)
                    startButton.imagePosition(at: .left, space: 0)
                    
                }
            }
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            startButton.autoCornerRadius = 28
            timerOut = false
        }
        
        private func layoutUI() {
            addSubviews([startButton, titleLabel])
            startButton.snp.makeConstraints { (make) in
                make.height.equalTo(56.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(self.snp.top).offset(16.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.height.equalTo(17.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(startButton.snp.bottom).offset(8.auto())
            }
        }
    }
}


extension OxSwapConfirmViewController {
    
    class ActionLockPannel: UIView {
        
        static let contentHeight: CGFloat = (56 + 16 + 8 ).auto() + vheight
        
        static var vheight: CGFloat  {
            let v = TR("0x.Lock.SubTitle").size(with: CGSize(width: ScreenWidth - (24 * 2).auto() , height: CGFloat(MAXFLOAT)), font: XWallet.Font(ofSize: 14))
            return v.height
        }
        
        lazy var startButton = UIButton().doNormal(title: TR("0x.Lock.Title"))
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(text: TR("0x.Lock.SubTitle"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
            v.autoFont = true
            v.textAlignment = .center
            v.numberOfLines = 0
            return v
        }()
       
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            startButton.autoCornerRadius = 28
            startButton.isUserInteractionEnabled = false
            startButton.alpha = 0.6
            startButton.title = TR("0x.Lock.Title")
            titleLabel.text = TR("0x.Lock.SubTitle")
        }
        private func layoutUI() {
            addSubviews([startButton, titleLabel])
            startButton.snp.makeConstraints { (make) in
                make.height.equalTo(56.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(self.snp.top).offset(16.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(startButton.snp.bottom).offset(8.auto())
            }
        }
    }
}
