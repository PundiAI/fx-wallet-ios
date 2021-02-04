//
//  ChatBadgeBinder.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/2.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

class ChatBadgeBinder: ChatBadgeView {
    
    static var standard: ChatBadgeBinder { return ChatBadgeBinder(size: CGSize(width: 18, height: 18)) }
    
    var number: Int = 0 {
        didSet {
            self.isHidden = number <= 0
            
            var text = String(number)
            var width = 18
            if number < 10 {
                width = 18
            } else if number <= 99 {
                width = 25
            } else {
                width = 32
                text = "99+"
            }
            
            self.textLabel.text = text
            self.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize(width: width, height: 18))
            }
        }
    }
}


class ChatBadgeView: UIView {
        
    lazy var textLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 12, weight: .bold)
        v.textColor = .white
        v.backgroundColor = HDA(0xC91F1F)
        v.textAlignment = .center
        v.layer.cornerRadius = 9
        v.layer.masksToBounds = true
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 0.8
        return v
    }()
    
    lazy var shadow: UIView = {
        let v = UIView(HDA(0xC91F1F))
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowColor = UIColor.black.cgColor
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
        addSubviews([shadow, textLabel])
        
        textLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        shadow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(4)
            make.height.equalTo(6)
            make.left.right.equalToSuperview().inset(3)
        }
    }
}
