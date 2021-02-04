//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension ResetWalletViewController {
    class Content: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel.title()
            v.text = TR("")
            return v
        }()
        
        lazy var subtitleLabel: UILabel = {
            let v = UILabel.subtitle()
            v.text = TR("")
            return v
        }()
        
        lazy var subMarkTitleLabel: UILabel = {
            let v = UILabel(XWallet.Font(ofSize: 16, weight: .bold), COLOR.notic, .left)
            v.numberOfLines = 0
            v.text = TR("")
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
            backgroundColor = .clear
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, subtitleLabel, subMarkTitleLabel])
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview().offset(8.auto())
                make.height.equalTo(29.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
            }
            
            subMarkTitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(subtitleLabel.snp.bottom).offset(4.auto())
            }
        }
    }
}

extension ResetWalletViewController {
    class InputView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(XWallet.Font(ofSize: 16), COLOR.title, .left)
            v.autoFont = true
            v.text = TR("")
            v.numberOfLines = 0
            return v
        }()
        
        lazy var inputTFContainer = FxRoundTextField.standard
        var inputTF: UITextField { return inputTFContainer.interactor }
        
        lazy var doneButton = UIButton().doNormal(title: TR("Button.Reset"))
        
        var touchControl = UIButton(frame: .zero)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            
            inputTFContainer.backgroundColor = COLOR.title.withAlphaComponent(0.03)
            inputTFContainer.autoCornerRadius = 34
            inputTF.textColor = COLOR.title
            inputTF.font = XWallet.Font(ofSize: 18, weight: .bold)
            inputTF.autoFont = true
            inputTF.tintColor = HDA(0x0552DC)
            
            inputTF.attributedPlaceholder = NSAttributedString(string: TR("ResetWallet.Input.Placeholder"), attributes: [.font : XWallet.Font(ofSize: 18),
            .foregroundColor: COLOR.title.withAlphaComponent(0.2)])
            
            doneButton.titleFont = XWallet.Font(ofSize: 18, weight: .bold)
            doneButton.titleLabel?.autoFont = true
            doneButton.autoCornerRadius = 28
            doneButton.isEnabled = false
        }
        
        private func layoutUI() {
            addSubview(titleLabel)
            addSubview(touchControl)
            addSubview(inputTFContainer)
            addSubview(doneButton)
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            touchControl.snp.makeConstraints { (make) in
                make.edges.equalTo(titleLabel)
            }
            
            inputTFContainer.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(68.auto())
            }
            
            doneButton.snp.makeConstraints { (make) in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(24.auto())
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            inputTF.snp.remakeConstraints { (make) in
                make.centerY.height.equalToSuperview()
                make.left.equalTo(24.auto())
                make.right.equalTo(-24.auto())
            }
        }
    }
}

