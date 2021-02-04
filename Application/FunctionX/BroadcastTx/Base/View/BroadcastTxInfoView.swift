//
//  BroadcastTxInfoView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/27.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

//MARK: InfoView
extension BroadcastTxAlertController {
    class InfoView: UIView {
        
        fileprivate let containerView = UIView(COLOR.BACKGROUND)
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("BroadcastTx.Payment")
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var closeButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_close_white")
            v.backgroundColor = .clear
            v.contentHorizontalAlignment = .right
            return v
        }()
        
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .clear
            listView.isScrollEnabled = false
        }

        private func layoutUI() {
            
            containerView.frame = CGRect(x: 8, y: 0, width: ScreenWidth - 8 * 2, height: 468)
            addSubview(containerView)
            containerView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(468)
            }
            
            containerView.addSubviews([titleLabel, closeButton, listView])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.left.equalTo(16)
                make.height.equalTo(34)
            }
            
            closeButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 44, height: 44))
            }
            
            listView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            }
        }
        
        func addCorner(_ listHeight: CGFloat) {
            
            let height = listHeight + 44
            containerView.frame = CGRect(x: 8, y: 0, width: ScreenWidth - 8 * 2, height: height)
            containerView.addCorner()
            containerView.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(8)
                make.height.equalTo(height)
            }
        }
    }
}

//MARK: AmountCell
extension BroadcastTxAlertController {
    
    class AmountCell: WKTableViewCell {
        
        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 32, weight: .medium)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var typeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.textAlignment = .center
            return v
        }()
        
        override func initSubView() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
            
            self.contentView.addSubview(typeLabel)
            self.contentView.addSubview(amountLabel)
            amountLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(38)
            }
            
            typeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(amountLabel.snp.bottom).offset(2)
                make.left.right.equalToSuperview()
                make.height.equalTo(19)
            }
        }
        
        override class func height(model: Any?) -> CGFloat { return 60 }
    }
}


//MARK: TokenCell
extension BroadcastTxAlertController {
    
    class TokenCell: WKTableViewCell {
        
        lazy var iconIV: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            v.layer.cornerRadius = 25
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.numberOfLines = 0
            return v
        }()
        
        override func initSubView() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
            
            self.contentView.addSubview(iconIV)
            self.contentView.addSubview(titleLabel)
            
            iconIV.snp.makeConstraints { (make) in
                make.top.equalTo(32)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 50, height: 50))
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(iconIV.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(4)
            }
        }
        
        override class func height(model: Any?) -> CGFloat { return 162 }
    }
}


//MARK: ContractItemView
extension BroadcastTxAlertController {
    class ContractItemView: UIView {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = "ETH " + TR("BroadcastTx.ContractTitle")
            v.font = XWallet.Font(ofSize: 18, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        private lazy var addressContainer: UIView = {
            let v = UIView()
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            v.layer.cornerRadius = 6
            v.layer.masksToBounds = true
            return v
        }()
        
        private lazy var contractTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("BroadcastTx.ContractAddress")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var contractLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = UIColor.white
            v.backgroundColor = .clear
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .clear
        }

        private func layoutUI() {
            
            addressContainer.addSubviews([contractTitleLabel, contractLabel])
            addSubviews([titleLabel, addressContainer])
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(2)
                make.left.equalTo(18)
                make.height.equalTo(21)
            }
            
            addressContainer.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(18)
                make.height.equalTo(52)
            }
            
            contractTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.equalTo(10)
                make.height.equalTo(16)
            }
            
            contractLabel.snp.makeConstraints { (make) in
                make.top.equalTo(contractTitleLabel.snp.bottom).offset(2)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(16)
            }
        }
    }
}


//MARK: FeeItemView
extension BroadcastTxAlertController {
    class FeeCell: WKTableViewCell {
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Fee")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.numberOfLines = 2
            return v
        }()
        
        lazy var feeLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white
            v.backgroundColor = .clear
            v.numberOfLines = 0
            return v
        }()
        
        lazy var sliderView: UISlider = {
            let v = UISlider()
            v.backgroundColor = .clear
            v.maximumTrackTintColor = .clear
            v.minimumTrackTintColor = .clear
            let layer = CAGradientLayer()
            layer.frame = CGRect(x: 0, y: 0, width: ScreenWidth - (8 + 18) * 2, height: 6)
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.colors = [HDA(0xECB592).cgColor, HDA(0xA6F0D4).cgColor]
            layer.cornerRadius = 3
            layer.masksToBounds = true
            v.layer.addSublayer(layer)
            return v
        }()
        
        lazy var gasLabel: UILabel = {
            let v = UILabel()
            v.text = ""
            v.font = XWallet.Font(ofSize: 16, weight: .medium)
            v.textColor = UIColor.white
            v.backgroundColor = .clear
            return v
        }()
        
        private lazy var slowerLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Slower")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        private lazy var fasterLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Faster")
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        override func initSubView() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
            layoutUI()
        }
        
        override class func height(model: Any?) -> CGFloat { return 100 }

        private func layoutUI() {
            
            addSubviews([titleLabel, feeLabel, sliderView, gasLabel, slowerLabel, fasterLabel])
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(2)
                make.left.equalTo(18)
                make.height.equalTo(16)
            }
            
            feeLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(100)
                make.right.equalTo(-18)
            }
            
            sliderView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(18)
                make.height.equalTo(8)
            }
            
            gasLabel.snp.makeConstraints { (make) in
                make.top.equalTo(sliderView.snp.bottom).offset(24)
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
            
            slowerLabel.snp.makeConstraints { (make) in
                make.top.equalTo(sliderView.snp.bottom).offset(24)
                make.left.equalTo(18)
                make.height.equalTo(20)
            }
            
            fasterLabel.snp.makeConstraints { (make) in
                make.top.equalTo(sliderView.snp.bottom).offset(24)
                make.right.equalTo(-18)
                make.height.equalTo(20)
            }
        }
    }
}
