//
//  BroadcastPwdInputView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

// extension BroadcastTxAlertController {
class PwdVerifyView: UIView {
    let containerView = UIView(COLOR.BACKGROUND)

    lazy var backButton: UIButton = {
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        v.image = IMG("ic_back_white")
        v.title = TR("BroadcastTx.SecurityVerify")
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

    fileprivate lazy var inputTFContainer: FxLineTextField = {
        let v = FxLineTextField(frame: ScreenBounds)
        v.autoHideKeyboard = false
        v.interactor.isSecureTextEntry = true
        v.interactor.attributedPlaceholder = NSAttributedString(string: TR("BroadcastTx.SecurityPlaceholder"),
                                                                attributes: [.font: XWallet.Font(ofSize: 18),
                                                                             .foregroundColor: UIColor.white.withAlphaComponent(0.2)])
        return v
    }()

    var inputTF: UITextField { return inputTFContainer.interactor }

    fileprivate let bioContainerView = UIView(COLOR.BACKGROUND)
    lazy var bioStartButton: UIButton = {
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        v.image = IMG(LocalAuthManager.shared.isAuthFace ? "Bio.FaceID" : "Bio.TouchID")
        v.backgroundColor = .clear
        v.contentHorizontalAlignment = .left
        return v
    }()

    fileprivate lazy var bioTipLabel: UILabel = {
        let v = UILabel()
        v.text = TR("Biometrics.VerifyTip")
        v.font = XWallet.Font(ofSize: 16)
        v.textColor = HDA(0x999999)
        v.backgroundColor = .clear
        return v
    }()

    lazy var verifyPwdButton: UIButton = {
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        let text = TR("Biometrics.VerifyPwd")
        let attText = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.white, .font: XWallet.Font(ofSize: 16), .underlineStyle: NSUnderlineStyle.single.rawValue])
        v.setAttributedTitle(attText, for: .normal)
        return v
    }()

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        logWhenDeinit()

        configuration()
        layoutUI()
    }

    private func configuration() {
        backgroundColor = .clear
        confirmButton.isHidden = true
        inputTFContainer.isHidden = true
    }

    private func layoutUI() {
        containerView.frame = CGRect(x: 8, y: 0, width: ScreenWidth - 8 * 2, height: 350)
        containerView.addCorner()
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(350)
        }

        containerView.addSubview(backButton)
        containerView.addSubview(confirmButton)
        containerView.addSubview(inputTFContainer)

        bioContainerView.addSubview(bioTipLabel)
        bioContainerView.addSubview(bioStartButton)
        bioContainerView.addSubview(verifyPwdButton)
        containerView.addSubview(bioContainerView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(24)
            make.right.equalTo(-60)
            make.height.equalTo(44)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.right.equalTo(-24)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }

        inputTFContainer.snp.makeConstraints { make in
            make.top.equalTo(73)
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
        }

        bioContainerView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        bioStartButton.snp.makeConstraints { make in
            make.top.equalTo(61)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 52, height: 52))
        }

        bioTipLabel.snp.makeConstraints { make in
            make.top.equalTo(bioStartButton.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }

        verifyPwdButton.snp.makeConstraints { make in
            make.bottom.equalTo(-58)
            make.right.equalTo(-29)
            make.height.equalTo(44)
        }
    }

    func relayoutForPwd() {
        if bioContainerView.isHidden { return }

        confirmButton.isHidden = false
        inputTFContainer.isHidden = false
        bioContainerView.isHidden = true

        containerView.height = 120
        containerView.addCorner()
        containerView.snp.remakeConstraints { make in
            make.bottom.equalTo(self.bottom).offset(-216)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(120)
        }
    }

    func relayoutForBio() {
        if inputTFContainer.isHidden { return }

        confirmButton.isHidden = true
        inputTFContainer.isHidden = true
        bioContainerView.isHidden = false

        containerView.height = 350
        containerView.addCorner()
        containerView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(350)
        }
    }
}

// }
