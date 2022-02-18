//
//
//  XWallet
//
//  Created by May on 2020/12/22.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import UIKit
import WKKit
import RxSwift
import RxCocoa
import AloeStackView

extension OxSwapViewController {
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
            view.height(constant: 8.auto())
            return view
        }()
        
        lazy var bottomSpaceView: UIView = {
            let view = UIView(frame:.zero)
            view.height(constant: (16 + 25 + 56).auto())
            return view
        }()
       
        
        lazy var inputFromView: CoinView = {
            let view = CoinView(frame: CGRect.zero)
            view.titleLabel.text = TR("Ox.NotFee.Title2")
            view.height(constant: 117.auto())
            return view
        }()
        
        lazy var inputChangeView: SwapChangeView = {
            let view = SwapChangeView(frame: CGRect.zero)
            view.height(constant: 56.auto())
            return view
        }()
        
        lazy var advancedSettings: AdvancedSettingsView = {
            let view = AdvancedSettingsView(frame: CGRect.zero)
            view.height(constant: (20 + 48).auto())
            return view
        }()
        
        
        lazy var inputToView: OutputCoinView = {
            let view = OutputCoinView(frame: CGRect.zero)
            view.titleLabel.text = TR("You.Receive")
            view.maxButton.isHidden = true
            view.maxButton.alpha = 0
            view.height(constant: 161.auto())
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
            inputToView.setLayout()
        }
        
        private func layoutUI() {
            addSubview(contentView)
            addSubview(actionView)
            contentView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(actionView.snp.bottom)
            }
            
            let offset:CGFloat = CGFloat((8.auto()).ifull(0.0))
            actionView.snp_makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo((56 + 32).auto())
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-offset)
            }
            
            contentView.addRows([topSpaceView, inputFromView,
                                 inputChangeView, inputToView, advancedSettings,bottomSpaceView])
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
        
extension OxSwapViewController {
    class CoinView: UIView , UITextFieldDelegate {
        lazy var contentView = UIView(HDA(0xF0F3F5))
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Ox.NotFee.Title2")
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
            v.adjustsFontSizeToFitWidth = true 
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
            textField.font = XWallet.Font(ofSize: 24, weight: .bold)
            textField.autoFont = true
            textField.returnKeyType = .done
            textField.tintColor = COLOR.inputborder
            textField.contentVerticalAlignment = .center
            textField.contentHorizontalAlignment = .left
            textField.textAlignment = .left
            textField.attributedPlaceholder = NSAttributedString(string: "0", attributes: [.font : XWallet.Font(ofSize: 24, weight: .bold),
                                                                                           .foregroundColor: COLOR.title.withAlphaComponent(0.2)])
            textField.keyboardType = .decimalPad
            textField.delegate = self
            textField.adjustsFontSizeToFitWidth = true
            return textField
        }()
        
        lazy var maxButton: UIButton = {
            let v = UIButton().doNormal(title: TR("SendToken.MAX"))
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
        
        var isReceived: Bool = false
        
        lazy var helpBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Help"), for: .normal)
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
            contentView.autoCornerRadius = 16
            arrowIV.image = IMG("Swap.Down")
            maxButton.isHidden = true
            chooseTokenButton.setTitle(TR("Uniswap.Select.Token"), for: .normal)
            indicatorView.isHidden = true
            helpBtn.isHidden = true
        }
        
        fileprivate func setLayout() {
            isReceived = true
            helpBtn.isHidden = true
            helpBtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16.auto(), height: 16.auto()))
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.left.equalTo(balanceLabel.snp.right).offset(8.auto())
                make.right.equalToSuperview().offset(-16.auto())
            }
            
            titleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.top.equalTo(24.auto())
                make.height.equalTo(24.auto())
            }
            
            balanceLabel.snp.remakeConstraints { (make) in
                make.right.equalTo(helpBtn.snp.left).offset(-8.auto())
                make.top.bottom.equalTo(titleLabel)
                make.left.equalTo(titleLabel.snp.right).offset(10)
            }
            
            selectCoinButton.snp.remakeConstraints { (make) in
                make.height.equalTo(44.auto())
                make.centerY.equalTo(inputTF)
                make.left.equalTo(chooseTokenButton.snp.left)
                make.right.equalTo(arrowIV.snp.right)
            }
        }
        
        fileprivate func layoutUI() {
            addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            
            contentView.addSubviews([titleLabel, balanceLabel, maxButton,
                                     tokenIV, tokenLabel, arrowIV, chooseTokenButton,selectCoinButton,
                                     inputContentView, inputTF, indicatorView, helpBtn])
            
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.top.equalTo(24.auto())
                make.height.equalTo(24.auto())
                make.right.equalTo(contentView.snp.centerX)
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16.auto())
                make.top.bottom.equalTo(titleLabel)
                make.left.equalTo(contentView.snp.centerX)
            }
            
            inputContentView.snp.makeConstraints { (make) in
                make.left.equalTo(10.auto())
                make.bottom.equalToSuperview().offset(-19.auto())
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
                make.centerY.equalTo(inputTF)
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
    
    class OutputCoinView: CoinView {
        lazy var usdPriceLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        override func layoutUI() {
            super.layoutUI()
            contentView.addSubview(usdPriceLabel) 
            usdPriceLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-16.auto())
                make.bottom.equalToSuperview().offset(-19.auto())
                make.height.equalTo(24.auto())
            }
            
            inputContentView.snp.remakeConstraints { (make) in
                make.left.equalTo(10.auto())
                make.bottom.equalToSuperview().offset(-58.auto())
                make.height.equalTo(39.auto())
                make.width.equalTo(contentView.snp.width).multipliedBy(0.4)
            } 
        }
    }
}


extension OxSwapViewController {
    class SwapChangeView: UIView {
        lazy var changeBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Confirm"), for: .normal)
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
    
    class AdvancedSettingsView: UIView {
        lazy var changeBtn: UIButton = {
            let button = UIButton()
            button.setTitleColor(COLOR.title, for: .normal)
            button.setTitle(TR("Ox.Advanced.Settings"), for: .normal)
            button.titleLabel?.font = XWallet.Font(ofSize: 16, weight: .medium)
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
                make.height.equalTo(20.auto())
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

extension OxSwapViewController {

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
//
//
//
//extension OxSwapViewController {
//    class ApprovePanel: UIView {
//        class ItemView: UIView {
//            lazy var buttonView = UIButton().doNormal(title: TR("-"))
//            lazy var indexView = UIButton().doNormal(title: "-").then { $0.isUserInteractionEnabled = false }
//            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//            override init(frame: CGRect) {
//                super.init(frame: frame)
//                logWhenDeinit()
//                addSubviews([buttonView, indexView])
//                buttonView.autoCornerRadius = 28
//                indexView.autoCornerRadius = 10
//
//                buttonView.snp.makeConstraints { (make) in
//                    make.top.right.left.equalToSuperview()
//                    make.height.equalTo(56.auto())
//                }
//
//                indexView.snp.makeConstraints { (make) in
//                    make.size.equalTo(CGSize(width: 20, height: 20).auto())
//                    make.centerX.equalToSuperview()
//                    make.top.equalTo(buttonView.snp.bottom).offset(8.auto())
//                }
//            }
//
//            func set(title:String, enable:Bool,  waiting:Bool = false) {
//                buttonView.title = title
//                buttonView.isEnabled = enable
//                indexView.isEnabled = enable
//            }
//        }
//
//        class ApproveItemView: ItemView {
//            lazy var indicatorView: UIActivityIndicatorView = {
//                let view = UIActivityIndicatorView(style:.gray)
//                view.hidesWhenStopped = true
//                return view
//            }()
//            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//            override init(frame: CGRect) {
//                super.init(frame: frame)
//                logWhenDeinit()
//                addSubview(indicatorView)
//                indicatorView.snp.makeConstraints { (make) in
//                    make.size.equalTo(CGSize(width: 25, height: 25))
//                    make.centerY.equalTo(buttonView)
//                    make.right.equalToSuperview().offset(-10)
//                }
//            }
//
//            override func set(title:String, enable:Bool, waiting:Bool = false) {
//                super.set(title: title, enable: enable, waiting:waiting)
//
//                waiting ? indicatorView.startAnimating() : indicatorView.stopAnimating()
//                buttonView.alpha = waiting ? 0.6 : 1.0
//            }
//        }
//
//        lazy var messageButton = ApproveItemView(frame:CGRect.zero).then {
//            $0.set(title: TR("----"), enable: false, waiting: false)
//            $0.indexView.title = TR("-")
//            $0.indexView.alpha = 0
//        }
//
//        lazy var approveButton = ApproveItemView(frame:CGRect.zero).then {
//            $0.set(title: TR("Button.Approve"), enable: true, waiting: false)
//            $0.indexView.title = TR("1")
//        }
//
//        lazy var swapButton = ItemView(frame:CGRect.zero).then {
//            $0.buttonView.title = TR("Ox.Button.Receive.Order")
//            $0.indexView.title = TR("2")
//        }
//
//        lazy var apporveTip: UILabel = {
//            let v = UILabel()
//            v.text = TR("Ox.Approve.Tip")
//            v.font = XWallet.Font(ofSize: 12)
//            v.autoFont = true
//            v.numberOfLines = 0
//            v.textColor = COLOR.subtitle
//            v.textAlignment = .center
//            return v
//        }()
//
//        lazy var line = UIView(.clear)
//        var isComplated:Bool = false
//
//        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            logWhenDeinit()
//            configuration()
//            layoutUI()
//        }
//
//        private func configuration() {
//            backgroundColor = .white
//        }
//
//        private func layoutUI() {
//            self.addSubviews([line, approveButton, swapButton, messageButton, apporveTip])
//
//            approveButton.snp.makeConstraints { (make) in
//                make.left.equalToSuperview().offset(24.auto())
//                make.right.equalTo(self.snp.centerX).offset(-8.auto())
//                make.centerY.equalToSuperview()
//            }
//
//            swapButton.snp.makeConstraints { (make) in
//                make.right.equalToSuperview().offset(-24.auto())
//                make.left.equalTo(self.snp.centerX).offset(8.auto())
//                make.centerY.equalToSuperview()
//            }
//
//            messageButton.snp.makeConstraints { (make) in
//                make.left.right.equalToSuperview().inset(24.auto())
//                make.height.equalTo((28 + 56).auto())
//                make.centerY.equalToSuperview()
//            }
//
//            apporveTip.snp.makeConstraints { (make) in
//                make.left.right.equalToSuperview()
//                make.top.equalTo(messageButton.snp.bottom).offset(8.auto())
//                make.height.equalTo(14.auto())
//            }
//        }
//
//        private func gradient(_ line: UIView) {
//            line.layer.sublayers?.each { (layer) in
//                layer.removeFromSuperlayer()
//            }
//
//            let fpoint = approveButton.convert(approveButton.indexView.center, to: self)
//            let tpoint = swapButton.convert(swapButton.indexView.center, to: self)
//            line.frame = CGRect(x: fpoint.x, y: fpoint.y, width: tpoint.x - fpoint.x, height: 1)
//            let gradientLine = CAGradientLayer()
//
//            let fromColor = isComplated ? COLOR.title : approveButton.indexView.backgroundImageColor
//            let toColor = swapButton.indexView.backgroundImageColor
//
//            gradientLine.frame = CGRect(x: 0, y: 0, width: line.width, height: 1)
//            gradientLine.startPoint = CGPoint(x: 0, y: 0.5)
//            gradientLine.endPoint = CGPoint(x: 1, y: 0.5)
//            gradientLine.colors = [fromColor.cgColor, toColor.cgColor]
//            line.layer.addSublayer(gradientLine)
//            line.isHidden = approveButton.indexView.isHidden
//        }
//
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            gradient(line)
//        }
//    }
//}


extension OxSwapViewController {
    
    typealias ApproveState = OxSwapViewController.OxSwapViewModel.ApproveState
    
    class ApprovePanel: UIView {
        class ItemView: UIView {
            lazy var buttonView = UIButton().doNormal(title: TR("-"))
            
            lazy var stepBtn: UIButton = {
                let button = UIButton()
                button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
                button.setTitleColor(UIColor.white, for: .normal)
                button.isUserInteractionEnabled = false
                return button
            }()
            
            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            override init(frame: CGRect) {
                super.init(frame: frame)
                logWhenDeinit()
                addSubviews([buttonView])
                buttonView.autoCornerRadius = 28
                
                buttonView.snp.makeConstraints { (make) in
                    make.top.right.left.equalToSuperview()
                    make.height.equalTo(56.auto())
                }
                
                buttonView.addSubview(stepBtn)
                
                stepBtn.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(14.auto())
                    make.top.equalTo(buttonView.titleLabel!.snp.bottom).offset(1)
                }
                buttonView.titleEdgeInsets = UIEdgeInsets(top: -12.auto(), left: 0, bottom: 0, right: 0)
                stepBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4.auto() )
            }
            
            func set(title:String, enable:Bool,  waiting:Bool = false) {
                buttonView.title = title
                buttonView.isEnabled = enable
            }
        }
        
        class ApproveItemView: ItemView {
            lazy var indicatorView: UIActivityIndicatorView = {
                let view = UIActivityIndicatorView(style:.white)
                view.hidesWhenStopped = true
                return view
            }()
            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            override init(frame: CGRect) {
                super.init(frame: frame)
                logWhenDeinit()
                addSubview(indicatorView)
                indicatorView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 20, height: 20))
                    make.centerY.equalTo(buttonView.titleLabel!.snp.centerY)
                    make.right.equalToSuperview().offset(-10)
                }
            }
            
            override func set(title:String, enable:Bool, waiting:Bool = false) {
                super.set(title: title, enable: enable, waiting:waiting)
                waiting ? indicatorView.startAnimating() : indicatorView.stopAnimating()
                buttonView.alpha = waiting ? 0.6 : 1.0
                if waiting {
                    buttonView.titleEdgeInsets = UIEdgeInsets(top: -12.auto(), left: -20, bottom: 0, right: 0)
                    print("\(buttonView.titleEdgeInsets)")
                } else {
                    buttonView.titleEdgeInsets = UIEdgeInsets(top: -12.auto(), left: 0, bottom: 0, right: 0)
                }
                
                buttonView.layoutIfNeeded()
            }
            
            func setAproveState(_ type: ApproveState, left: Bool) {
                switch type {
                case .normal:
                    if left {
                        set(title: TR("Button.Approve"), enable: true)
                        buttonView.isUserInteractionEnabled = true
                        stepBtn.setImage(nil, for: .normal)
                        stepBtn.setTitleColor(.white, for: .normal)
                    } else {
                        set(title: TR("Ox.Order.Title"), enable: false)
                        buttonView.isUserInteractionEnabled = true
                        stepBtn.setImage(nil, for: .normal)
                        stepBtn.setTitleColor(COLOR.title.withAlphaComponent(0.1), for: .normal)
                    }
                    break
                case .refresh:
                    if left {
                        set(title: TR("Swap.Button.Approving"), enable: true, waiting: true)
                        buttonView.isUserInteractionEnabled = false
                    } else {
                        set(title: TR("Ox.Order.Title"), enable: false, waiting: false)
                        stepBtn.setTitleColor(COLOR.title.withAlphaComponent(0.1), for: .normal)
                        buttonView.isUserInteractionEnabled = false
                    }
                    break
                case .completed:
                    if left {
                        set(title: TR("Button.Approved"), enable: false)
                        stepBtn.setTitleColor(COLOR.title.withAlphaComponent(0.1), for: .normal)
                        stepBtn.setImage(IMG("Swap.Approve.Ok"), for: .normal)
                    } else {
                        set(title: TR("Ox.Order.Title"), enable: true)
                        stepBtn.setTitleColor(.white, for: .normal)
                        stepBtn.setImage(nil, for: .normal)
                        buttonView.isUserInteractionEnabled = true
                    }
                    break
                case .disable:
                    if left {
                        set(title: TR("Button.Approve"), enable: false)
                        buttonView.isUserInteractionEnabled = true
                        stepBtn.setImage(nil, for: .normal)
                        stepBtn.setTitleColor(COLOR.title.withAlphaComponent(0.1), for: .normal)
                    } else {
                        set(title: TR("Ox.Order.Title"), enable: false)
                        buttonView.isUserInteractionEnabled = true
                        stepBtn.setImage(nil, for: .normal)
                        stepBtn.setTitleColor(COLOR.title.withAlphaComponent(0.1), for: .normal)
                    }
                default:
                    break
                }
            }
        }
        
        lazy var swapButton = ItemView(frame:CGRect.zero).then {
            $0.set(title: TR("Ox.Order.Title"), enable: false, waiting: false)
            $0.buttonView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        lazy var approveButton = ApproveItemView(frame:CGRect.zero).then {
            $0.set(title: TR("Button.Approve"), enable: true, waiting: false)
            $0.stepBtn.title = TR("Step 1")
        }
        
        lazy var swapStepButton = ApproveItemView(frame:CGRect.zero).then {
            $0.buttonView.title = TR("Ox.Order.Title")
            $0.stepBtn.title = TR("Step 2")
        }
        
        lazy var apporveTip: UILabel = {
            let v = UILabel()
            v.text = TR("Ox.Approve.Tip")
            v.font = XWallet.Font(ofSize: 12)
            v.autoFont = true
            v.numberOfLines = 3
            v.textColor = COLOR.subtitle
            v.textAlignment = .center
            return v
        }()
        
        var isComplated:Bool = false
        
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
            self.addSubviews([approveButton, swapStepButton, swapButton, apporveTip])
            
            approveButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(24.auto())
                make.right.equalTo(self.snp.centerX).offset(-8.auto())
                make.centerY.equalToSuperview()
            }
            
            swapStepButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.left.equalTo(self.snp.centerX).offset(8.auto())
                make.centerY.equalToSuperview()
            }
            
             
            swapButton.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
                make.centerY.equalToSuperview()
            }
            
            apporveTip.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(approveButton.snp.bottom).offset(8.auto())
                make.height.equalTo(28.auto())
            }
        }
        
        
        func setAproveState(_ type: ApproveState)  {
            approveButton.setAproveState(type, left: true)
            swapStepButton.setAproveState(type, left: false)
        }
        
        
        
        var isAprove: Bool = false {
            didSet {
                if isAprove {
                    approveButton.alpha = 1
                    apporveTip.alpha = 1
                    swapStepButton.alpha = 1
                    swapButton.isHidden = true
                    swapStepButton.isHidden = false
                    approveButton.snp.remakeConstraints { (make) in
                        make.left.equalToSuperview().offset(24.auto())
                        make.right.equalTo(self.snp.centerX).offset(-8.auto())
                        make.bottom.equalTo(apporveTip.snp.top).offset(-16.auto())
                        make.height.equalTo(56.auto())
                    }
                    swapStepButton.snp.remakeConstraints { (make) in
                        make.right.equalToSuperview().offset(-24.auto())
                        make.left.equalTo(self.snp.centerX).offset(8.auto())
                        make.bottom.equalTo(apporveTip.snp.top).offset(-16.auto())
                        make.height.equalTo(56.auto())
                    }
                    
                    apporveTip.snp.remakeConstraints { (make) in
                        make.left.right.equalToSuperview().inset(24.auto())
                        make.top.equalTo(approveButton.snp.bottom).offset(16.auto())
                        make.bottom.equalToSuperview()
//                        make.height.equalTo(30.auto())
                    }
                } else {
                    approveButton.alpha = 0
                    apporveTip.alpha = 0
                    swapStepButton.alpha = 0
                    swapButton.isHidden = false
                    swapButton.snp.remakeConstraints { (make) in
                        make.left.right.equalToSuperview().inset(24.auto())
                        make.height.equalTo(56.auto())
                        make.centerY.equalToSuperview()
                    }
                }
            }
        }
        
        
         func relayout(_ isAprove: Bool) {
            if isAprove {
                
                approveButton.alpha = 1
                apporveTip.alpha = 1
                swapStepButton.alpha = 1
                swapButton.isHidden = true
                
                approveButton.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(24.auto())
                    make.right.equalTo(self.snp.centerX).offset(-8.auto())
                    make.bottom.equalTo(apporveTip.snp.top).offset(-16.auto())
                    make.height.equalTo(56.auto())
                }
                
                swapStepButton.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview().offset(-24.auto())
                    make.left.equalTo(self.snp.centerX).offset(8.auto())
                    make.bottom.equalTo(apporveTip.snp.top).offset(-16.auto())
                    make.height.equalTo(56.auto())
                }
                
                apporveTip.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(24.auto())
                    make.top.equalTo(approveButton.snp.bottom).offset(16.auto())
                    make.bottom.equalToSuperview()
//                    make.height.equalTo(30.auto())
                }
            } else {
                
                approveButton.alpha = 0
                apporveTip.alpha = 0
                swapStepButton.alpha = 0
                swapButton.isHidden = false
                swapButton.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(24.auto())
                    make.height.equalTo(56.auto())
                    make.centerY.equalToSuperview()
                }
            }
        }
    }
}
