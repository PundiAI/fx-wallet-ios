//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension SendTokenInputViewController {
    class View: UIView {
        lazy var titleView = CoinTitleView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 160, height: NavBarHeight)) 
        
        var titleLabel: UILabel { titleView.nameLabel }
        var tokenButton : CoinTypeView { titleView.tokenButton }
        
        lazy var backgoundContainer = UIView(.white)
        lazy var amountContainer = UIView(.white)
        
        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 48, weight: .medium)
            v.textColor = HDA(0x080A32)
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.numberOfLines = 2
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var exchangeAmountLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            v.autoFont = true
            return v
        }()
        
        lazy var maxButton: UIButton = {

            let v = UIButton()
            v.title = TR("MAX")
            v.titleFont = XWallet.Font(ofSize: 12, weight: .medium)
            v.titleColor = HDA(0x080A32)
            v.autoCornerRadius = 18
            v.backgroundColor = HDA(0xF4F4F4)
            v.titleLabel?.autoFont = true
            return v
        }()
        
        lazy var unitButton: UIButton = {

            let v = UIButton()
            v.image = IMG("SendToken.Switch")
            v.autoCornerRadius = 18
            v.backgroundColor = HDA(0xF4F4F4)
            v.titleLabel?.autoFont = true
            return v
        }()
        
        lazy var tokenContainer: UIView = {
            let v = UIView(HDA(0xF4F4F4))
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 110.auto())
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds,
                                          byRoundingCorners: [.bottomLeft, .bottomRight] ,
                                          cornerRadii: CGSize(width: 36, height: 36).auto()).cgPath
            v.frame = bounds
            v.layer.mask = maskLayer
            return v
        }()
        
        lazy var tokenArrowIV: UIImageView = {
            let v = UIImageView()
            v.image = IMG("ic_arrow_right")
            v.contentMode = .scaleAspectFit
            return v
        }()
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        
        lazy var switchAccountButton = UIButton(.clear)
        
        lazy var balanceLabel = UILabel(text: unknownAmount,
                                        font: XWallet.Font(ofSize: 16, weight: .medium), textColor: HDA(0x080A32))
            .then { $0.autoFont = true }
        
        lazy var addressLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5))
            v.lineBreakMode = .byTruncatingMiddle
            v.autoFont = true
            return v
        }()
        
        fileprivate lazy var remarkBackground: UIView = {
            let v = UIView(HDA(0x0552DC))
            v.autoCornerRadius = 11
            return v
        }()
        
        lazy var remarkLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.autoFont = true
            return v
        }()
        
        lazy var noticeContainer: UIView = {
            let v = UIView(HDA(0xFA6237))
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 110.auto())
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight] ,
                                          cornerRadii: CGSize(width: 36, height: 36).auto()).cgPath
            v.frame = bounds
            v.layer.mask = maskLayer
            return v
        }()
        
        lazy var noticeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16, weight: .medium)
            v.text = TR("SendToken.InsufficientBalance").uppercased()
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.autoFont = true
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
            backgroundColor = HDA(0x080A32)
        }
        
        private var hiding = false
        func hideNotice(_ v: Bool) {
            if hiding == v { return }
            self.hiding = v
            
            noticeContainer.snp.updateConstraints { (make) in
                make.bottom.equalTo(tokenContainer).offset(v ? 0 : 26)
            }
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .layoutSubviews, animations: {
                self.layoutIfNeeded()
            })
        }
        
        private func layoutUI() {
            addSubview(backgoundContainer)
            addSubviews([noticeContainer, amountContainer, tokenContainer])
            noticeContainer.addSubviews([noticeLabel])
            amountContainer.addSubviews([maxButton, unitButton, amountLabel, exchangeAmountLabel])
            tokenContainer.addSubviews([tokenIV, balanceLabel, addressLabel, remarkBackground, remarkLabel, tokenArrowIV, switchAccountButton])
             
            backgoundContainer.alpha = 0
            backgoundContainer.snp.makeConstraints { (make) in
                make.left.right.equalTo(amountContainer)
                make.top.equalToSuperview()
                make.bottom.equalTo(tokenContainer.snp.centerY)
            }
            
            //amountContainer...b
            amountContainer.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.height.equalTo(150.auto())
            }
             
            amountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(58.auto())
                make.width.equalTo(150)
            }
             
            exchangeAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountLabel.snp.bottom).offset(10.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(24.auto())
            }
            
            unitButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(amountLabel)
                make.left.equalTo(amountLabel.snp.right).offset(28)
                make.size.equalTo(CGSize(width: 36, height: 36).auto())
            }

            maxButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(amountLabel)
                make.right.equalTo(amountLabel.snp.left).offset(-28)
                make.size.equalTo(CGSize(width: 36, height: 36).auto())
            }
            
            //amountContainer...e
            
            //tokenContainer...b
            tokenContainer.snp.makeConstraints { (make) in
                make.top.equalTo(amountContainer.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(110.auto())
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }

            relayout(hideRemark: true)
            
            remarkLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(8)
                make.left.equalTo(addressLabel).offset(4)
                make.height.equalTo(22)
            }
            
            remarkBackground.snp.makeConstraints { (make) in
                make.edges.equalTo(remarkLabel).inset(UIEdgeInsets(top: 0, left: -8, bottom: 0, right: -8).auto())
                make.width.greaterThanOrEqualTo(50)
                make.width.lessThanOrEqualTo(100)
            }
            
            tokenArrowIV.snp.makeConstraints { (make) in
                make.right.equalTo(-24)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
            
            switchAccountButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            //tokenContainer...e
            
            //noticeContainer...b
            noticeContainer.snp.makeConstraints { (make) in
                make.bottom.equalTo(tokenContainer).offset(0)
                make.left.right.equalToSuperview()
                make.height.equalTo(tokenContainer)
            }
            
            noticeLabel.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(26)
            }
            //noticeContainer...e
        }
        
        private var bottomEdge: CGFloat { StatusBarHeight == 44 ? 34 : 0 }
        var calculatorSize: CGSize { CGSize(width: ScreenWidth, height: ScreenHeight - FullNavBarHeight - (150 + 110 + 30 + bottomEdge).auto()) }
        func add(calculator: UIView) {
            
            addSubview(calculator)
            calculator.snp.makeConstraints { (make) in
                make.size.equalTo(calculatorSize)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-bottomEdge)
            }
        }
    
        private let maxAmountWidth: CGFloat = ScreenWidth - 87.5 * 2
        func updateAmountWidth(_ text: String) {
            if text.count <= 5 {
                amountLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(150.auto())
                }
            } else {
                let box = text.boundingRect(with: CGSize(width: 999, height: 56), options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [.font: XWallet.Font(ofSize: 48, weight: .bold)], context: nil)
                let width = box.width + 2
                amountLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(min(width, maxAmountWidth))
                }
            }
        }
        
        func relayout(hideRemark: Bool) {
            remarkLabel.isHidden = hideRemark
            remarkBackground.isHidden = hideRemark
            if hideRemark {
                
                balanceLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview().offset(-(10 + 4).auto())
                    make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                    make.right.equalTo(tokenArrowIV.snp.left).offset(-8.auto())
                    make.height.equalTo(20.auto())
                }
                
                addressLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview().offset((10 + 4).auto())
                    make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                    make.right.equalTo(tokenArrowIV.snp.left).offset(-8.auto())
                    make.height.equalTo(20.auto())
                }
            } else {
                
                addressLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                    make.right.equalTo(tokenArrowIV.snp.left).offset(-8.auto())
                    make.height.equalTo(20.auto())
                }
                
                balanceLabel.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(addressLabel.snp.top).offset(-8.auto())
                    make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                    make.right.equalTo(tokenArrowIV.snp.left).offset(-8.auto())
                    make.height.equalTo(20.auto())
                }
            }
        }
    }
}
        
