//
//  NotificationListHeadView.swift
//  XWallet
//
//  Created by Pundix54 on 2020/7/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Foundation
import pop
import WKKit
import RxSwift

extension NotificationPanelViewController {
    class ListHeaderView: UIView {
        lazy var contentView = UIView()
        
        let headerBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
            $0.backgroundColor = HDA(0xF4F4F4).withAlphaComponent(0.88)
            $0.layer.shadowColor = HDA(0x0A0E1D).cgColor
            $0.layer.shadowRadius = 4
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowOpacity = 0.1
            $0.isHidden = true
        }
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Notifications.Title")
            v.font = XWallet.Font(ofSize: 24, weight: .medium)
            v.autoFont = true
            v.textColor = HDA(0x080A32)
            return v
        }()
        
        lazy var foldButton: UIButton = {
            let v = UIButton(type:.system)
            v.title = TR("Notifications.Fold")
            v.titleColor = HDA(0x080A32)
            v.autoCornerRadius = 18
            v.setImage(IMG("ic_not_UpB"), for: .normal)
            v.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 1)
            v.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -1)
            v.tintColor = HDA(0x080A32)
            v.titleLabel?.font = XWallet.Font(ofSize: 14,  weight: .medium)
            v.titleLabel?.autoFont = true
            v.backgroundColor = HDA(0xF0F3F5)
            return v
        }()
         
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layoutUI()
            configuration()
        }
        
        private func configuration() {
            backgroundColor = .clear
            layer.zPosition = 0
        }
        
        private func layoutUI() {
            addSubview(headerBlurView)
            headerBlurView.isHidden = true
            headerBlurView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            } 
            addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20.auto(), bottom: 0, right: 20.auto()) )
            }
            contentView.addSubviews([titleLabel, foldButton])
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(4.auto())
                make.centerY.equalTo(foldButton.snp.centerY)
                make.right.lessThanOrEqualTo(foldButton.snp.left).offset(-20.auto())
            }
            
            foldButton.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 81, height: 36).auto())
                make.right.equalToSuperview().offset(-4.auto())
                make.bottom.equalToSuperview().offset(-19.auto())
            } 
        }
        
        func fold(animated:Bool = true) {
            headerBlurView.isHidden = true
            if animated {
                if let anim = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY) {
                    anim.toValue = 20.auto()
                    contentView.layer.pop_add(anim, forKey: "offsetY")
                }
                
                if let anim = POPSpringAnimation(propertyNamed: kPOPLayerOpacity) {
                    anim.toValue = 0
                    contentView.layer.pop_add(anim, forKey: "opacity")
                }
            }else {
                contentView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 20.auto())
                contentView.alpha = 0
            } 
        }
        
        func expand(animated:Bool = true) {
            headerBlurView.isHidden = true
            if animated { 
                if let anim = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY) {
                    anim.toValue = 0 
                    contentView.layer.pop_add(anim, forKey: "offsetY")
                }
                
                if let anim = POPSpringAnimation(propertyNamed: kPOPLayerOpacity) {
                    anim.toValue = 1
                    contentView.layer.pop_add(anim, forKey: "opacity")
                }
            }else {
                contentView.transform = CGAffineTransform.identity
                contentView.alpha = 1
            }
        }
    }
}


