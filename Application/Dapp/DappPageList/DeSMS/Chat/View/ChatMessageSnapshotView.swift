//
//  ChatMessageSnapshotView.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/16.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit


extension ChatViewController {
    
    class SnapshotView: UIView {
        lazy var hideButton = UIButton(.clear)
        
        lazy var actionContainer: UIView = {
            let v = UIView(HDA(0x2E2E2E))
            v.layer.cornerRadius = 8
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var line = UIView(UIColor.white.withAlphaComponent(0.24))
        
        var copyButton: UIButton { copyItemView.actionButton }
        lazy var copyItemView = SnapshotItemView(image: IMG("Chat.Copy_white"), text: TR("Copy_U"))
        
        var infoButton: UIButton { infoItemView.actionButton }
        lazy var infoItemView = SnapshotItemView(image: IMG("ic_warning_white"), text: TR("Chat.BlockInfo"))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = UIColor.black.withAlphaComponent(0.88)
        }

        private func layoutUI() {
            
            actionContainer.addSubviews([copyItemView, infoItemView, line])
            addSubview(hideButton)
            addSubview(actionContainer)
            
            actionContainer.frame = CGRect(x: 100, y: 100, width: 255, height: 72)
            
            hideButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            copyItemView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(36)
            }
            
            line.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
            
            infoItemView.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview()
                make.height.equalTo(36)
            }
        }
        
        func relayout(_ hideInfo: Bool) {
            line.isHidden = hideInfo
            infoItemView.isHidden = hideInfo
            actionContainer.height = hideInfo ? 36 : 72
        }
    }
    
    class SnapshotItemView: UIView {
        
        lazy var actionButton = UIButton()
        lazy var imageView = UIImageView()
        lazy var textLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            v.textColor = .white
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        convenience init(image: UIImage?, text: String) {
            self.init(frame: CGRect(x: 0, y: 0, width: 255, height: 32))
            textLabel.text = text
            imageView.image = image
        }
        
        private func configuration() {
            backgroundColor = HDA(0x2E2E2E)
        }
        
        private func layoutUI() {
            
            addSubviews([imageView, textLabel, actionButton])
            
            textLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(14)
                make.height.equalTo(16)
            }
            
            imageView.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-14)
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
            
            actionButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
