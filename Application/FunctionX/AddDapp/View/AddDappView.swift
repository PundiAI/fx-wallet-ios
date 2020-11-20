//
//  AddDappsView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension AddDappViewController {
    class View: UIView {
        lazy var backButton: UIButton = {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
            v.image = IMG("ic_back_white")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .left
            return v
        }()

        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("AddDapps.Title")
            v.font = XWallet.Font(ofSize: 32, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()

        fileprivate lazy var subtitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("AddDapps.Subtitle")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.backgroundColor = .clear
            return v
        }()

        var inputTF: UITextField { return inputTFContainer.interactor }
        lazy var inputTFContainer: FxLineTextField = {
            let v = FxLineTextField(background: HDA(0x303030))
            v.interactor.returnKeyType = .go
            return v
        }()

        lazy var tipView: TipView = {
            let v = TipView(frame: ScreenBounds)
            v.textLabel.text = TR("AddDapps.Tip")
            v.textLabel.textColor = HDA(0xFA6237)
            v.dotView.backgroundColor = HDA(0xFA6237)
            return v
        }()

        lazy var refreshView: UIActivityIndicatorView = {
            let v = UIActivityIndicatorView(style: .white)
            return v
        }()

        lazy var dappContainer = UIView(.clear)

        lazy var dappIconIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            v.layer.cornerRadius = 25
            v.layer.masksToBounds = true
            return v
        }()

        lazy var dappNameLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            return v
        }()

        lazy var dappDescLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x999999)
            v.numberOfLines = 0
            v.textAlignment = .center
            return v
        }()

        lazy var addDAppButton = UIButton().doGradient(title: TR("Add_U"))

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()

            configuration()
            layoutUI()
        }

        private func configuration() {
            tipView.isHidden = true
            dappContainer.isHidden = true
        }

        private func layoutUI() {
            dappContainer.addSubviews([dappIconIV, dappNameLabel, dappDescLabel, addDAppButton])

            addSubview(backButton)
            addSubview(titleLabel)
            addSubview(subtitleLabel)
            addSubview(inputTFContainer)
            addSubview(tipView)
            addSubview(refreshView)
            addSubview(dappContainer)

            backButton.snp.makeConstraints { make in
                make.top.equalTo(StatusBarHeight)
                make.left.equalTo(18)
                make.size.equalTo(CGSize(width: 100, height: NavBarHeight))
            }

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(20 + FullNavBarHeight)
                make.left.right.equalToSuperview().inset(24)
            }

            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.equalTo(24)
            }

            inputTFContainer.snp.makeConstraints { make in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
                make.left.right.equalToSuperview()
                make.height.equalTo(48)
            }

            tipView.snp.makeConstraints { make in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(14)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(24)
            }

            refreshView.snp.makeConstraints { make in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(50)
                make.centerX.equalToSuperview()
            }

            dappContainer.snp.makeConstraints { make in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(50)
                make.left.right.bottom.equalToSuperview()
            }

            dappIconIV.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 50, height: 50))
            }

            dappNameLabel.snp.makeConstraints { make in
                make.top.equalTo(dappIconIV.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.height.equalTo(29)
            }

            dappDescLabel.snp.makeConstraints { make in
                make.top.equalTo(dappNameLabel.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(40)
            }

            addDAppButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-88)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
        }
    }
}
