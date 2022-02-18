//
//  NotificationBaseCell.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/5/10.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import UIKit
import pop
import WKKit
import RxSwift
import RxCocoa
import SwipeCellKit
import SnapKit
import SwiftyJSON

let messageCotentWidth:CGFloat = ScreenWidth - 24.auto() * 4

extension Int {
    var toAudioString: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
    }
}


extension NotificationPanelViewController {
    class fxNotificationViewCell: SwipeCollectionViewCell {
        var viewModel: CellViewModel?
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            layoutUI()
        }
        
        open class func contentSize(model: CellViewModel) -> CGSize {
            return .zero
        }
        
        open class func messageSize(model: CellViewModel) -> CGSize {
            return .zero
        }
        
        open func update(model:CellViewModel, _ args: CVarArg...) { }
        
        func layoutUI() { }
    }
}

extension NotificationPanelViewController {
    class FoldBaseCell: fxNotificationViewCell {
        lazy var topMaskView = UIView(.white)
        lazy var contentBGView: UIView = {
            let v = UIView(.white)
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()
        
        lazy var contentBoxVie = UIView().then { $0.clipsToBounds = true }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            layoutUI()
            inchView()
        }
        
        override func layoutUI() {
            contentView.addSubviews([contentBGView, contentBoxVie])
            contentView.insertSubview(topMaskView, aboveSubview: contentBGView)
            contentBoxVie.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(ScreenWidth - 24.auto() * 2)
            }
            
            contentBGView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            topMaskView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(contentBGView.snp.centerY)
            }
        }
        
        private func inchView() {
            topMaskView.isHidden = false
            topMaskView.screen(.iFull)?.isHidden = true
        }
        
        override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            return CGSize(width: ScreenBounds.width,
                          height: NotificationPanelViewController.minFoldContentHeight)
        }
    }
    
    
    class FoldNormalCell: FoldBaseCell {
        lazy var textBoxView = UIView().then { $0.clipsToBounds = true }
        lazy var textLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0).then { $0.autoFont = true }
        var alertNumRelay = BehaviorRelay<Int>(value: 0)
        
        lazy var alertNumView: UIButton = {
            let b = UIButton(HDA(0xFA6237), cornerRadius: 8)
            b.isUserInteractionEnabled = false
            b.titleLabel?.font = XWallet.Font(ofSize: 12, weight: .medium)
            b.titleLabel?.autoFont = true
            b.setTitleColor(UIColor.white, for: .normal)
            b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4.auto(), bottom: 2.auto(), right: 4.auto())
            b.borderColor = UIColor.white
            b.borderWidth = 1
            b.autoCornerRadius = 8
            return b
        }()
        
        lazy var leftAletView: UIImageView = {
            let v = UIImageView()
            v.image = IMG("ic_not_notify")!.withRenderingMode(.alwaysTemplate)
            v.tintColor = UIColor.black
            return v
        }()
         
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            layoutUI()
            alertNumRelay.map{ (count) -> String in
                if count > 0 && count <= 99 { return "\(count)"}
                if count > 99 {return "\(count)+"}
                return "0"
            }.bind(to: alertNumView.rx.title())
                .disposed(by: defaultBag)
            
            alertNumRelay.map{ (count) -> Bool in
                return count <= 0
            }.bind(to: alertNumView.rx.isHidden)
                .disposed(by: defaultBag)
            alertNumView.isHidden = true
            alertNumRelay.distinctUntilChanged()
                .filter { (count) -> Bool in
                    return count > 0 }
                .delay(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: {[weak self] _ in
                    self?.alertNumView.setNeedsLayout()
                    self?.alertNumView.shake()
                    self?.leftAletView.shake()
                }).disposed(by: defaultBag)
        }
        
        override func layoutUI() {
            super.layoutUI()
            contentBoxVie.addSubviews([leftAletView,alertNumView, textBoxView])
            textBoxView.snp.remakeConstraints { (make) in
                make.bottom.equalTo(contentBoxVie.snp.bottom).offset(-24.auto())
                make.right.equalTo(contentBoxVie.snp.right)
                make.left.equalTo(alertNumView.snp.right).offset(19.auto())
                make.height.lessThanOrEqualTo(50.auto())
                make.height.greaterThanOrEqualTo(34.auto()).priorityMedium()
                make.bottom.lessThanOrEqualToSuperview().offset(-24.auto()).priorityHigh()
            }
            textBoxView.addSubview(textLabel)
            textLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
  
            leftAletView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalToSuperview()
                make.centerY.equalTo(textBoxView.snp.centerY).offset(4.auto())
            }

            alertNumView.isHidden = true
            alertNumView.setTitle("0", for: .normal)
            alertNumView.snp.makeConstraints { (make) in
                make.left.equalTo(leftAletView.snp.right).offset(-10.auto())
                make.bottom.equalTo(leftAletView.snp.top).offset(10.auto())
                make.height.equalTo(16.auto())
                make.width.greaterThanOrEqualTo(16.auto())
            }
        }
        
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            self.viewModel = model
            let not = model.rawValue
            let unReadCount = (args.get(0) as? Int) ?? 0
            let row = (args.get(1) as? Int) ?? 0
            
            let content = not.title + (not.title.count > 0 ? " " : "") + not.message
            let attributes = [NSAttributedString.Key.font: XWallet.Font(ofSize: 14)]
            textLabel.attributedText = NSAttributedString(string: content, attributes: attributes)
            alertNumRelay.accept(unReadCount)
            isHidden = unReadCount <= 0
            contentBoxVie.isHidden = row > 0
        }
    }
}
 
extension NotificationPanelViewController { 
    class ExpandBaseCell: fxNotificationViewCell {
        lazy var contentBGView: UIView = {
            let v = UIView(.white)
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()
        
        lazy var contentBoxVie = UIView().then { $0.clipsToBounds = false }
        lazy var textBoxView = UIView().then { $0.clipsToBounds = true }
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        lazy var textLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        lazy var dateLabel = UILabel(font: XWallet.Font(ofSize: 12, weight: .medium), textColor: COLOR.subtitle)
        lazy var typeImageView = UIImageView(size: CGSize(width: 149, height: 149).auto())
        lazy var typeImageBoxView = UIView().then { $0.clipsToBounds = true }
        
        var isRead: Bool = false {
            didSet {
                contentBGView.clipsToBounds = isRead
                contentView.alpha = isRead ? 0.5 : 1.0
            }
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        var reuseBag = DisposeBag()
        override func prepareForReuse() {
            super.prepareForReuse()
            reuseBag = DisposeBag()
        }
        
        func configuration() {
            backgroundColor = .clear
            swipeOffset = 124.auto()
        }
     
        override func layoutUI() {
            contentView.addSubviews([contentBGView, typeImageBoxView, contentBoxVie])
            let views = [titleLabel, textBoxView, dateLabel]
            
            typeImageBoxView.addSubview(typeImageView)
            contentBoxVie.addSubviews(views)
            contentBoxVie.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(messageCotentWidth)
            }
            contentBGView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            textBoxView.addSubview(textLabel)
            textLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
            }
             
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(contentBoxVie).offset(24.auto())
                make.left.right.equalTo(contentBoxVie)
            }
             
            textBoxView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(contentBoxVie)
                make.bottom.equalTo(dateLabel.snp.top).offset(-8.auto())
            }
            
            dateLabel.backgroundColor = .clear
            dateLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(contentBoxVie)
                make.height.equalTo(20.auto())
                make.bottom.equalToSuperview().offset(-26.auto())
            }
            
            typeImageBoxView.snp.makeConstraints { (make) in
                make.edges.equalTo(contentBGView)
            }
            typeImageView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 149, height: 149).auto())
                make.right.equalTo(contentBGView).offset(24.auto())
                make.bottom.equalTo(contentBGView).offset(44.auto())
            }
        }
    }
    
    class ExpandNormalCell: ExpandBaseCell {
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            self.viewModel = model
            dateLabel.text = model.dateText
            textLabel.attributedText = model.message
            titleLabel.text = model.titleMsg
            typeImageView.image = model.msgIcon
            if !model.showAddToken {
                self.isRead = model.rawValue.isRead
            } else {
                self.isRead = false
            }
        }
        
        open override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {  
            let width = ScreenWidth - (24.auto() * 2) * 2
            let messageHeigt:CGFloat = messageSize(model: model).height
            let contentHeight:CGFloat = (107) + max(21, messageHeigt)
            return CGSize(width: width, height: contentHeight.auto())
        }
        
        open override class func messageSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            let width = ScreenWidth - (24.auto() * 2) * 2 
            let height:CGFloat = model.message?.string.heightWithConstrainedWidth(width: width,
                                                                                  font: XWallet.Font(ofSize: 14), lineSpacing: 4) ?? 0
            return CGSize(width: width, height: height)
        }
    }
}

