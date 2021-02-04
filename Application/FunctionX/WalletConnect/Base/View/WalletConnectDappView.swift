//
//  WalletConnectDappView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/9/29.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

class WalletConnectDappView: UIView {
    
    static func standard() -> WalletConnectDappView { WalletConnectDappView(size: CGSize(width: 327, height: 195).auto()) }
    
    
    lazy var container = UIView(.clear, cornerRadius: 36)
    
    private lazy var dappBackgroundIV = UIImageView(.clear)
    private lazy var dappBackgroundTopMask: CALayer = {
        let v = CAGradientLayer()
        v.startPoint = CGPoint(x:0.5, y:0)
        v.endPoint = CGPoint(x:0.5, y:1)
        v.colors = [UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.white.cgColor]
        return v
    }()
    
    private lazy var dappBackgroundBottomMask = UIView(.white)
    
    lazy var dappIV = CoinImageView(size: CGSize(width: 48, height: 48).auto(), image: IMG("WC.DappPlaceholder"))
    lazy var logoIV = CoinImageView(size: CGSize(width: 48, height: 48).auto(), image: IMG("Dapp.Fx"))
    lazy var linkIV = UIImageView(image: IMG("WC.Link"))
    
    lazy var dappUrlLabel: UILabel = {
        let v = UILabel(text: TR("WalletConnect.Connecting"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center)
        v.lineBreakMode = .byTruncatingMiddle
        return v
    }()
    
    lazy var dappNameLabel: UILabel = {
        let v = UILabel(text: TR("Connecting"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: COLOR.title, alignment: .center)
        v.adjustsFontSizeToFitWidth = true
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        logWhenDeinit()
        
        configuration()
        layoutUI()
    }
    
    func bind(_ dapp: Dapp) {
        
        let isIco = dapp.icon.hasSuffix(".ico")
        dappUrlLabel.text = dapp.url
        dappNameLabel.text = dapp.name
        dappBackgroundIV.setImage(urlString: dapp.icon) { [weak self](image) in
            self?.dappIV.image = image 
            if let _image = image, _image.size.height  <= 240 {
                self?.dappBackgroundIV.image = _image.blur(radius: 0.5, scale: isIco ? 1 : UIScreen.main.scale)
            }
        }
    }
    
    private func configuration() {
        backgroundColor = .white
        
        wk.displayShadow()
        layer.cornerRadius = 36.auto()
    }
    
    func layoutUI() {
        addSubview(container)
        container.addSubview(dappBackgroundIV)
        container.layer.addSublayer(dappBackgroundTopMask)
        container.addSubview(dappBackgroundBottomMask)
        
        container.addSubviews([logoIV, linkIV, dappIV, dappNameLabel, dappUrlLabel])
        
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        dappBackgroundIV.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }
        
        let topHeight: CGFloat = 100.auto()
        dappBackgroundTopMask.frame = CGRect(x: 0, y: 0, width: width, height: topHeight)
        dappBackgroundBottomMask.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: topHeight, left: 0, bottom: 0, right: 0))
        }
        
        dappIV.snp.makeConstraints { (make) in
            make.top.equalTo(40.auto())
            make.right.equalTo(linkIV.snp.left).offset(-10)
            make.size.equalTo(CGSize(width: 48, height: 48).auto())
        }
        
        linkIV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(dappIV)
            make.size.equalTo(CGSize(width: 24, height: 24).auto())
        }
        
        logoIV.snp.makeConstraints { (make) in
            make.top.size.equalTo(dappIV)
            make.left.equalTo(linkIV.snp.right).offset(10)
        }
        
        dappNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dappIV.snp.bottom).offset(16.auto())
            make.left.right.equalToSuperview().inset(20.auto())
            make.height.equalTo(30.auto())
        }
        
        dappUrlLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dappNameLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20.auto())
        }
    }
}
