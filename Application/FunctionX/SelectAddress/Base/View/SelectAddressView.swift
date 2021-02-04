//
//  SelectAddressView.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/6.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit

extension SelectAddressViewController {
    
    class View: UIView {
        
        lazy var navBar = FxBlurNavBar(size: CGSize(width: ScreenWidth, height: 60))
        var closeButton: UIButton { navBar.backButton }
        
        lazy var confirmButton: UIButton = {
            let v = UIButton()
            v.title = "OK"
            v.titleFont = XWallet.Font(ofSize: 14, weight: .bold)
            v.titleColor = .white
            v.backgroundColor = .clear
            v.disabledTitleColor = UIColor.white.withAlphaComponent(0.16)
            v.setBackgroundImage(IMG("ic_btn_normal67x46"), for: .normal)
            v.setBackgroundImage(IMG("ic_btn_disable67x46"), for: .disabled)
            v.setBackgroundImage(IMG("ic_btn_pressed67x46"), for: .highlighted)
//            v.contentHorizontalAlignment = .right
            return v
        }()
        
        lazy var navIconIV: UIImageView = {
            let v = UIImageView()
            v.layer.cornerRadius = 12
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var navTitleLabel: UILabel = {
            let v = UILabel()
            v.text = "Function.io"
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.textColor = HDA(0xffffff)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("WalletConnect.SelectAddress.Title")
            v.font = XWallet.Font(ofSize: 32, weight: .bold)
            v.textColor = .white
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var subtitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("WalletConnect.SelectAddress.Subtitle$", "Function.io")
            v.font = XWallet.Font(ofSize: 19)
            v.textColor = HDA(0x999999)
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var sectionView = UIView(COLOR.BACKGROUND)
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        func configuration() {
            
            backgroundColor = COLOR.BACKGROUND
            listView.backgroundColor = .clear
            closeButton.image = IMG("ic_close_white")
        }
        
        func layoutUI() {
            
            addSubview(listView)
            
            navBar.navigationArea.addSubviews([navIconIV, navTitleLabel, confirmButton])
            addSubview(navBar)
            
            navBar.relayout(statusHeight: 0)
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(60)
            }
            
            navIconIV.snp.makeConstraints { (make) in
                make.left.equalTo(closeButton.snp.right).offset(4)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
            
            navTitleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(navIconIV.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
            
            confirmButton.snp.makeConstraints { (make) in
                make.right.equalTo(-8)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 67, height: 46))
            }
            
            sectionView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 110 + navBar.height)
            listView.tableHeaderView = sectionView
            sectionView.addSubviews([titleLabel, subtitleLabel])

            titleLabel.snp.makeConstraints { (make) in
//                make.top.equalTo(navBar.height)
                make.centerY.equalToSuperview().offset(10)
                make.left.right.equalToSuperview().inset(16)
                make.height.equalTo(34)
            }

            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.left.right.equalToSuperview().inset(16)
//                make.height.equalTo(19)
            }
            
            listView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.bottom.left.right.equalToSuperview()
            }
        }
    }
}
