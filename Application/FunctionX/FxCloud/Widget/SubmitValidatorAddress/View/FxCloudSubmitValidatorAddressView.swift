//
//  FxCloudSubmitValidatorAddressView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxCloudSubmitValidatorAddressViewController {
    
    class SelectValidatorAddressItemView: SelectItemView {
        
        override var image: UIImage? { IMG("Dapp.Wallet") }
        override var text: String { TR("CloudWidget.SubDelegatorAddr.SelectAddress") }
    }
}


extension FxCloudSubmitValidatorAddressViewController {
    
    class ValidatorAddressItemView: UIView {
        
        lazy var deleteButton: UIButton = {
            let v = UIButton()
            v.image = IMG("FC.Delete")
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var containerView: UIView = {
            
            let v = UIView()
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            return v
        }()
        
        fileprivate lazy var walletAddressTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.SubDelegatorAddr.WalletAddressT")
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.numberOfLines = 2
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var walletAddressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var copyWalletAddressButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Dapp.CopyAddress")
            return v
        }()
        
        fileprivate lazy var validatorAddressTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.SubDelegatorAddr.ValidatorAddressT")
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.numberOfLines = 2
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var validatorAddressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var copyValidatorAddressButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Dapp.CopyAddress")
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
            
            addSubviews([containerView, deleteButton])
            containerView.addSubviews([walletAddressTitleLabel, walletAddressLabel, copyWalletAddressButton, validatorAddressTitleLabel, validatorAddressLabel, copyValidatorAddressButton])
            
            containerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 18, bottom: 0, right: 18))
            }
            
            deleteButton.snp.makeConstraints { (make) in
                make.top.equalTo(containerView).offset(-10)
                make.left.equalTo(containerView).offset(-6)
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
            
            walletAddressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(21)
                make.left.equalTo(13)
                make.width.equalTo(85)
            }
            
            walletAddressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(21)
                make.left.equalTo(106)
                make.right.equalTo(-43)
            }
            
            copyWalletAddressButton.snp.makeConstraints { (make) in
                make.top.equalTo(21)
                make.right.equalTo(-10)
                make.size.equalTo(CGSize(width: 25, height: 25))
            }
            
            validatorAddressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(walletAddressLabel.snp.bottom).offset(16)
                make.left.equalTo(13)
                make.width.equalTo(85)
            }
            
            validatorAddressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(validatorAddressTitleLabel)
                make.left.equalTo(106)
                make.right.equalTo(-43)
            }
            
            copyValidatorAddressButton.snp.makeConstraints { (make) in
                make.top.equalTo(validatorAddressTitleLabel)
                make.right.equalTo(-10)
                make.size.equalTo(CGSize(width: 25, height: 25))
            }
        }
    }
}





extension FxCloudSubmitValidatorAddressCompletedViewController {
    
    class ValidatorAddressItemView: InfoItemView {
        
        var walletAddressLabel: UILabel { contentLabel }
        fileprivate var walletAddressTitleLabel: UILabel { titleLabel }
        
        fileprivate lazy var validatorAddressTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var validatorAddressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
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
            backgroundColor = .clear
            
            walletAddressTitleLabel.text = TR("CloudWidget.SubDelegatorAddr.WalletAddressT")
            validatorAddressTitleLabel.text = TR("CloudWidget.SubDelegatorAddr.ValidatorAddressT")
        }
        
        private func layoutUI() {
            
            containerView.addSubviews([validatorAddressTitleLabel, validatorAddressLabel])
            
            validatorAddressTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(walletAddressLabel.snp.bottom).offset(16)
                make.left.equalTo(15)
            }
            
            validatorAddressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(walletAddressLabel.snp.bottom).offset(16)
                make.left.equalTo(108)
                make.right.equalTo(-15)
            }
        }
    }
}

