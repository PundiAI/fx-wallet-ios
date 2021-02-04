//
//  FxCloudWidgetActionCompletedView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxCloudWidgetActionViewController {
    class InfoTitleCell: WKTableViewCell.TitleCell {
        
        override func layoutUI() {
            super.layoutUI()
            
            titleLabel.font = XWallet.Font(ofSize: 16, weight: .bold)
            
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(40)
                make.left.equalTo(18)
                make.height.equalTo(20)
            }
        }
        
        override class func height(model: Any?) -> CGFloat { 40 + 20 + 10 }
    }
}

//MARK: InfoItemView
extension FxCloudWidgetActionCompletedViewController {
    
    class InfoItemView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var contentLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var containerView: UIView = {
            
            let v = UIView()
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
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
            
            addSubview(containerView)
            containerView.addSubviews([titleLabel, contentLabel])
            
            containerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(21)
                make.left.equalTo(15)
            }
            
            contentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(21)
                make.left.equalTo(108)
                make.right.equalTo(-15)
            }
        }
    }
}
