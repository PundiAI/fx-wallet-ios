//
//  AuthorizeDappView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension AuthorizeDappAlertController {
    
    class DappInfoCell: WKTableViewCell {
        
        lazy var iconIV = CoinImageView(size: CGSize(width: 50, height: 50))
        
        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 24, weight: .medium)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var descLabel: UILabel = {
            let v = UILabel()
            v.text = TR("AuthorizeDapp.Desc")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.textAlignment = .center
            v.numberOfLines = 2
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat { return 180 }
        
        //MARK: Utils
        override public func initSubView() {
            
            layoutUI()
            configuration()
            
            logWhenDeinit()
        }
        
        private func configuration() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
        }
        
        private func layoutUI() {
            
            contentView.addSubviews([iconIV, nameLabel, descLabel])
            iconIV.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 50, height: 50))
            }
            
            nameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(iconIV.snp.bottom).offset(18)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(30)
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(24)
            }
        }
    }
    
}




extension AuthorizeDappAlertController {
    
    class AuthorityCell: FxTableViewCell {
        
        enum AuthorityType: Int {
            case wallet = 0
            case sign = 1
            case name = 2
            
            case ethWallet = 3
            
            case mnemonic = 4
            case generateKeypair = 5
            case useValidatorKeypair = 6
            
            var info: (text: String, img: String) {
                switch self {
                case .wallet: return (TR("AuthorizeDapp.AuthorityOfWallet"), "Dapp.Wallet")
                case .sign: return (TR("AuthorizeDapp.AuthorityOfSign"), "Dapp.Sign")
                case .name: return (TR("AuthorizeDapp.AuthorityOfName"), "Dapp.UserIcon")
                case .ethWallet: return (TR("AuthorizeDapp.AuthorityOfEthWallet"), "Dapp.Wallet")
                case .mnemonic: return (TR("AuthorizeDapp.AuthorityOfMnemonic"), "Dapp.Mnemonic")
                case .generateKeypair: return (TR("AuthorizeDapp.AuthorityOfGenerateKeypair"), "Dapp.Keypair")
                case .useValidatorKeypair: return (TR("AuthorizeDapp.AuthorityOfUseValidatorKeypair"), "Dapp.Keypair")
                }
            }
        }
        
        lazy var containerView = UIView(UIColor.white.withAlphaComponent(0.08), cornerRadius: 16)
        
        lazy var iconIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            return v
        }()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0xffffff)
            v.backgroundColor = .clear
            v.numberOfLines = 0
            return v
        }()
        //MARK: Getter end
        
        override class func height(model: Any?) -> CGFloat {
            let type = (model as? AuthorityType) ?? .wallet
            
            let textWidth = ScreenWidth - 24 * 2 - (80 + 40)
            let textHeight: CGFloat = max(20, type.info.text.height(ofWidth: textWidth, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium)]))
            let containerHeight = textHeight + 16 * 2
            return containerHeight + 10 * 2
        }
        
        var type: AuthorityType = .wallet
        override func bind(_ viewModel: Any?) {
            guard let type = viewModel as? AuthorityType else { return }
            self.type = type
            
            let info = type.info
            self.iconIV.image = IMG(info.img)
            self.titleLabel.text = info.text
        }
        
        //MARK: Utils
        override func layoutUI() {
            
            contentView.addSubview(containerView)
                
            containerView.addSubview(iconIV)
            containerView.addSubview(titleLabel)
            
            containerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24))
            }
        
            iconIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(iconIV.snp.right).offset(16)
                make.right.equalTo(-16)
            }
        }
    }
    
}

extension AuthorizeDappAlertController {
    
    class ActionCell: WKTableViewCell.DoubleActionCell {
        
        var denyButton: UIButton { leftActionButton }
        var allowButton: UIButton { rightActionButton }
        
        override func configuration() {
            super.configuration()
            denyButton.title = TR("Deny")
        }
    }
}
