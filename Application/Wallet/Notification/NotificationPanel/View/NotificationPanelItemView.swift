//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import pop
import WKKit
import RxSwift
import RxCocoa
import SwipeCellKit
import SnapKit

let messageCotentWidth:CGFloat = ScreenWidth - 24.auto() * 4

extension NotificationPanelViewController {
    class AddTokenContentView: UIView {
        lazy var addTokenBGView: UIView = {
            let v = UIView(HDA(0xF4F4F4))
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()
        lazy var contentView = UIView().then { $0.clipsToBounds = true }
        lazy var addTokenLabel = UILabel(text: TR("Notif.AddTokenNotice$", "NPXS"), font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title, lines: 2, alignment: .center)
        lazy var addTokenButton: UIButton = {
            let v = UIButton(COLOR.title, cornerRadius: 28)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleEdgeInsets = UIEdgeInsets(top: -20.auto(), left: 0, bottom: 0, right: 0)
            return v
        }()
        lazy var tokenButton = CoinTypeView().then{
            $0.style = .lightContent
            $0.isUserInteractionEnabled = false
        }
        override init(frame: CGRect) {
            super.init(frame:frame)
            addView(addTokenBGView, contentView)
            contentView.addView(addTokenLabel, addTokenButton)
            addTokenButton.addSubview(tokenButton)
            
            addTokenBGView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            contentView.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(24.auto())
                make.centerX.equalToSuperview()
                make.width.equalTo(messageCotentWidth)
            }
            
            addTokenLabel.adjustsFontSizeToFitWidth = true
            addTokenLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(addTokenButton.snp.top).offset(-16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            addTokenButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(56.auto())
            }
            tokenButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-7.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 20).auto() )
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    class BaseCell: SwipeCollectionViewCell {
        lazy var contentBGView: UIView = {
            let v = UIView(.white)
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()
        
        lazy var contentBoxVie = UIView().then { $0.clipsToBounds = false }
        lazy var textBoxView = UIView().then { $0.clipsToBounds = false }
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
     
        func layoutUI() { 
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
                make.height.equalTo(24.auto())
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
}
