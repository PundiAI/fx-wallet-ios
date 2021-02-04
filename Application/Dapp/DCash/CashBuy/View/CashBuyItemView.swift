//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

class CashBuyTxInputContentCell: UIView { 
    private lazy var bgView = UIView(HDA(0xF0F3F5), cornerRadius: 24)
    lazy var inputTitleLabel:UILabel = {
        let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
        v.text = TR("CryptoBank.Cash.Input.Title")
        return v
    }()
    
    var inputTF: UITextField { inputVIew.interactor }
    lazy var inputVIew: FxRoundTextField = {
        let v = FxRoundTextField(size: CGSize(width: ScreenWidth, height: 56.auto()))
        v.interactor.font = XWallet.Font(ofSize:16, weight: .medium)
        v.interactor.textColor = HDA(0x080A32)
        v.interactor.tintColor = HDA(0x0552DC)
        v.editBorderColors = (HDA(0x0552DC), .clear)
        v.borderWidth = 2
        v.interactor.keyboardType = .decimalPad
        v.backgroundColor = HDA(0xF7F7FA)
        return v
    }()
    
    lazy var tokenIV = UIImageView()
    lazy var tokenLabel = UILabel(text: "---", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, alignment: .right)
    
    lazy var addressButton = UIButton()
    lazy var addressTitleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
    lazy var addressLabel: UILabel = {
        let v = UILabel(font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32))
        v.lineBreakMode = .byTruncatingMiddle
        v.numberOfLines = 2
        return v
    }()
    
    lazy var addressArrowIV: UIImageView = {
        let v = UIImageView()
        v.image = IMG("ic_arrow_right")
        v.contentMode = .scaleAspectFit
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
        addSubview(bgView)
        bgView.addSubviews([inputTitleLabel])
        bgView.addSubviews([inputVIew, addressButton])
        addressButton.addSubviews([addressTitleLabel, addressLabel, addressArrowIV])
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 24, bottom: 32, right: 24).auto())
        }
        
        let edge: CGFloat = 24.auto()
        inputTitleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview().inset(edge)
            make.height.equalTo(20.auto())
        }
        
        inputVIew.addSubviews([tokenIV, tokenLabel])
        inputVIew.snp.makeConstraints { (make) in
            make.top.equalTo(inputTitleLabel.snp.bottom).offset(16.auto())
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
            make.width.equalTo(60)
        }
        
        inputVIew.interactor.snp.remakeConstraints { (make) in
            make.height.centerY.equalToSuperview()
            make.left.equalTo(48.auto())
            make.right.equalTo(tokenLabel.snp.left).offset(-8)
        }
        
        addressButton.snp.makeConstraints { (make) in
            make.top.equalTo(inputVIew.snp.bottom).offset(16.auto())
            make.left.right.equalToSuperview().inset(edge)
            make.bottom.equalToSuperview().inset(19.auto())
        }
        
        addressTitleLabel.snp.makeConstraints { (make) in
            make.bottom.lessThanOrEqualTo(addressButton.snp.centerY).offset(-4.auto())
            make.left.right.equalTo(addressLabel)
            make.height.equalTo(20.auto())
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(8.auto())
            make.left.equalToSuperview()
            make.right.equalTo(addressArrowIV.snp.left).offset(-16.auto())
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        addressArrowIV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(7.auto())
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24).auto())
        } 
    }
}


class CashBuyConfirmTxContentCell: UIView {
    lazy var submitButton: UIButton = {
        let v = UIButton().doNormal(title: TR("Next"))
        v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
        v.titleColor = .white
        v.cornerRadius = 28.auto()
        v.backgroundColor = COLOR.title
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
    
    lazy var poweredByLabel: UILabel = {
        let v = UILabel()
        v.textColor = HDA(0x080A32)
        v.alpha = 0.5
        v.font = XWallet.Font(ofSize: 12)
        v.text = TR("CryptoBank.Cash.Powered.By")
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
    lazy var checkBoxState = BehaviorRelay<Bool>(value: false)
    private func layoutUI() {
        
        addSubviews([submitButton, checkBox, tipLabel, tipButton, poweredByLabel])
        submitButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(24.auto())
            make.height.equalTo(56.auto())
        }
        
        if tipLabel.width <= ScreenWidth - 80.auto() {
            checkBox.snp.makeConstraints { (make) in
                make.top.equalTo(submitButton.snp.bottom).offset(15.auto())
                make.right.equalTo(tipLabel.snp.left).offset(-15.auto())
                make.size.equalTo(CGSize(width: 22, height: 22).auto())
            }
            
            tipLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(checkBox)
                make.centerX.equalToSuperview().offset(18.auto())
            }
        } else {
            
            checkBox.snp.makeConstraints { (make) in
                make.top.equalTo(submitButton.snp.bottom).offset(15.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 22, height: 22).auto())
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
        
        poweredByLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(tipButton.snp.bottom).offset(9.auto())
        }
    }
}
