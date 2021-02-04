//
//  TokenInfoAddressView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/7/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension TokenInfoAddressListBinder {
    class View: UIView {
        
        private var listTop: CGFloat { topEdge + 20 }
        
        lazy var listContainer: UIView = {
           
            let v = UIView(.white)
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - listTop)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight] , cornerRadii: CGSize(width: 40, height: 40)).cgPath
            v.frame = bounds
            v.layer.mask = maskLayer
            return v
        }()
        
        lazy var listView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: UITableView.Style.plain)
            v.separatorStyle = .none
            v.backgroundColor = .white
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            
            v.cornerRadius = 40
            v.estimatedRowHeight = 87
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionFooterHeight = 0
            return v
        }()
        
        private lazy var listHeader = UIView(.white)
        lazy var listFooter = UIView(.white)
        lazy var addAddressButton: UIButton = {
           
            let v = UIButton()
            v.image = IMG("Wallet.Add")
            v.title = TR("Token.Add.Address")
            v.titleFont = XWallet.Font(ofSize: 18)
            v.titleColor = HDA(0x080A32)
            v.cornerRadius = 28
            v.setTitlePosition(.right, withAdditionalSpacing: 10)
            v.backgroundColor = HDA(0xF0F3F5)
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
            
            addSubview(listContainer)
            listContainer.addSubview(listView)
            
            listHeader.size = CGSize(width: ScreenWidth, height: 20)
            listView.tableHeaderView = listHeader
            
            listFooter.size = CGSize(width: ScreenWidth, height: 32 + 56 + 45)
            listFooter.addSubview(addAddressButton)
            listView.tableFooterView = listFooter
            
            listContainer.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: listTop, left: 0, bottom: 0, right: 0))
            }
            
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            addAddressButton.snp.makeConstraints { (make) in
                make.top.equalTo(32)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(56)
            }

        }
    
    }
}
  
