//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import Hero
import pop
import RxCocoa
import RxSwift
import WKKit

extension TokenListViewController {
    class View: UIView {
        lazy var messageArea = UIView(.white)

        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = "My Assets"
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            return v
        }()

        lazy var settingsButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Wallet.Settings")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .right
            return v
        }()

        lazy var settingsRedDot: UIView = {
            let v = UIView()
            v.backgroundColor = HDA(0xC91F1F)
            v.layer.cornerRadius = 3
            v.layer.masksToBounds = true
            return v
        }()

        lazy var bgroundView = UIView(UIColor.white)
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var listHeaderView = UIView()
        private lazy var listHeaderArcView: UIView = {
            let v = UIView(.clear)
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: 60)
            //            let maskLayer = CAShapeLayer()
            //            maskLayer.frame = bounds
            //            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight] , cornerRadii: CGSize(width: 40, height: 40)).cgPath
            //            v.frame = bounds
            //            v.layer.mask = maskLayer
            return v
        }()

        lazy var searchButton: UIButton = {
            let v = UIButton(size: CGSize(width: ScreenWidth - 40, height: 44))
            v.title = TR("TokenList.SearchPlaceholder")
            v.titleFont = XWallet.Font(ofSize: 16, weight: .bold)
            v.titleColor = UIColor.white.withAlphaComponent(0.32)
            v.borderColor = UIColor.white.withAlphaComponent(0.12)
            v.borderWidth = 1
            v.cornerRadius = 22
            v.backgroundColor = HDA(0x1D1D1D)
            v.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            v.contentHorizontalAlignment = .left
            return v
        }()

        fileprivate lazy var searchIV: UIImageView = {
            let v = UIImageView()
            v.image = IMG("ic_search")
            return v
        }()

        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = "$ --"
            v.font = XWallet.Font(ofSize: 24, weight: .bold)
            v.textColor = HDA(0xFFFFFF)
            v.backgroundColor = .clear
            return v
        }()

        lazy var nameLabel: UILabel = {
            let v = UILabel()
            v.text = "@username"
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x86879B)
            v.backgroundColor = .clear
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

        func set(amount: String) {
            let current = (amountLabel.text ?? "0").replacingOccurrences(of: "$ ", with: "").replacingOccurrences(of: ",", with: "").d.s
            let change = amount.sub(current).f
            let toValue = abs(change)
            guard toValue > 5 else {
                amountLabel.text = "$ \(amount.thousandth(2))"
                return
            }

            let tag = "xxx"
            let animation = POPBasicAnimation()
            animation.duration = toValue > 100 ? 1 : 0.5
            animation.toValue = toValue
            animation.fromValue = 0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.property = POPAnimatableProperty.property(withName: "") { p in
                guard let property = p else { return }

                property.threshold = 0.025
                property.writeBlock = { obj, values in
                    guard let label = obj as? UILabel, let values = values else { return }

                    var value = change >= 0 ? current.add(values[0].s) : current.sub(values[0].s)
                    if values[0] >= toValue - 0.1 {
                        value = amount
                        label.pop_removeAnimation(forKey: tag)
                    }
                    label.text = "$ \(value.thousandth(2))"
                }
            } as? POPAnimatableProperty
            amountLabel.pop_removeAnimation(forKey: tag)
            amountLabel.pop_add(animation, forKey: tag)
        }

        private func configuration() {
            backgroundColor = HDA(0x080A32)
            listView.backgroundColor = .clear

            searchIV.isHidden = true
            searchButton.isHidden = true
        }

        private func layoutUI() {
            bgroundView.clipsToBounds = true
            bgroundView.cornerRadius = 40
            bgroundView.clipsToBounds = true
            insertSubview(bgroundView, at: 0)

            addSubviews([messageArea, listView])

            listHeaderView.clipsToBounds = true
            listHeaderView.size = CGSize(width: ScreenWidth, height: FullNavBarHeight + 156)
            listView.tableHeaderView = listHeaderView
            listHeaderView.addSubviews([listHeaderArcView, titleLabel, settingsButton, settingsRedDot, searchButton, searchIV, amountLabel, nameLabel])

            messageArea.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(0)
            }

            // header...b
            let arcViewHeight: CGFloat = 60
            listHeaderArcView.snp.makeConstraints { make in
                make.bottom.equalTo(arcViewHeight - 30)
                make.left.right.equalToSuperview()
                make.height.equalTo(arcViewHeight)
            }

            titleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(settingsButton)
                make.left.equalTo(16)
            }

            settingsButton.snp.makeConstraints { make in
                make.top.equalTo(StatusBarHeight + 16)
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: NavBarHeight, height: NavBarHeight))
            }

            settingsRedDot.snp.makeConstraints { make in
                make.top.equalTo(settingsButton).offset(12)
                make.right.equalTo(settingsButton).offset(4)
                make.size.equalTo(CGSize(width: 6, height: 6))
            }

            searchButton.snp.makeConstraints { make in
                make.top.equalTo(32)
                make.left.right.equalToSuperview().inset(14)
                make.height.equalTo(44)
            }

            searchIV.snp.makeConstraints { make in
                make.centerY.equalTo(searchButton)
                make.right.equalTo(searchButton).offset(-14)
                //                make.size.equalTo(CGSize(width: 24, height: 24))
            }

            amountLabel.snp.makeConstraints { make in
                make.top.equalTo(settingsButton.snp.bottom).offset(25)
                make.left.equalToSuperview().inset(16)
            }

            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(amountLabel.snp.bottom).offset(8)
                make.left.equalToSuperview().inset(16)
            }
            // header...e

            listView.snp.makeConstraints { make in
                make.top.equalTo(messageArea.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            }

            let listHeaderHeight = listHeaderView.height
            let viewSize = bounds.size
            listView.rx.contentOffset.asObservable().subscribe(onNext: { [weak self] in
                let offsetY = listHeaderHeight - 20
                self?.bgroundView.frame = CGRect(x: 0, y: offsetY - $0.y,
                                                 width: viewSize.width, height: viewSize.height - offsetY + $0.y)
            }).disposed(by: defaultBag)

            bgroundView.hero.id = "token_list_background_0"
            bgroundView.cornerRadius = 40
            bgroundView.hero.modifiers = [.useGlobalCoordinateSpace,
                                          .useOptimizedSnapshot,
                                          .spring(stiffness: 250, damping: 25)]
        }
    }
}
