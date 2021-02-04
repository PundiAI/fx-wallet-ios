//
//  WalletConnectView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/12.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension WalletConnectViewController {
    
    class View: UIView {
        
        private lazy var connectingContainer = UIView(.white)
        lazy var connectingView = WalletConnectDappView.standard()
        lazy var helpButton: UIButton = {
            let v = UIButton()
            v.title = TR("Powered by WalletConnect >")
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = COLOR.subtitle
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var listView = WKTableView(frame: ScreenBounds, .white)
        
        lazy var disconnectButton: UIButton = {
            let v = UIButton()
            v.title = TR("Disconnect")
            v.bgImage = UIImage.createImageWithColor(color: HDA(0xFA6237))
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.autoCornerRadius = 28
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
            
            backgroundColor = COLOR.backgroud
            listView.isHidden = true
            disconnectButton.isHidden = true
        }
        
        func didConnect(_ v: Bool) {
            listView.isHidden = !v
            disconnectButton.isHidden = !v
        }
        
        private func layoutUI() {
            
            addSubviews([connectingContainer, listView, disconnectButton])
            connectingContainer.addSubviews([connectingView, helpButton])
            
            connectingContainer.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            connectingView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(connectingView.size)
            }
            
            helpButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-32.auto())
                make.left.right.equalToSuperview().inset(20.auto())
            }
            
            listView.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(disconnectButton.snp.top).offset(-8.auto())
            }
            
            disconnectButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }
    }
}



extension WalletConnectViewController {
    
    class DappCell: FxTableViewCell {
        
        private lazy var view = WalletConnectDappView(size: CGSize(width: ScreenWidth - 24.auto(), height: 195.auto()))
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? Dapp else { return }
            view.bind(vm)
        }
        
        override class func height(model: Any?) -> CGFloat { (24 + 195).auto() }
        
        override func layoutUI() {
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 24, bottom: 0, right: 24).auto())
            }
        }
    }
    
}
