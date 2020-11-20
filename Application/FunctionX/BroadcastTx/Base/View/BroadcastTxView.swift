//
//  BroadcastTxView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension BroadcastTxAlertController {
    class View: UIView {
        let containerView: UIScrollView = {
            let v = UIScrollView(.clear)
            v.contentSize = CGSize(width: ScreenWidth * 4, height: 0)
            v.isScrollEnabled = false
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            return v
        }()

        let infoView = InfoView(frame: ScreenBounds)
        let pwdVerifyView = PwdVerifyView(frame: ScreenBounds.offsetBy(dx: ScreenWidth, dy: 0))
        let committingView = CommittingView(frame: ScreenBounds.offsetBy(dx: ScreenWidth * 2, dy: 0))
        let resultView = ResultView(frame: ScreenBounds.offsetBy(dx: ScreenWidth * 3, dy: 0))

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
        }

        private func layoutUI() {
            addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            containerView.addSubview(infoView)
            containerView.addSubview(pwdVerifyView)
            containerView.addSubview(committingView)
            containerView.addSubview(resultView)

            //            infoView.isHidden = true
            //            committingView.frame = ScreenBounds
        }
    }
}
