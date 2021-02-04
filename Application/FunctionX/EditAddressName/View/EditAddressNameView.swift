//
//  EditAddressNameView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension EditAddressNameAlertController {
    class View: UIView {
        
        lazy var backButton: UIButton = {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
            v.image = IMG("ic_back_white")
            v.title = TR("EditAddressName.Title")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.tintColor = .white
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .left
            v.titleEdgeInsets = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 0)
            return v
        }()
        
        lazy var confirmButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Wallet.Done")
            v.disabledImage = IMG("Wallet.Done_disable")
            v.titleFont = XWallet.Font(ofSize: 12)
            v.titleColor = HDA(0xFA6237)
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .right
            return v
        }()
        
        fileprivate lazy var inputTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Name")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var inputTFContainer = FxLineTextField(background: HDA(0x303030))
        var inputTF: UITextField { return inputTFContainer.interactor }
        
        fileprivate lazy var addressTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Address")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var addressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
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
            confirmButton.isEnabled = false
        }
        
        private func layoutUI() {
            
            self.addCorner()
            
            gradientBGLayerForTip.frame = self.bounds
            
            addSubview(backButton)
            addSubview(confirmButton)
            addSubview(inputTitleLabel)
            addSubview(inputTFContainer)
            addSubview(addressTitleLabel)
            addSubview(addressLabel)
            
            backButton.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(24)
                make.right.equalTo(-60)
                make.height.equalTo(44)
            }

            confirmButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(backButton)
                make.right.equalTo(-24)
                make.size.equalTo(CGSize(width: 44, height: 44))
            }
            
            inputTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(backButton.snp.bottom).offset(24)
                make.left.equalTo(24)
                make.height.equalTo(24)
            }

            inputTFContainer.snp.makeConstraints { (make) in
                make.top.equalTo(inputTitleLabel.snp.bottom).offset(4)
                make.left.right.equalToSuperview()
                make.height.equalTo(48)
            }
            
            addressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(24)
                make.left.equalTo(24)
                make.height.equalTo(24)
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressTitleLabel.snp.bottom).offset(18)
                make.left.right.equalToSuperview().inset(24)
            }
        }
    }
}

