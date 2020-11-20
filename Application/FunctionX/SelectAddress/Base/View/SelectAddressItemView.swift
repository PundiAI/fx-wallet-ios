//
//  SelectAddressItemView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit

extension SelectAddressViewController {
    class ItemView: UIView {
        lazy var containerView: UIView = {
            let v = UIView()
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            v.gradientBGLayer.size = CGSize(width: ScreenWidth - 8 * 2, height: 64)
            v.gradientBGLayer.isHidden = true
            v.backgroundColor = .clear // UIColor.white.withAlphaComponent(0.08)
            return v
        }()

        fileprivate lazy var spaceView = UIView(.clear)
        fileprivate lazy var lineView = UIView(HDA(0x373737))

        lazy var remarkLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = HDA(0x1A7CEB)
            v.backgroundColor = .clear
            v.layer.borderColor = HDA(0x1A7CEB).cgColor
            v.layer.borderWidth = 0.8
            v.layer.cornerRadius = 4
            v.layer.masksToBounds = true
            return v
        }()

        lazy var addressLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()

        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = TR("")
            v.font = XWallet.Font(ofSize: 18, weight: .bold)
            v.textColor = .white
            return v
        }()

        lazy var balanceLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        lazy var actionContainer = UIView(.clear)

        lazy var editButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Dapp.EditAddress")
            return v
        }()

        lazy var copyButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Dapp.CopyAddress")
            return v
        }()

        private var actionWidth: CGFloat { 60 }

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()

            configuration()
            layoutUI()
        }

        func configuration() {
            backgroundColor = .clear
            lineView.alpha = 0.4

            containerView.gradientBGLayer.size = CGSize(width: ScreenWidth - 8 * 2, height: 95)
            containerView.gradientBGLayer.isHidden = true

            actionContainer.isHidden = true
        }

        func layoutUI() {
            addSubview(containerView)
            containerView.addSubview(remarkLabel)
            containerView.addSubview(addressLabel)
            containerView.addSubview(nameLabel)
            containerView.addSubview(balanceLabel)

            addSubview(actionContainer)
            actionContainer.addSubviews([copyButton, editButton])

            addSubview(spaceView)
            addSubview(lineView)

            containerView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview().inset(8)
                make.right.equalTo(actionContainer.snp.left).offset(0)
                make.height.equalTo(94)
            }

            nameLabel.snp.makeConstraints { make in
                make.top.left.equalToSuperview().inset(10)
                make.right.equalTo(-103)
                make.height.equalTo(21)
            }

            remarkLabel.snp.makeConstraints { make in
                make.centerY.equalTo(nameLabel)
                make.right.equalTo(-10)
                make.height.equalTo(19)
                make.width.lessThanOrEqualTo(81)
            }

            balanceLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(5)
                make.left.equalTo(nameLabel)
                make.height.equalTo(19)
            }

            addressLabel.snp.makeConstraints { make in
                make.top.equalTo(balanceLabel.snp.bottom).offset(5)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(14)
            }

            actionContainer.snp.makeConstraints { make in
                make.top.equalTo(containerView)
                make.right.equalTo(actionWidth)
                make.width.equalTo(actionWidth)
                make.height.equalTo(containerView)
            }

            editButton.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5)
            }

            copyButton.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5)
            }

            spaceView.snp.makeConstraints { make in
                make.top.equalTo(containerView.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(4)
            }

            lineView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16)
                make.bottom.equalTo(-1)
                make.height.equalTo(1)
            }
        }

        func relayout(hideRemark: Bool) {
            remarkLabel.isHidden = hideRemark
        }

        func relayout(isSelected: Bool) {
            containerView.gradientBGLayer.isHidden = !isSelected
            remarkLabel.backgroundColor = isSelected ? .white : .clear
            remarkLabel.layer.borderWidth = isSelected ? 0 : 0.8

            actionContainer.snp.updateConstraints { make in
                make.top.equalTo(containerView)
                make.right.equalTo(isSelected ? 0 : actionWidth)
            }

            if isSelected { actionContainer.isHidden = false }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 4, initialSpringVelocity: 2, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                if !isSelected { self.actionContainer.isHidden = true }
            })
        }

        func relayoutForNoName() {
            nameLabel.isHidden = true

            balanceLabel.snp.remakeConstraints { make in
                make.edges.equalTo(nameLabel)
            }

            addressLabel.font = XWallet.Font(ofSize: 14)
            addressLabel.textColor = .white
            addressLabel.numberOfLines = 0
            addressLabel.snp.remakeConstraints { make in
                make.top.equalTo(49)
                make.left.right.equalToSuperview().inset(10)
            }
        }
    }
}
