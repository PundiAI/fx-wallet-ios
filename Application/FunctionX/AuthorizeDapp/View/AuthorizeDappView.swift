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
        lazy var closeButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_close_white")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .left
            return v
        }()

        lazy var iconIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            v.layer.cornerRadius = 25
            v.layer.masksToBounds = true
            return v
        }()

        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            return v
        }()

        lazy var descLabel: UILabel = {
            let v = UILabel()
            v.text = TR("AuthorizeDapp.Desc")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x1A7CEB)
            return v
        }()

        override class func height(model _: Any?) -> CGFloat { return 188 }

        // MARK: Utils

        override public func initSubView() {
            layoutUI()
            configuration()

            logWhenDeinit()
        }

        private func configuration() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        private func layoutUI() {
            contentView.addSubview(closeButton)
            contentView.addSubview(iconIV)
            contentView.addSubview(nameLabel)
            contentView.addSubview(descLabel)

            closeButton.snp.makeConstraints { make in
                make.top.equalTo(10)
                make.left.equalTo(20)
                make.size.equalTo(CGSize(width: 44, height: 44))
            }

            iconIV.snp.makeConstraints { make in
                make.top.equalTo(56)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 50, height: 50))
            }

            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(iconIV.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.height.equalTo(29)
            }

            descLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(20)
            }
        }
    }
}

extension AuthorizeDappAlertController {
    class AuthorityCell: WKTableViewCell {
        enum AuthorityType: Int {
            case wallet = 0
            case sign = 1
            case name = 2

            case ethWallet = 3

            case mnemonic = 4
            case generateKeypair = 5
            case useValidatorKeypair = 6
        }

        lazy var containerView: UIView = {
            let v = UIView(UIColor.white.withAlphaComponent(0.08))
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            return v
        }()

        fileprivate lazy var spaceView = UIView(.clear)

        lazy var iconIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            return v
        }()

        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            v.numberOfLines = 0
            return v
        }()

        // MARK: Getter end

        override class func height(model: Any?) -> CGFloat {
            let type = (model as? AuthorityType) ?? .wallet

            var textHeight: CGFloat = 44
            if type == .mnemonic {
                let text = TR("AuthorizeDapp.AuthorityOfMnemonic")
                textHeight = max(textHeight, text.height(ofWidth: ScreenWidth - 64 - 24, attributes: [.font: XWallet.Font(ofSize: 16)]) + 12 + 12)
            } else if type == .generateKeypair {
                let text = TR("AuthorizeDapp.AuthorityOfGenerateKeypair")
                textHeight = max(textHeight, text.height(ofWidth: ScreenWidth - 64 - 24, attributes: [.font: XWallet.Font(ofSize: 16)]) + 12 + 12)
            }
            return textHeight + 10
        }

        var type: AuthorityType = .wallet {
            didSet {
                switch type {
                case .wallet:
                    iconIV.image = IMG("Dapp.Wallet")
                    let text = TR("AuthorizeDapp.AuthorityOfWallet")
                    let attText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.white, .font: XWallet.Font(ofSize: 16)])
                    attText.addAttributes([.font: XWallet.Font(ofSize: 16, weight: .bold)], range: text.convert(range: text.range(of: TR("Function X"))!))
                    titleLabel.attributedText = attText

                case .sign:
                    iconIV.image = IMG("Dapp.Sign")
                    titleLabel.text = TR("AuthorizeDapp.AuthorityOfSign")

                case .name:
                    iconIV.image = IMG("Dapp.UserIcon")
                    titleLabel.text = TR("AuthorizeDapp.AuthorityOfName")

                case .ethWallet:
                    iconIV.image = IMG("Dapp.Wallet")
                    let text = TR("AuthorizeDapp.AuthorityOfEthWallet")
                    let attText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.white, .font: XWallet.Font(ofSize: 16)])
                    attText.addAttributes([.font: XWallet.Font(ofSize: 16, weight: .bold)], range: text.convert(range: text.range(of: TR("Ethereum"))!))
                    titleLabel.attributedText = attText

                case .mnemonic:
                    iconIV.image = IMG("Dapp.Mnemonic")
                    titleLabel.text = TR("AuthorizeDapp.AuthorityOfMnemonic")

                case .generateKeypair:
                    iconIV.image = IMG("Dapp.Keypair")
                    titleLabel.text = TR("AuthorizeDapp.AuthorityOfGenerateKeypair")

                case .useValidatorKeypair:
                    iconIV.image = IMG("Dapp.Keypair")
                    titleLabel.text = TR("AuthorizeDapp.AuthorityOfUseValidatorKeypair")
                }
            }
        }

        // MARK: Utils

        override public func initSubView() {
            layoutUI()
            configuration()

            logWhenDeinit()
        }

        private func configuration() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        private func layoutUI() {
            contentView.addSubview(containerView)

            containerView.addSubview(iconIV)
            containerView.addSubview(titleLabel)
            contentView.addSubview(spaceView)

            spaceView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(10)
            }

            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16))
            }

            iconIV.snp.makeConstraints { make in
                make.top.equalTo(12)
                make.left.equalTo(10)
                make.size.equalTo(CGSize(width: 20, height: 20))
            }

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(12)
                make.left.equalTo(iconIV.snp.right).offset(10)
                make.right.equalTo(-10)
                //                make.height.equalTo(20)
            }
        }
    }
}

extension AuthorizeDappAlertController {
    class ActionCell: WKTableViewCell {
        lazy var allowButton = UIButton().doGradient(title: TR("Allow"))

        lazy var denyButton: UIButton = {
            let v = UIButton()
            v.title = TR("Deny")
            v.titleFont = XWallet.Font(ofSize: 14, weight: .bold)
            v.titleColor = HDA(0xFA6237)
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            v.layer.cornerRadius = 22
            v.layer.masksToBounds = true
            return v
        }()

        override public class func height(model _: Any? = nil) -> CGFloat { return 38 + 44 + 57 }

        override public func initSubView() {
            layoutUI()
            configuration()

            logWhenDeinit()
        }

        private func configuration() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        public func layoutUI() {
            let buttonWidth = (ScreenWidth - 8 * 2) * 158 / 360

            contentView.addSubview(allowButton)
            contentView.addSubview(denyButton)
            allowButton.snp.makeConstraints { make in
                make.centerY.equalTo(denyButton)
                make.centerX.equalToSuperview().offset(buttonWidth * 0.5 + 7)
                make.size.equalTo(CGSize(width: buttonWidth, height: 88))
            }

            denyButton.snp.makeConstraints { make in
                make.top.equalTo(38)
                make.centerX.equalToSuperview().offset(-buttonWidth * 0.5 - 7)
                make.size.equalTo(CGSize(width: buttonWidth, height: 44))
            }
        }
    }
}
