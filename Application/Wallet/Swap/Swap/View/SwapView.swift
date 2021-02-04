//
//
//  XWallet
//
//  Created by May on 2020/10/13.
//  Copyright © 2020 May All rights reserved.
//
import UIKit
import WKKit
import RxSwift
import AloeStackView

extension SwapViewController {
    class SwapStackView: AloeStackView {
        let touchBeganOberver = PublishSubject<()>()
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { 
            self.touchBeganOberver.onNext(())
        }
    }
    
    
    class View: UIView {
        public lazy var contentView: SwapStackView = {
            let view = SwapStackView()
            view.alwaysBounceVertical = true
            view.automaticallyHidesLastSeparator = false
            view.rowInset = UIEdgeInsets.zero
            view.showsVerticalScrollIndicator = false
            view.showsHorizontalScrollIndicator = false
            view.separatorHeight = 0
            return view
        }()
        
        lazy var approveNotice: ApproveNotcie =  {
            let v = ApproveNotcie(frame: CGRect(x: 24.auto(), y: StatusBarHeight + 4.auto(), width: ScreenWidth - 48.auto(), height: 130.auto()))
            return v
        }()
        
        lazy var topSpaceView: UIView = {
            let view = UIView(frame:.zero)
            view.height(constant: 24.auto())
            return view
        }()
        
        lazy var bottomSpaceView: UIView = {
            let view = UIView(frame:.zero)
            view.height(constant: (16 + 25 + 56).auto())
            return view
        }()
        
        lazy var pricePanelView: RateView = {
            let view = RateView(frame:.zero)
            view.height(constant: (144 + 8).auto())
            return view
        }()
        
        lazy var inputFromView: CoinView = {
            let view = CoinView(frame: CGRect.zero)
            view.titleLabel.text = TR("From")
            view.height(constant: 104.auto())
            return view
        }()
        
        lazy var inputChangeView: SwapChangeView = {
            let view = SwapChangeView(frame: CGRect.zero)
            view.height(constant: (56 + 10).auto())
            return view
        }()
        
        lazy var inputToView: CoinView = {
            let view = CoinView(frame: CGRect.zero)
            view.titleLabel.text = TR("To")
            view.maxButton.isHidden = true
            view.maxButton.alpha = 0
            view.height(constant: 104.auto())
            return view
        }()
        
        lazy var outputPriceView: PriceView = {
            let view = PriceView(frame: CGRect.zero)
            view.height(constant: 104.auto())
            return view
        }()
        
        lazy var outputInfoView: FeePannel = {
            let view = FeePannel(frame: CGRect.zero)
            view.height(constant: 132.auto())
            return view
        }()
        
        lazy var outputPairPathView: RounterView = {
            let view = RounterView(frame: CGRect.zero)
            view.height(constant: 100.auto())
            return view
        }()
        
        lazy var actionView: ApprovePanel = {
            let view = ApprovePanel(frame: CGRect.zero)
            return view
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
        }
        
        private func layoutUI() {
            addSubview(contentView)
            addSubview(actionView)
            contentView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(actionView.snp.bottom)
            }
            
            let offset:CGFloat = CGFloat((0.0).ifull(10.auto()))
            actionView.snp_makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(100.auto())
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(offset)
            }
            
            contentView.addRows([topSpaceView, pricePanelView, inputFromView,
                                 inputChangeView, inputToView,
                                 outputPriceView, outputInfoView, outputPairPathView, bottomSpaceView]) 
        }
        
        
        func showNotice(_ model: ApprovedModel) {
            approveNotice.model = model
            self.addView(approveNotice)
            approveNotice.titleLabel.text = TR("Swap.Approve.Notice.Title", model.token)
            approveNotice.wk.addBorder((1, .white))
            
            _ = WKTaskDelay(time: 5) { [weak self] in
                self?.close()
            }
        }
        
        func close() {
            approveNotice.removeFromSuperview()
        }
    }
}

extension SwapViewController {
    class CoinView: UIView , UITextFieldDelegate {
        lazy var contentView = UIView(HDA(0xF0F3F5))
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("From")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            return v
        }()
        
        lazy var balanceLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            return v
        }()
        
        lazy var indicatorView: UIActivityIndicatorView = {
            let view = UIActivityIndicatorView(style:.gray)
            view.hidesWhenStopped = true
            return view
        }()
        
        lazy var inputContentView = UIView(HDA(0xF0F3F5)).then {
            $0.autoCornerRadius = 16
            $0.borderColor = .clear
            $0.borderWidth = 2
        }
        
        lazy var inputTF: UITextField = {
            let textField = UITextField()
            textField.textColor = UIColor.black
            textField.font = XWallet.Font(ofSize: 16, weight: .bold)
            textField.autoFont = true
            textField.returnKeyType = .done
            textField.tintColor = COLOR.inputborder
            textField.contentVerticalAlignment = .center
            textField.contentHorizontalAlignment = .left
            textField.textAlignment = .left
            textField.placeholder = "0"
            textField.keyboardType = .decimalPad
            textField.delegate = self
            return textField
        }()
        
        lazy var maxButton: UIButton = {
            let v = UIButton().doNormal(title: TR("MAX"))
            v.sizeToFit()
            v.autoCornerRadius = 11
            v.titleFont = XWallet.Font(ofSize: 12)
            v.setTitleColor(COLOR.title, for: .normal)
            v.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0xDCE0E3)), for: .normal)
            return v
        }()
        
        lazy var chooseTokenButton: UIButton = {
            let v = UIButton()
            v.autoCornerRadius = 16
            v.titleFont = XWallet.Font(ofSize: 14, weight: .bold)
            v.setImage(IMG("Swap.Down.White"), for: .normal)
            v.titleLabel?.textColor = .white 
            v.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0x0552DC)), for: .normal)
            return v
        }()
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 24, height: 24).auto())
        lazy var arrowIV =  UIImageView()
        
        lazy var tokenLabel: UILabel = {
            let v = UILabel()
            v.text = TR("ETH")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()
        
        lazy var selectCoinButton: UIButton = {
            let v = UIButton()
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
            contentView.autoCornerRadius = 16
            arrowIV.image = IMG("Swap.Down")
            maxButton.isHidden = true
            chooseTokenButton.setTitle(TR("Uniswap.Select.Token"), for: .normal)
            indicatorView.isHidden = true
            
        }
        
        private func layoutUI() {
            addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            
            contentView.addSubviews([titleLabel, balanceLabel, maxButton,
                                     tokenIV, tokenLabel, arrowIV, chooseTokenButton,selectCoinButton,
                                     inputContentView, inputTF, indicatorView])
            
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.top.equalTo(16.auto())
                make.height.equalTo(17.auto())
                make.right.equalTo(contentView.snp.centerX)
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16.auto())
                make.top.bottom.equalTo(titleLabel)
                make.left.equalTo(contentView.snp.centerX)
            }
            
            inputContentView.snp.makeConstraints { (make) in
                make.left.equalTo(10.auto())
                make.bottom.equalToSuperview().offset(-10.auto())
                make.height.equalTo(39.auto())
                make.width.equalTo(contentView.snp.width).multipliedBy(0.4)
            }
            
            inputTF.snp.makeConstraints { (make) in
                make.edges.equalTo(inputContentView).inset(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8) )
            }
            
            indicatorView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 20, height: 20))
                make.centerY.equalTo(inputTF.snp.centerY)
                make.right.equalTo(inputTF.snp.right)
            }
            
            
            tokenLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(inputTF)
                make.height.equalTo(19.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-4.auto())
                make.left.lessThanOrEqualTo(tokenIV.snp.right)
                    .offset(8.auto())
                    .priority(.high)
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
                make.centerY.equalTo(inputTF)
                make.right.equalTo(tokenLabel.snp.left).offset(-8.auto())
            }
            
            let width = maxButton.width
            maxButton.snp.makeConstraints { (make) in
                make.width.equalTo(width)
                make.centerY.equalTo(inputTF)
                make.right.equalTo(tokenIV.snp.left).offset(-8.auto())
                make.height.equalTo(22.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
                make.centerY.equalTo(inputTF)
                make.right.equalToSuperview().offset(-16.auto())
            }
            
            chooseTokenButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16.auto())
                make.bottom.equalToSuperview().offset(-16.auto())
                make.height.equalTo(32.auto())
            }
            selectCoinButton.snp.makeConstraints { (make) in
                make.height.equalTo(44.auto())
                make.centerY.equalTo(inputTF)
                make.left.equalTo(tokenIV.snp.left)
                make.right.equalTo(arrowIV.snp.right)
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            chooseTokenButton.imagePosition(at: .right, space: 4)
            chooseTokenButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16.auto(), bottom: 0, right: 12.auto())
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let inverseSet = CharacterSet(charactersIn:"0123456789").inverted
            let components = string.components(separatedBy: inverseSet)
            let filtered = components.joined(separator: "")
            if range.length == 1 && string == "" {
                return true
            }
            
            if filtered == string {
                if var newTextString = textField.text {
                    newTextString = newTextString.appending(string)
                    let numberDecimal = NSDecimalNumber(string: newTextString)
                    if newTextString == numberDecimal.description {
                        return true
                    }else {
                        let dotsCount = newTextString.components(separatedBy:".").count 
                        return (range.length == 0 && string == "0") && dotsCount == 2
                    }
                }
                return true
            } else {
                if string == "." || string == "," {
                    let countDots = textField.text!.components(separatedBy:".").count - 1
                    let countCommas = textField.text!.components(separatedBy:",").count - 1
                    if countDots == 0 && countCommas == 0 {
                        return true
                    } else {
                        return false
                    }
                } else  {
                    return false
                }
            }
        }
    }
}


extension SwapViewController {
    class SwapChangeView: UIView {
        lazy var changeBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Switch"), for: .normal)
            return button
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            layoutUI()
        }
        
        private func layoutUI() {
            addSubview(changeBtn)
            changeBtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56.auto(), height: 56.auto()))
                make.center.equalToSuperview()
            }
        }
    }
    
    
    class CoinPannel: UIView {
        
        var  fromTokenView = CoinView(frame: .zero)
        
        var  toTokenView = CoinView(frame: .zero)
        
        lazy var changeBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Switch"), for: .normal)
            return button
        }()
        
        var fromBalance: UILabel { fromTokenView.balanceLabel }
        var fromMax: UIButton { fromTokenView.maxButton }
        var fromInputTF: UITextField { fromTokenView.inputTF }
        var fromToken: UILabel { fromTokenView.tokenLabel }
        var selectFromToken: UIButton { fromTokenView.selectCoinButton }
        
        var toBalance: UILabel { toTokenView.balanceLabel }
        var toInputTF: UITextField { toTokenView.inputTF }
        var toToken: UILabel { toTokenView.tokenLabel }
        var selectToToken: UIButton { toTokenView.selectCoinButton }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            toTokenView.maxButton.isHidden = true
            toTokenView.titleLabel.text = TR("To")
            fromTokenView.chooseTokenButton.isHidden = true
        }
        
        private func layoutUI() {
            
            addSubviews([fromTokenView, changeBtn, toTokenView])
            
            fromTokenView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(104.auto())
            }
            
            changeBtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 56.auto(), height: 56.auto()))
                make.centerX.equalToSuperview()
                make.top.equalTo(fromTokenView.snp.bottom)
            }
            
            toTokenView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(104.auto())
                make.top.equalTo(changeBtn.snp.bottom)
            }
        }
    }
}

extension SwapViewController {
    
    class FeeItemView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Maxmum sold")
            v.font = XWallet.Font(ofSize: 14)
            //            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            return v
        }()
        
        lazy var helpBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Help"), for: .normal)
            return button
        }()
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("---")
            v.font = XWallet.Font(ofSize: 14)
            //            v.autoFont = true
            v.textColor = COLOR.title
            v.textAlignment = .right
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
            titleLabel.sizeToFit()
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, helpBtn, subTitleLabel])
            titleLabel.snp.makeConstraints { (make) in
                make.top.bottom.left.equalToSuperview()
                make.right.lessThanOrEqualTo(helpBtn.snp.left)
                    .offset(-8.auto())
            }
            
            helpBtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16.auto(), height: 16.auto()))
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.left.equalTo(titleLabel.snp.right).offset(8.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.bottom.right.equalToSuperview()
                make.left.greaterThanOrEqualTo(helpBtn.snp.right)
                    .offset(8.auto())
                    .priority(.high)
            }
        }
    }
}

extension SwapViewController {
    
    class FeePannel: UIView {
        
        lazy var contentView = UIView(HDA(0xF0F3F5))
        
        var  maxSold = FeeItemView(frame: .zero)
        var  priceImpact = FeeItemView(frame: .zero)
        var  providerFee = FeeItemView(frame: .zero)
        
        var soldHelpBtn: UIButton { maxSold.helpBtn }
        var soldValue: UILabel { maxSold.subTitleLabel }
        
        var priceHelpBtn: UIButton { priceImpact.helpBtn }
        var priceValue: UILabel { priceImpact.subTitleLabel }
        
        var providerHelpBtn: UIButton { providerFee.helpBtn }
        var providerValue: UILabel { providerFee.subTitleLabel }
        
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
        }
        
        private func layoutUI() {
            
            addSubview(contentView)
            
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            
            contentView.addSubviews([maxSold, priceImpact, providerFee])
            
            maxSold.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(16.auto())
                make.top.equalToSuperview().offset(25.auto())
                make.height.equalTo(17.auto())
            }
            
            priceImpact.snp.makeConstraints { (make) in
                make.top.equalTo(maxSold.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(17.auto())
            }
            
            providerFee.snp.makeConstraints { (make) in
                make.top.equalTo(priceImpact.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(16.auto())
                make.height.equalTo(17.auto())
            }
        }
    }
}

extension SwapViewController {
    
    class PriceView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Price")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            return v
        }()
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        
        lazy var titleLabel1: UILabel = {
            let v = UILabel()
            v.text = TR("Uniswap.Price.Title")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            return v
        }()
        
        lazy var subTitleLabel1: UILabel = {
            let v = UILabel()
            v.text = "0.5%"
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            return v
        }()
        
        lazy var refeshBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Exchange"), for: .normal)
            return button
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
            //            titleLabel.sizeToFit()
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, subTitleLabel, refeshBtn, titleLabel1, subTitleLabel1])
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(40.auto())
                make.top.equalToSuperview().offset(20.auto())
                make.height.equalTo(17.auto()) 
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.height.equalTo(titleLabel.snp.height)
                make.right.equalTo(refeshBtn.snp.left).offset(-8.auto())
                make.left.equalTo(titleLabel.snp.right).offset(10.auto())
            }
            
            refeshBtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
                make.centerY.equalTo(titleLabel) 
                make.right.equalToSuperview().offset(-38.auto())
            }
            
            titleLabel1.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(40.auto())
                make.height.equalTo(24.auto())
                make.bottom.equalToSuperview().offset(-24.auto())
            }
            
            subTitleLabel1.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-38.auto())
                make.height.equalTo(24.auto())
                make.bottom.equalToSuperview().offset(-24.auto())
            }
        }
    }
}


extension SwapViewController {
    
    class ApproveNotcie: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Approve USDC")
            v.font = XWallet.Font(ofSize: 14, weight: .bold)
            v.autoFont = true
            v.textColor = .white
            v.textAlignment = .left
            return v
        }()
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.Approve.Notice.SubTitle")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.textAlignment = .left
            return v
        }()
        
        lazy var viewBtn: UIButton = {
            let button = UIButton()
            button.setBackgroundImage(UIImage.createImageWithColor(color: UIColor.white), for: .normal)
            button.setTitleColor(COLOR.title, for: .normal)
            button.title = TR("View")
            button.titleFont = XWallet.Font(ofSize: 14, weight: .bold)
            button.autoCornerRadius = 33/2
            return button
        }()
        
        lazy var closeBtn: UIButton = {
            let button = UIButton()
            button.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0x31324A)), for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.title = TR("Close")
            button.titleFont = XWallet.Font(ofSize: 14, weight: .bold)
            button.autoCornerRadius = 33/2
            return button
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        var model: ApprovedModel?
        
        private func configuration() {
            backgroundColor = COLOR.title
            self.autoCornerRadius = 36
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, subTitleLabel, viewBtn, closeBtn])
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(24.auto())
                make.bottom.equalTo(self.snp.centerY).offset(-2.auto())
                make.right.equalTo(viewBtn.snp.left).offset(-10.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(24.auto())
                make.top.equalTo(self.snp.centerY).offset(2.auto())
                make.right.equalTo(viewBtn.snp.left).offset(-10.auto())
            }
            
            viewBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(33.auto())
                make.width.equalTo(77.auto())
                make.bottom.equalTo(self.snp.centerY).offset(-8.auto())
            }
            
            closeBtn.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(33.auto())
                make.width.equalTo(77.auto())
                make.top.equalTo(self.snp.centerY).offset(8.auto())
            }
        }
    }
}
