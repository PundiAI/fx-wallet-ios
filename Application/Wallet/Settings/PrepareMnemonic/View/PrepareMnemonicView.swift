//
//  PrepareMnemonicView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/4.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import SnapKit
import UIKit
import WKKit

extension PrepareMnemonicViewController {
    class View: UIView {
        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Mnemonic.Prepare.Title")
            v.font = XWallet.Font(ofSize: 32, weight: .bold)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var noteLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Mnemonic.Prepare.Note")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()

        lazy var startButton = UIButton().doGradient(title: TR("Mnemonic.Prepare.Start"))

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()

            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = COLOR.BACKGROUND
        }

        private func layoutUI() {
            addSubview(titleLabel)
            addSubview(noteLabel)
            addSubview(startButton)

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(20 + FullNavBarHeight)
                make.left.right.equalToSuperview().inset(24)
            }

            noteLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(24)
            }

            startButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-88)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
        }
    }
}
