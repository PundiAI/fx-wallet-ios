//
//  FxCloudSubmitValidatorKeypairItemView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxCloudSubmitValidatorKeypairViewController {
    
    class SelectKeypairItemView: SelectItemView {
        
        override var image: UIImage? { IMG("Dapp.Keypair") }
        override var text: String { TR("CloudWidget.SubValidatorKeypair.SelectKeys") }
    }
}




extension FxCloudSubmitValidatorKeypairViewController {
    
    class KeypairItemView: UIView {
        
        fileprivate lazy var publicKeyView = AddressItemView(frame: .zero)
        var deleteButton: UIButton { publicKeyView.deleteButton }
        var publicKeyLabel: UILabel { publicKeyView.addressLabel }
        
        fileprivate lazy var privateKeyView: UIView = {
           
            let v = UIView(UIColor.white.withAlphaComponent(0.08))
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            return v
        }()
        
        fileprivate lazy var privateKeyTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.text = TR("CloudWidget.PrivateKey")
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var privateKeyLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12)
            v.text = "***********************************************************"
            v.textColor = .white
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
            
            publicKeyView.relayout(hideRemark: true)
            publicKeyView.containerView.backgroundColor = HDA(0x464646)
        }
        
        private func layoutUI() {
            
            addSubviews([privateKeyView, publicKeyView])
            privateKeyView.addSubviews([privateKeyTitleLabel, privateKeyLabel])
            
            publicKeyView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(64 + 10)
            }
            
            privateKeyView.snp.makeConstraints { (make) in
                make.top.equalTo(publicKeyView.snp.bottom).offset(-10)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(10 + 48)
            }
            
            privateKeyTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(10 + 10)
                make.left.equalTo(10)
                make.height.equalTo(16)
            }
            
            privateKeyLabel.snp.makeConstraints { (make) in
                make.top.equalTo(privateKeyTitleLabel.snp.bottom)
                make.left.equalTo(10)
                make.height.equalTo(14)
            }
        }
    }
}








extension FxCloudSubmitValidatorKeypairCompletedViewController {
    
    class KeypairItemView: InfoItemView {
        
        var publicKeyLabel: UILabel { contentLabel }
        fileprivate var publicKeyTitleLabel: UILabel { titleLabel }
        
        fileprivate lazy var privateKeyTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var privateKeyLabel: UILabel = {
            let v = UILabel()
            v.text = "***********************************************************"
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
            
            publicKeyTitleLabel.text = TR("CloudWidget.PublicKey")
            privateKeyTitleLabel.text = TR("CloudWidget.PrivateKey")
        }
        
        private func layoutUI() {
            
            containerView.addSubviews([privateKeyTitleLabel, privateKeyLabel])
            
            privateKeyTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(publicKeyLabel.snp.bottom).offset(24)
                make.left.equalTo(15)
            }
            
            privateKeyLabel.snp.makeConstraints { (make) in
                make.top.equalTo(publicKeyLabel.snp.bottom).offset(24)
                make.left.equalTo(108)
                make.right.equalTo(-15)
            }
        }
    }
}
