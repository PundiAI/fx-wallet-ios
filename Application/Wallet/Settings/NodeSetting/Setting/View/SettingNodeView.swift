//
//  SettingNodeView.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/1/27.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Foundation
import UIKit
import WKKit
import RxSwift
import RxCocoa

extension SettingNodesController {
    class TopHeaderCell: FxTableViewCell {
        override class func height(model: Any?) -> CGFloat { return 28.auto() }
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        override func layoutUI() {
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.right.equalTo(-51.auto())
                make.bottom.equalTo(-8.auto())
                make.height.equalTo(20.auto())
            }
        }
    }
    
    class FxChianHeaderCell: TopHeaderCell {
        lazy var addButton: UIButton = {
            let v = UIButton(type:.system)
            v.setImage(IMG("Wallet.Add"), for: .normal)
            v.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            v.tintColor = .black
            return v
        }()
        
        override func layoutUI() {
            super.layoutUI()
            contentView.addSubview(addButton)
            addButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.right.equalToSuperview().inset(24.auto())
                make.size.equalTo(CGSize(width: 44, height: 24).auto())
            }
        }
    }
    
    class PanelCell: FxTableViewCell {
        lazy var pannel: UIView = {
            let v = UIView(COLOR.settingbc)
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            return 14.auto()
        }
        
        override func layoutUI() {
            contentView.addView(pannel)
            contentView.clipsToBounds = true
            pannel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
        }
    }
    
    class TopSpaceCell: PanelCell {
        override func layoutUI() {
            super.layoutUI()
            pannel.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().offset(16.auto())
            }
            pannel.autoCornerRadius = 16
            pannel.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        }
    }
    
    class BotSpaceCell: PanelCell {
        override func layoutUI() {
            super.layoutUI()
            pannel.snp.remakeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(-16.auto())
            }
            pannel.autoCornerRadius = 16
            pannel.layer.maskedCorners = [CACornerMask.layerMinXMaxYCorner, CACornerMask.layerMaxXMaxYCorner]
        }
    }
    
     
    class BaseCell: PanelCell {
        override class func height(model: Any?) -> CGFloat {
            return 40.auto()
        }
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18)
            v.textColor = COLOR.title
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var unAbleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.autoFont = true
            v.backgroundColor = .clear
            return v
        }()
 
        lazy var selectedBt: UIButton = {
            let v = UIButton()
            v.isUserInteractionEnabled = false
            v.setImage(IMG("ic_check"), for: UIControl.State.selected)
            v.setImage(UIImage() , for: .normal)
            return v
        }()
          
        override func layoutUI() {
            super.layoutUI()
            pannel.addSubviews([titleLabel, subTitleLabel, unAbleLabel,selectedBt])
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
                make.left.equalTo(titleLabel.snp.right).offset(20.auto())
            }
            unAbleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
                make.left.equalTo(titleLabel.snp.right).offset(20.auto())
            }
            
            selectedBt.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.centerY.equalToSuperview()
                make.right.equalTo(-24.auto())
            }
        }
    }
    
    class SingleCell: BaseCell {
        var enableBehavior = BehaviorRelay<Bool>(value: true)
        var selectedBehavior = BehaviorRelay<Bool>(value: false)
        
        override class func height(model: Any?) -> CGFloat {
            return 50.auto()
        }
        
        override func configuration() {
            super.configuration()
            self.unAbleLabel.text = TR("Setting.Newtrok.Unavailable")
            enableBehavior.asDriver().drive(onNext: {[weak self] enable in
                self?.titleLabel.alpha = enable ? 1 : 0.5
                self?.subTitleLabel.isHidden = enable ? false : true
                self?.unAbleLabel.isHidden = enable ? true : false
                self?.selectedBt.isHidden = enable ? false : true
            }).disposed(by: defaultBag)
            
            selectedBehavior.asDriver().drive(selectedBt.rx.isSelected)
                .disposed(by: defaultBag)
        }
    }
}
