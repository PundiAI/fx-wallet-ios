//
//  FxCloudWidgetView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/19.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension FxCloudWidgetActionViewController {
    
    class View: UIView {
        
        lazy var confirmButton = UIButton().doGradient()
        
        lazy var listView = UITableView(frame: ScreenBounds, style: .plain)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = HDA(0x020B10)
            listView.backgroundColor = .clear
        }

        private func layoutUI() {
            
            addSubviews([listView, confirmButton])
            
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: FullNavBarHeight, left: 0, bottom: 0, right: 0))
            }
            
            confirmButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(-42)
                make.centerX.equalToSuperview()
                make.size.equalTo(UIButton.gradientSize())
            }
        }
    }
}




extension FxCloudWidgetActionViewController {
    class BlockchainInfoCell: WKTableViewCell {
        
        fileprivate lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.BlockchainInfo")
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var containerView: UIView = {
            
            let r = CGRect(x: 0, y: 0, width: ScreenWidth - 18 * 2, height: 75)
            let v = UIView(frame: r)
            v.layer.cornerRadius = 16
            v.layer.masksToBounds = true
            v.gradientBGLayer.frame = r
            v.gradientBGLayer.isHidden = false
            return v
        }()
        
        fileprivate lazy var haloIV: UIImageView = {
            
            let v = UIImageView()
            v.image = IMG("FC.Halo")
            v.clipsToBounds = true
            v.contentMode = .scaleAspectFill
            return v
        }()
        
        lazy var chainNameLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 18, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var chainHrpLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = HDA(0x1A7CEB)
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var chainHrpBackground: UIView = {
            let v = UIView()
            v.backgroundColor = .white
            v.layer.cornerRadius = 4
            v.layer.masksToBounds = true
            return v
        }()
        
        fileprivate lazy var chainHrpDescLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.AddressPrefix")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        override func initSubView() {
            
            layoutUI()
            configuration()
            logWhenDeinit()
        }
        
        public func configuration() {
            
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }
        
        public func layoutUI() {
            
            contentView.addSubviews([titleLabel, containerView])
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(18)
                make.height.equalTo(16)
            }
            
            containerView.addSubviews([haloIV, chainNameLabel, chainHrpBackground, chainHrpLabel, chainHrpDescLabel])
            
            containerView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(18)
                make.height.equalTo(75)
            }
            
            haloIV.snp.makeConstraints { (make) in
                make.top.bottom.centerX.equalToSuperview()
                make.width.equalTo(329)
            }
            
            chainNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(15)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(21)
            }
            
            chainHrpLabel.snp.makeConstraints { (make) in
                make.top.equalTo(chainNameLabel.snp.bottom).offset(7)
                make.left.equalTo(25)
                make.height.equalTo(14)
            }
            
            chainHrpBackground.snp.makeConstraints { (make) in
                make.edges.equalTo(chainHrpLabel).inset(UIEdgeInsets(top: -2, left: -5, bottom: -2, right: -5))
            }
            
            chainHrpDescLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(chainHrpLabel)
                make.left.equalTo(chainHrpBackground.snp.right).offset(5)
            }
        }
        
        override class func height(model: Any?) -> CGFloat { return 16 + 10 + 75 }
    }
}

//MARK: AddressItemView
extension FxCloudWidgetActionViewController {
    
    class AddressItemView: UIView {
        
        lazy var addressLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            v.lineBreakMode = .byTruncatingMiddle
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var remarkLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = UIColor.white.withAlphaComponent(0.88)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var deleteButton: UIButton = {
            let v = UIButton()
            v.image = IMG("FC.Delete")
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
            
            addSubviews([containerView, deleteButton])
            containerView.addSubviews([addressLabel, remarkLabel])
            
            containerView.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.right.equalToSuperview().inset(18)
                make.height.equalTo(64)
            }
            
            deleteButton.snp.makeConstraints { (make) in
                make.top.equalTo(containerView).offset(-10)
                make.left.equalTo(containerView).offset(-6)
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(14)
                make.left.right.equalToSuperview().inset(12)
            }
            
            remarkLabel.snp.makeConstraints { (make) in
                make.top.equalTo(34)
                make.left.right.equalToSuperview().inset(12)
            }
        }
        
        func relayout(hideRemark: Bool) {
            
            remarkLabel.isHidden = hideRemark
            addressLabel.numberOfLines = hideRemark ? 2 : 1
        }
    }
}

extension FxCloudWidgetActionViewController {
    
    class SelectItemView: UIView {
        
        var image: UIImage? { nil }
        fileprivate lazy var imageView = UIImageView(image: image)
        
        var text: String { "" }
        fileprivate lazy var textLabel: UILabel = {
            let v = UILabel()
            v.textAlignment = .center
            v.attributedText = NSAttributedString(string: text,
                                                  attributes: [.foregroundColor: HDA(0x2D90FF),
                                                               .font: XWallet.Font(ofSize: 14),
                                                               .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                               .underlineColor: HDA(0x2D90FF)])
            v.backgroundColor = .clear
            return v
        }()
        
        fileprivate lazy var containerView: UIView = {
            
            let r = CGRect(x: 0, y: 0, width: ScreenWidth - 18 * 2, height: 88)
            
            let borderLayer = CAShapeLayer()
            borderLayer.path = UIBezierPath(roundedRect: r, cornerRadius: 6).cgPath
            borderLayer.frame = r
            borderLayer.lineJoin = .round
            borderLayer.lineWidth = 1
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = UIColor.white.cgColor
            borderLayer.lineDashPattern = [2, 2]
            borderLayer.backgroundColor = UIColor.clear.cgColor
            
            let v = UIView(frame: r)
            v.backgroundColor = .clear
            v.layer.addSublayer(borderLayer)
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
            
            addSubviews([containerView, imageView, textLabel])
            
            containerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
            }
            
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32))
            }
            
            textLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(-16)
                make.centerX.equalToSuperview()
            }
        }
    }
}


//MARK: ResultTitleCell
extension FxCloudWidgetActionViewController {
    class ResultTitleCell: FxTableViewCell {
        
        lazy var resultIV = UIImageView(image: IMG("ic_success"))
        lazy var resultLabel: UILabel = {
            let v = UILabel()
            v.text = TR("CloudWidget.SubmitSuccess")
            v.font = XWallet.Font(ofSize: 20, weight: .medium)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat { return 136 }
        
        override func layoutUI() {
            
            contentView.addSubviews([resultLabel, resultIV])
            
            resultIV.snp.makeConstraints { (make) in
                make.top.equalTo(20)
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




