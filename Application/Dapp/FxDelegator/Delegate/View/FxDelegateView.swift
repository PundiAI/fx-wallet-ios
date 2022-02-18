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

//MARK: InputCell
class FxDelegateTxInputCell: FxTableViewCell {
    
    enum Types {
        case delegate
        case undelegate
    }
    
    private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
    
    private lazy var validatorContentView = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
    lazy var validatorIV = CoinImageView(size: CGSize(width: 48, height: 48).auto()).then {
        $0.relayout(cornerRadius: 4.auto())
        $0.layer.shadowRadius = 8
        $0.layer.shadowOpacity = 0.02
    }
    lazy var validatorNameLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
    lazy var validatorAddressLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle).then{ $0.lineBreakMode = .byTruncatingMiddle }
    lazy var statusButton = FxValidatorStatusButton(size: CGSize(width: 100, height: 18).auto())
    
    private lazy var line = UIView(HDA(0xEBEEF0))
    
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
    
    lazy var maximumTilteLabel = UILabel(text: TR("FxStaking.MaximumAvailable"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
    lazy var maximumLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)

    var type = Types.delegate {
        didSet {
            if type == .undelegate { relayoutForUndelegate() }
        }
    }
    
    var estimatedHeight: CGFloat { return 295.auto() }
    
    override class func height(model: Any?) -> CGFloat { (model as? FxDelegateTxInputCell)?.estimatedHeight ?? 0 }
    
    func percentEnable(_ v: Bool) {
        percentButtons.forEach{ $0.isEnabled = v }
    }
    
    func relayout(hasAddress: Bool) {
        
        line.isHidden = !hasAddress
        inputVIew.isHidden = !hasAddress
        percentContainer.isHidden = !hasAddress
    }
    
    private func relayoutForUndelegate() {
        maximumTilteLabel.text = TR("ValidatorOverview.Delegated")
    }
    
    override func layoutUI() {
        
        contentView.addSubview(bgView)
        
        bgView.addSubviews([validatorContentView, line, inputVIew, percentContainer, maximumTilteLabel, maximumLabel])
        validatorContentView.addSubviews([validatorIV, validatorAddressLabel, validatorNameLabel, statusButton])
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24).auto())
        }
        
        // validator...b
        validatorContentView.snp.makeConstraints { (make) in
            make.top.equalTo(16.auto())
            make.left.right.equalToSuperview().inset(16.auto())
            make.height.equalTo(70.auto())
        }
        
        let edge: CGFloat = 16.auto()
        validatorIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(edge)
            make.size.equalTo(CGSize(width: 32, height: 32).auto())
        }
        
        validatorNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(16.auto())
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
        // validator...e
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(94.auto())
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
        
        //inputVIew...b
        inputVIew.addSubviews([inputTokenLabel])
        inputVIew.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(24.auto())
            make.left.right.equalToSuperview().inset(24.auto())
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
            make.left.right.equalToSuperview().inset(24.auto())
            make.height.equalTo(34.auto())
        }
        
        maximumTilteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(percentContainer.snp.bottom).offset(16.auto())
            make.left.equalTo(32.auto())
            make.height.equalTo(14.auto())
        }
        
        maximumLabel.snp.makeConstraints { (make) in
            make.top.equalTo(maximumTilteLabel.snp.bottom).offset(8.auto())
            make.left.right.equalToSuperview().inset(32.auto())
            make.height.equalTo(17.auto())
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
