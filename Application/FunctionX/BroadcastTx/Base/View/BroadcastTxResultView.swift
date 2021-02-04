//
//  BroadcastTxSuccessfulView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension BroadcastTxAlertController {
    class ResultView: UIView {
        
        let containerView = UIView(COLOR.BACKGROUND)
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
        lazy var closeButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_close_white")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .right
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
            
            containerView.frame = CGRect(x: 8, y: 0, width: ScreenWidth - 8 * 2, height: ScreenHeight * 0.75)
            containerView.addCorner()
            addSubview(containerView)
            containerView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(ScreenHeight * 0.75)
            }
            
            containerView.addSubview(closeButton)
            closeButton.snp.makeConstraints { (make) in
                make.top.equalTo(8)
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 44, height: 44))
            }
            
            containerView.addSubview(listView)
            listView.snp.makeConstraints { (make) in
                make.top.equalTo(closeButton.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }
}



extension BroadcastTxAlertController {
    class ResultTitleCell: WKTableViewCell {
        
        lazy var resultIV: UIImageView = {
            
            let v = UIImageView()
            v.image = IMG("ic_success")
            return v
        }()
        
        lazy var resultLabel: UILabel = {
            let v = UILabel()
            v.text = TR("BroadcastTx.SubmitSuccess")
            v.font = XWallet.Font(ofSize: 20, weight: .medium)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat { return 136 }
        
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
            
            contentView.addSubviews([resultLabel, resultIV])
            
            resultIV.snp.makeConstraints { (make) in
                make.top.equalTo(4)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 78, height: 78))
            }
            
            resultLabel.snp.makeConstraints { (make) in
                make.top.equalTo(resultIV.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
            }
        }
    }
}

extension BroadcastTxAlertController {
    class ResultUSDCell: WKTableViewCell.TitleCell {
        
        var usdLabel: UILabel { titleLabel }
        
        override func initSubView() {
            super.initSubView()
            
            usdLabel.font = XWallet.Font(ofSize: 16)
            usdLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        }
        
        override class func height(model: Any?) -> CGFloat { return 19 }
    }
}
