//
//  FxDelegateView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/26.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxDelegateViewController {
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

//MARK: ValidatorCell
class FxValidatorTitleCell: FxTableViewCell {
    
    private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
    lazy var validatorIV = CoinImageView(size: CGSize(width: 48, height: 48).auto()).relayout(cornerRadius: 4.auto())
    lazy var validatorNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
    lazy var validatorAddressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
    lazy var statusButton = FxValidatorStatusButton(size: CGSize(width: 100, height: 18).auto())
    
    override class func height(model: Any?) -> CGFloat { 80.auto() }
    
    override func layoutUI() {

        contentView.addSubviews([bgView])
        bgView.addSubviews([validatorIV, validatorAddressLabel, validatorNameLabel, statusButton])
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
        }
        
        let edge: CGFloat = 16.auto()
        validatorIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(edge)
            make.size.equalTo(CGSize(width: 32, height: 32).auto())
        }
        
        validatorNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20.auto())
            make.left.equalTo(validatorIV.snp.right).offset(edge)
            make.height.equalTo(19.auto())
        }
        
        validatorAddressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(validatorNameLabel.snp.bottom).offset(4.auto())
            make.left.equalTo(validatorIV.snp.right).offset(edge)
            make.right.equalTo(-edge)
            make.height.equalTo(17.auto())
        }

        statusButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(validatorNameLabel)
            make.left.equalTo(validatorNameLabel.snp.right).offset(4.auto())
            make.height.equalTo(18.auto())
        }
    }
}

//MARK: InputCell
class FxDelegateTxInputCell: FxTableViewCell {
    
    enum Types {
        case delegate
        case undelegate
        case rewards
    }
    
    private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
    
    private lazy var titleBGView = UIView(COLOR.title)
    private lazy var titleLabel = UILabel(text: TR("FXDelegator.DelegationAmount"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white)
    
    private lazy var line = UIView(HDA(0xEBEEF0))
    
    private lazy var addressTitleLabel = UILabel(text: TR("FXDelegate.ExecutionAddress"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
    lazy var addressContainer = UIView(.white, cornerRadius: 16)
    lazy var tokenIV = CoinImageView(size: CGSize(width: 32, height: 32).auto())
    lazy var balanceLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
    lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
    lazy var addressPlaceHolderLabel = UILabel(text: TR("FXDelegate.SelectAddress"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 2, bgColor: .white)
    lazy var addressActionButton = UIButton(.clear)
    private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
    
    var inputTF: UITextField { inputVIew.interactor }
    lazy var inputTokenLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, alignment: .right)
    lazy var inputVIew: FxRoundTextField = {
        let v = FxRoundTextField(size: CGSize(width: ScreenWidth, height: 56.auto()))
        v.interactor.font = XWallet.Font(ofSize:16, weight: .medium)
        v.interactor.textColor = HDA(0x080A32)
        v.interactor.tintColor = HDA(0x0552DC)
        v.editBorderColors = (HDA(0x0552DC), .clear)
        v.borderWidth = 2
        v.interactor.keyboardType = .decimalPad
        v.backgroundColor = .white
        return v
    }()
    
    var percentButtons: [UIButton] = []
    private lazy var percentContainer: UIStackView = {
        
        let v = UIStackView(frame: .zero)
        v.axis = .horizontal
        v.spacing = 12.auto()
        v.alignment = .center
        v.distribution = .fillEqually
        return v
    }()
    lazy var p25Button = pButton("25%")
    lazy var p50Button = pButton("50%")
    lazy var p75Button = pButton("75%")
    lazy var maxButton = pButton(TR("SendToken.MAX"))
    private func pButton(_ title: String) -> UIButton {
        let v = UIButton()
        v.title = title
        v.titleFont = XWallet.Font(ofSize: 14)
        v.titleColor = COLOR.title
        v.selectedTitleColor = .white
        v.bgImage = UIImage.createImageWithColor(color: .white)
        v.selectedBGImage = UIImage.createImageWithColor(color: COLOR.title)
        v.height = 34.auto()
        v.cornerRadius = 16.auto()
        return v
    }

    var type = Types.delegate {
        didSet {
            if type == .undelegate { relayoutForUndelegate() }
            else if type == .rewards { relayoutForRewards() }
        }
    }
    
    var estimatedHeight: CGFloat {
        if type == .rewards { return 260.auto() }
        return inputVIew.isHidden ? 164.auto() : 309.auto()
    }
    
    override class func height(model: Any?) -> CGFloat { (model as? FxDelegateTxInputCell)?.estimatedHeight ?? 0 }
    
    override func configuration() {
        super.configuration()
        
        tokenIV.image = IMG("ic_token?")
        relayout(hasAddress: false)
    }
    
    func percentEnable(_ v: Bool) {
        percentButtons.forEach{ $0.isEnabled = v }
    }
    
    func relayout(hasAddress: Bool) {
        
        addressPlaceHolderLabel.isHidden = hasAddress
        line.isHidden = !hasAddress
        inputVIew.isHidden = !hasAddress
        percentContainer.isHidden = !hasAddress
    }
    
    func relayoutForUnchangeableAddress() {
        
        arrowIV.isHidden = true
        addressActionButton.isUserInteractionEnabled = false
        addressContainer.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    private func relayoutForUndelegate() {
        relayout(hasAddress: true)
        
        titleLabel.text = TR("FXDelegator.UnDelegateAmount")
        relayoutForUnchangeableAddress()
    }
    
    private func relayoutForRewards() {
        relayout(hasAddress: true)
        
        percentContainer.isHidden = true
        titleLabel.text = TR("FXDelegator.RewardsAmount")
        relayoutForUnchangeableAddress()
        
        inputVIew.isUserInteractionEnabled = false
        inputVIew.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        inputTF.textColor = COLOR.subtitle
    }
    
    override func layoutUI() {
        
        contentView.addSubview(bgView)
        bgView.addSubviews([titleBGView, titleLabel, addressTitleLabel, addressContainer, line])
        addressContainer.addSubviews([tokenIV, arrowIV, balanceLabel, addressLabel, addressPlaceHolderLabel, addressActionButton])
        
        bgView.addSubviews([inputVIew, percentContainer])
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
        }
        
        titleBGView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40.auto())
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.height.equalTo(titleBGView)
            make.left.equalTo(bgView).offset(16.auto())
        }
        
        //Address...b
        
        addressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleBGView.snp.bottom).offset(16.auto())
            make.left.right.equalTo(bgView).inset(16.auto())
            make.height.equalTo(14.auto())
        }
        
        addressContainer.snp.makeConstraints { (make) in
            make.top.equalTo(titleBGView.snp.bottom).offset(38.auto())
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
        
        balanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(tokenIV.snp.right).offset(8.auto())
            make.right.equalTo(arrowIV.snp.left).offset(-8.auto())
            make.height.equalTo(20)
        }
        
        addressLabel.snp.makeConstraints { (make) in
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
        
        //Address...e
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(titleBGView.snp.bottom).offset(116.auto())
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        percentButtons.appends(array: [p25Button, p50Button, p75Button, maxButton])
        percentContainer.addArrangedSubview(p25Button)
        percentContainer.addArrangedSubview(p50Button)
        percentContainer.addArrangedSubview(p75Button)
        percentContainer.addArrangedSubview(maxButton)
        percentButtons.forEach{ $0.snp.makeConstraints { (make) in
            make.height.equalTo(34.auto())
        } }
        
        let edge: CGFloat = 24.auto()
        
        //inputVIew...b
        inputVIew.addSubviews([inputTokenLabel])
        inputVIew.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(24.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(56.auto())
        }
        
        inputTokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16.auto())
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        inputVIew.interactor.snp.remakeConstraints { (make) in
            make.height.centerY.equalToSuperview()
            make.left.equalTo(24.auto())
            make.right.equalTo(inputTokenLabel.snp.left).offset(-8)
        }
        //inputVIew...e
        
        percentContainer.snp.makeConstraints { (make) in
            make.top.equalTo(inputVIew.snp.bottom).offset(16.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(34.auto())
        }
    }
}

//MARK: ConfirmTxCell
class FxDelegateConfirmTxCell: FxTableViewCell {
    
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
        v.selectedImage = IMG("ic_check")?.reRender(color: .white)
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
    
    func enable(_ v: Bool) {
        submitButton.isEnabled = v
    }
 
    override func layoutUI() {
        
        enable(false)
        
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
