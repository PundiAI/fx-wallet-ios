//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

class CryptoBankTxInputCell: FxTableViewCell {
    
    private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
    
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
//        v.editBackgroundColors = (.white, HDA(0xF7F7FA))
        v.borderWidth = 2
        v.interactor.keyboardType = .decimalPad
        v.backgroundColor = .white
        return v
    }()
    
    lazy var tokenIV = UIImageView()
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
    
    lazy var maximumLabel: UILabel = {
        let v = UILabel(text: TR("CryptoBank.Deposit.MAX$", "--"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        v.adjustsFontSizeToFitWidth = true
        return v
    }()
    
    override class func height(model: Any?) -> CGFloat { (8 + 262 + 32).auto() }
    
    func percentEnable(_ v: Bool) {
        percentButtons.forEach{ $0.isEnabled = v }
    }
    
    override func layoutUI() {
        
        contentView.addSubview(bgView)
        bgView.addSubviews([addressTitleLabel, addressLabel, line])
        bgView.addSubviews([inputVIew, percentContainer, maximumLabel])
        
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
        addressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(16.auto())
            make.left.equalTo(edge)
            make.height.equalTo(20.auto())
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(8.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(18.auto())
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(75.auto())
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //inputVIew...b
        inputVIew.addSubviews([tokenIV, tokenLabel])
        inputVIew.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(24.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(56.auto())
        }
        
        tokenIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16.auto())
            make.size.equalTo(CGSize(width: 24, height: 24).auto())
        }
        
        tokenLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16.auto())
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        inputVIew.interactor.snp.remakeConstraints { (make) in
            make.height.centerY.equalToSuperview()
            make.left.equalTo(48.auto())
            make.right.equalTo(tokenLabel.snp.left).offset(-8)
        }
        //inputVIew...e
        
        percentContainer.snp.makeConstraints { (make) in
            make.top.equalTo(inputVIew.snp.bottom).offset(16.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(34.auto())
        }
        
        maximumLabel.snp.makeConstraints { (make) in
            make.top.equalTo(percentContainer.snp.bottom).offset(16.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(18.auto())
        }
    }
}
        

class CryptoBankEnableTokenCell: FxTableViewCell {
    
    lazy var view = ApprovePanel(frame: .zero).then{ $0.mode = .multiStep }
    override func getView() -> UIView { view }

    override public class func height(model:Any? = nil) -> CGFloat { return 102.auto() }
}


class CryptoBankConfirmTxCell: FxTableViewCell {
    
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
//        self.isUserInteractionEnabled = v
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
