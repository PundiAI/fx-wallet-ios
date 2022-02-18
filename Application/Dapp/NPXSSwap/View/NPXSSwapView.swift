

import WKKit

extension NPXSSwapViewController {
    class View: UIView {
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
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
            
            addSubviews([listView])
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
        }
    }
}

//MARK: ContentCell
extension NPXSSwapViewController {
    
    class TitleCell: FxTableViewCell {
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        private lazy var swapIV = UIImageView(image: IMG("NPXSSwap.Swap"))
        private lazy var titleLabel = UILabel(text: "\(Coin.FxSwapSymbol)/NPXS", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var descLabel = UILabel(text: TR("NPXSSwap.Submit.Desc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0, alignment: .center)
        
        override func layoutUI() {
            contentView.addSubviews([bgView, tokenIV, swapIV, titleLabel, descLabel])
            
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            swapIV.snp.makeConstraints { (make) in
                make.top.equalTo(42.auto())
                make.left.equalTo(tokenIV).offset(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(tokenIV.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(19.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4.auto())
                make.left.right.equalTo(bgView).inset(24.auto())
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            
            let descHeight = TR("NPXSSwap.Submit.Desc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            return 151.auto() + descHeight
        }
    }
}

//MARK: ContentCell
extension NPXSSwapViewController {
    
    class ContentCell: FxTableViewCell {
        
        enum State {
            case normal
            case selected
        }
        
        private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        private lazy var titleBGView = UIView(COLOR.title)
        private lazy var titleLabel = UILabel(text: TR("NPXSSwap.Submit.SwapAmount"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
        
        private lazy var descLabel = UILabel(text: TR("NPXSSwap.Submit.Tip"), font: XWallet.Font(ofSize: 12, weight: .medium), textColor: HDA(0xFA6237), lines: 0)
        
        lazy var addressContainer = UIView(.white, cornerRadius: 16)
        lazy var tokenIV = CoinImageView(size: CGSize(width: 32, height: 32).auto()).then{ $0.image = IMG("ic_token?") }
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        lazy var ethBalanceLabel = UILabel(text: "\(unknownAmount) ETH", font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        lazy var npxsBalanceLabel = UILabel(text: "\(unknownAmount) NPXS", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
        lazy var addressPlaceHolderLabel = UILabel(text: TR("FXDelegate.SelectAddress"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 2, bgColor: .white)
        lazy var addressActionButton = UIButton(.clear)
        
        private lazy var feeTitleLabel = UILabel(text: TR("CrossChain.F2E.FeeTitle"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        lazy var feeLabel = UILabel(text: "\(unknownAmount) ETH", font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        private lazy var feeErrorLabel = UILabel(text: TR("CrossChain.F2E.InsufficientFunds"), font: XWallet.Font(ofSize: 14, weight: .medium), textColor: HDA(0xFA6237))
        
        lazy var amountContainer = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
        private lazy var amountTitleLabel1 = UILabel(text: TR("NPXSSwap.Submit.AvailableToSwap"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        private lazy var amountTitleLabel2 = UILabel(text: TR("NPXSSwap.Submit.YouWillReceive"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        private lazy var amountArrowIV = UIImageView(image: IMG("NPXSSwap.SwapArrow"))
        lazy var npxsAmountLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        lazy var xsAmountLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var regularHeight: CGFloat = {
            let descHeight = TR("NPXSSwap.Submit.Tip").height(ofWidth: ScreenWidth - 40.auto() * 2, attributes: [.font: XWallet.Font(ofSize: 12, weight: .medium)])
            return 220.auto() + descHeight
        }()
        
        private lazy var amountHeight: CGFloat = (230 + 16).auto()
        
        private let titleBGHeight: CGFloat = 40.auto()
        var estimatedHeight: CGFloat {
            
            let topHeight = feeErrorLabel.isHidden ? regularHeight : regularHeight + 24.auto()
            return topHeight + (state == .selected ? amountHeight : 0)
        }
        
        override class func height(model: Any?) -> CGFloat { return (model as? ContentCell)?.estimatedHeight ?? 0 }
        
        var state = State.normal {
            didSet {
                guard state == .selected, amountContainer.isHidden else { return }
                
                titleLabel.text = TR("NPXSSwap.Submit.WalletAddress")
                addressPlaceHolderLabel.isHidden = true
                relayout(isFeeError: false)
                amountContainer.isHidden = false
                
                regularHeight += 21.auto()
                addressContainer.snp.updateConstraints { (make) in
                    make.height.equalTo(91.auto())
                }
            }
        }
        
        override func configuration() {
            super.configuration()
            
            feeErrorLabel.isHidden = true
            amountContainer.isHidden = true
        }
        
        override func layoutUI() {
            
            contentView.addSubviews([bgView, titleLabel])
            contentView.addSubviews([descLabel])
            bgView.addSubviews([titleBGView])
            
            contentView.addSubviews([addressContainer, feeTitleLabel, feeLabel, feeErrorLabel, amountContainer])
            addressContainer.addSubviews([tokenIV, arrowIV, npxsBalanceLabel, addressLabel, ethBalanceLabel, addressPlaceHolderLabel, addressActionButton])
            amountContainer.addSubviews([amountTitleLabel1, amountTitleLabel2, npxsAmountLabel, amountArrowIV, xsAmountLabel])
            
            bgView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
            }
            
            //title...b
            titleBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.height.equalTo(titleBGView)
                make.left.equalTo(bgView).offset(16.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(bgView).offset((titleBGHeight + 16.auto()))
                make.left.right.equalTo(bgView).inset(16.auto())
            }
            //title...e
            
            //address.b
            addressContainer.snp.makeConstraints { (make) in
                make.top.equalTo(descLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(70.auto())
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32).auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.right.equalTo(-8.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            npxsBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(20)
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(18)
            }
            
            ethBalanceLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(-16)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
                make.height.equalTo(18)
            }
            
            addressPlaceHolderLabel.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(10)
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
            }
            
            addressActionButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            feeTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressContainer.snp.bottom).offset(22.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(15.auto())
            }
            
            feeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(feeTitleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(18.auto())
            }
            
            feeErrorLabel.snp.makeConstraints { (make) in
                make.top.equalTo(feeLabel.snp.bottom).offset(4.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(18.auto())
            }
            //address.e
            
            //amount...b
            amountContainer.snp.makeConstraints { (make) in
                make.top.equalTo(feeLabel.snp.bottom).offset(24.auto())
                make.left.right.equalTo(bgView).inset(16.auto())
                make.height.equalTo(230.auto())
            }
            
            npxsAmountLabel.snp.makeConstraints { (make) in
                make.top.equalTo(32.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(20.auto())
            }
            
            amountTitleLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(npxsAmountLabel.snp.bottom).offset(8.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            amountArrowIV.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            xsAmountLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(amountTitleLabel2.snp.top).offset(-8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(20.auto())
            }
            
            amountTitleLabel2.snp.makeConstraints { (make) in
                make.bottom.equalTo(-32.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            //amount...e
        }
        
        func relayout(isFeeError: Bool) {
            feeErrorLabel.isHidden = !isFeeError
        }
    }
}
        
//MARK: ConfirmCell
extension NPXSSwapViewController {
    
    class ConfirmCell: FxTableViewCell {
        
        lazy var submitButton: UIButton = {
            let v = UIButton()
            v.title = TR("Next")
            v.bgImage = UIImage.createImageWithColor(color: COLOR.title)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.cornerRadius = 28.auto()
            
            v.disabledBGImage = UIImage.createImageWithColor(color: HDA(0xF7F9FA))
            v.disabledTitleColor = COLOR.title.withAlphaComponent(0.1)
            return v
        }()
        
        lazy var checkBox: UIButton = {
            let v = UIButton()
            v.image = nil
            v.bgImage = UIImage.createImageWithColor(color: .clear)
            v.selectedImage = IMG("ic_check_white")
            v.selectedBGImage = UIImage.createImageWithColor(color: HDA(0x0552DC))
            v.cornerRadius = 4
            v.borderWidth = 2
            v.borderColor = HDA(0x0552DC)
            v.isSelected = true
            return v
        }()
        
        lazy var tipButton = UIButton(.clear)
        lazy var tipLabel: UILabel = {
            let v = UILabel()
            v.numberOfLines = 0
            let text = TR("AgreeToTerms")
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 14), .foregroundColor: COLOR.subtitle])
            attText.addAttributes([.foregroundColor: HDA(0x0552DC)], range: text.nsRange(of: TR("Terms"))!)
            v.attributedText = attText
            v.sizeToFit()
            return v
        }()
        
        override func layoutUI() {
            
            contentView.addSubviews([submitButton, checkBox, tipLabel, tipButton])
            submitButton.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            if tipLabel.width <= ScreenWidth - 80.auto() {
                
                checkBox.snp.makeConstraints { (make) in
                    make.top.equalTo(submitButton.snp.bottom).offset(16.auto())
                    make.right.equalTo(tipLabel.snp.left).offset(-8.auto())
                    make.size.equalTo(CGSize(width: 20, height: 20).auto())
                }
                
                tipLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(checkBox)
                    make.centerX.equalToSuperview().offset(20.auto())
                }
            } else {
                
                checkBox.snp.makeConstraints { (make) in
                    make.top.equalTo(submitButton.snp.bottom).offset(16.auto())
                    make.left.equalTo(24.auto())
                    make.size.equalTo(CGSize(width: 20, height: 20).auto())
                }
                
                tipLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(submitButton.snp.bottom).offset(10.auto())
                    make.left.equalTo(checkBox.snp.right).offset(8.auto())
                    make.right.equalTo(24.auto())
                }
            }
            
            tipButton.snp.makeConstraints { (make) in
                make.left.equalTo(checkBox.snp.right).offset(24)
                make.top.right.height.equalTo(tipLabel)
            }
        }
        
        override public class func height(model:Any? = nil) -> CGFloat {
            
            let tipHeight = TR("AgreeToTerms").height(ofWidth: ScreenWidth - 24.auto() * 2, attributes: [.font: XWallet.Font(ofSize: 14)])
            return (56 + 20).auto() + tipHeight
        }
    }
}
