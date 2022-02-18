//
//  FxStakingItemView.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/8.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

class FxStakingTxInputCell: FxTableViewCell {
    
    enum Types {
        case regular
        case disableEdit
    }
    
    private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
    
    private lazy var addressBGView = UIView(UIColor.white.withAlphaComponent(0.5), cornerRadius: 16)
    lazy var tokenIV = UIImageView(.clear, cornerRadius: 16)
    lazy var addressTitleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
    lazy var addressLabel: UILabel = {
        let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        v.lineBreakMode = .byTruncatingMiddle
        return v
    }()
    
    private lazy var line = UIView(HDA(0xEBEEF0))
    
    var inputTF: UITextField { inputVIew.interactor }
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
    
    lazy var tokenLabel = UILabel(text: "---", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, alignment: .right)
    
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
    
    override class func height(model: Any?) -> CGFloat {
        let contentHeight = (model as? FxStakingTxInputCell)?.type == .disableEdit ? 199 : 295
        return (8 + contentHeight + 32).auto()
    }
    
    func percentEnable(_ v: Bool) {
        percentButtons.forEach{ $0.isEnabled = v }
    }
    
    var type = Types.regular {
        didSet {
            guard type == .disableEdit else { return }
            relayoutForDisableEdit()
        }
    }
    
    override func layoutUI() {
        
        contentView.addSubview(bgView)
        bgView.addSubview(addressBGView)
        addressBGView.addSubviews([tokenIV, addressTitleLabel, addressLabel])
        
        bgView.addSubviews([line, inputVIew, percentContainer, maximumTilteLabel, maximumLabel])
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 24, bottom: 32, right: 24).auto())
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
        addressBGView.snp.makeConstraints { (make) in
            make.top.equalTo(16.auto())
            make.left.right.equalToSuperview().inset(16.auto())
            make.height.equalTo(70.auto())
        }
        
        tokenIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16.auto())
            make.size.equalTo(CGSize(width: 32, height: 32).auto())
        }
        
        addressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15.auto())
            make.left.equalTo(56.auto())
            make.height.equalTo(19.auto())
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-15.auto())
            make.left.equalTo(56.auto())
            make.right.equalTo(-edge)
            make.height.equalTo(17.auto())
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(addressBGView.snp.bottom).offset(8.auto())
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //inputVIew...b
        inputVIew.addSubviews([tokenLabel])
        inputVIew.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(24.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(56.auto())
        }
        
        tokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16.auto())
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        inputVIew.interactor.snp.remakeConstraints { (make) in
            make.height.centerY.equalToSuperview()
            make.left.equalTo(16.auto())
            make.right.equalTo(tokenLabel.snp.left).offset(-8)
        }
        //inputVIew...e
        
        percentContainer.snp.makeConstraints { (make) in
            make.top.equalTo(inputVIew.snp.bottom).offset(16.auto())
            make.left.right.equalToSuperview().inset(edge)
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
    
    private func relayoutForDisableEdit() {
        
        percentContainer.isHidden = true
        
        inputVIew.isUserInteractionEnabled = false
        inputVIew.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        inputTF.textColor = COLOR.subtitle
    }
}

class FxStakingConfirmTxCell: FxTableViewCell {
    
    var submitButton: UIButton { actionView.submitButton }
    lazy var actionView = ApprovePanel(frame: .zero).then{
        $0.submitButton.title = TR("Next")
        $0.tipLabel.text = ""
    }
    
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
        actionView.set(submitEnabled: v)
//        self.isUserInteractionEnabled = v
    }
 
    override func layoutUI() {
        
        enable(false)
        
        contentView.addSubviews([actionView, checkBox, tipLabel, tipButton])
        actionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
//            make.left.right.equalToSuperview().inset(24.auto())
            make.left.right.equalToSuperview()
            make.height.equalTo(56.auto())
        }
        
        if tipLabel.width <= ScreenWidth - 80.auto() {
            
            checkBox.snp.makeConstraints { (make) in
                make.top.equalTo(actionView.snp.bottom).offset(16.auto())
                make.right.equalTo(tipLabel.snp.left).offset(-8.auto())
                make.size.equalTo(CGSize(width: 20, height: 20).auto())
            }
            
            tipLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(checkBox)
                make.centerX.equalToSuperview().offset(20.auto())
            }
        } else {
            
            checkBox.snp.makeConstraints { (make) in
                make.top.equalTo(actionView.snp.bottom).offset(16.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 20, height: 20).auto())
            }
            
            tipLabel.snp.makeConstraints { (make) in
                make.top.equalTo(actionView.snp.bottom).offset(10.auto())
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
