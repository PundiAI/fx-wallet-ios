//
//
//  XWallet
//
//  Created by May on 2020/12/17.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension SetPasswordViewController {
    class View: UIView {
        
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 40, weight: .medium),
                                      textColor: COLOR.title,
                                      bgColor: .clear).then {$0.autoFont = true}
        
        lazy var subtitleLabel = UILabel(font: XWallet.Font(ofSize: 16),
                                         textColor: COLOR.subtitle,
                                         lines: 0,
                                         bgColor: .clear).then {$0.autoFont = true}
        
        lazy var inputTFContainer = FxRoundTextField.standard
        var inputTF: UITextField { return inputTFContainer.interactor }
        
        lazy var doneButton = UIButton().doNormal(title: TR("Button.Next"))
        
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            inputTFContainer.backgroundColor = .white
            inputTFContainer.borderColor = COLOR.inputborder
            inputTFContainer.borderWidth = 2
            inputTFContainer.autoCornerRadius = 28
            
            inputTF.textColor = UIColor.black
            inputTF.font = XWallet.Font(ofSize: 16, weight: .bold)
            inputTF.autoFont = true
            inputTF.isSecureTextEntry = true
            inputTF.tintColor = COLOR.inputborder
            
            inputTF.attributedPlaceholder = NSAttributedString(string: TR("BroadcastTx.Security.Placeholder"), attributes: [.font : XWallet.Font(ofSize: 16),
                                                                                                                   .foregroundColor: COLOR.tip])
            doneButton.titleFont = XWallet.Font(ofSize: 18, weight: .bold)
            doneButton.titleLabel?.autoFont = true
            doneButton.autoCornerRadius = 28
            
            titleLabel.text = TR("Password") 
            subtitleLabel.text = TR("Security.Change.Setting.SubTitle")
        }
        
        private func layoutUI() {
            
            addSubview(navBar)
            
            addSubviews([titleLabel, subtitleLabel, inputTFContainer, doneButton])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + 8.auto() )
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(48.auto())
            
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10.auto())
                make.height.equalTo(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            inputTFContainer.snp.makeConstraints { (make) in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            doneButton.snp.makeConstraints { (make) in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    }
}
        
