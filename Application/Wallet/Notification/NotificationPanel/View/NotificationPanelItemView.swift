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

extension NotificationPanelViewController {
    class Cell: SwipeCollectionViewCell {
        lazy var contentBGView: UIView = {
            let v = UIView(.white)
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()
        
        lazy var contentBoxVie = UIView().then { $0.clipsToBounds = true }
        
        lazy var tempBGView: UIView = {
            let v = UIView(.clear)
            v.layer.cornerRadius = 36.auto()
            return v
        }()

        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 18, weight: .medium), textColor: COLOR.title)
        lazy var subTitleLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        lazy var typeImage = UIImageView(size: CGSize(width: 149, height: 149).auto())
        lazy var textLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        lazy var dateLabel = UILabel(font: XWallet.Font(ofSize: 12, weight: .medium), textColor: COLOR.subtitle)
        lazy var imageView = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        
        lazy var addTokenBGView: UIView = {
            let v = UIView(HDA(0xF4F4F4))
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()
        
        lazy var addTokenLabel = UILabel(text: TR("Notif.AddTokenNotice$", "NPXS"), font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title, lines: 0, alignment: .center)
        lazy var addTokenButton: UIButton = {
            let v = UIButton(COLOR.title, cornerRadius: 28)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            return v
        }()
        
        var isRead: Bool = false {
            didSet {
                contentBGView.clipsToBounds = isRead
                self.contentView.alpha = isRead ? 0.5 : 1.0
                
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
            imageView.isHidden = true
            addTokenBGView.isHidden = true
            subTitleLabel.isHidden = true 
        }
        
        lazy var tokenButton = CoinTypeView().then{ $0.style = .lightContent }
          
        func layoutUI() {
            contentView.addSubviews([contentBGView, contentBoxVie])
            contentBoxVie.addSubviews([tempBGView, titleLabel, subTitleLabel, textLabel, dateLabel, imageView])
            contentBoxVie.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            contentBGView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            tempBGView.snp.makeConstraints { (make) in
                make.edges.equalTo(contentBGView)
            }
             
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(contentBGView).offset(24.auto())
                make.left.equalTo(contentBGView).offset(24.auto())
                make.right.equalTo(contentBGView).offset(-24.auto())
                make.height.equalTo(24.auto())
            }
            
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(contentBGView).offset(24.auto())
                make.left.equalTo(contentBGView).offset(24.auto())
                make.right.equalTo(contentBGView).offset(-24.auto())
                make.height.equalTo(24.auto())
            }
            
            textLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(contentBGView).offset(24.auto())
                make.right.equalTo(contentBGView).offset(-24.auto())
                make.bottom.lessThanOrEqualToSuperview().offset(-24.auto())
            }
            
            dateLabel.snp.makeConstraints { (make) in
                make.top.equalTo(textLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(contentBGView).inset(24.auto())
                make.height.equalTo(20.auto())
                make.bottom.lessThanOrEqualToSuperview().offset(-24.auto())
            }
            
            tempBGView.addSubview(typeImage)
            tempBGView.clipsToBounds = true
            typeImage.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 149, height: 149).auto())
                make.right.equalTo(contentBGView).offset(24.auto())
                make.bottom.equalTo(contentBGView).offset(44.auto())
            }
        }
        
        func layoutForTx() { 
            contentView.insertSubview(addTokenBGView, belowSubview: contentBGView)
            addTokenBGView.addSubviews([addTokenLabel, addTokenButton])
            contentBGView.snp.remakeConstraints { (make) in
                make.edges.equalTo(contentBoxVie)
            }
            contentBoxVie.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.lessThanOrEqualTo(160.auto())
                make.bottom.lessThanOrEqualToSuperview()
            }
            
            imageView.snp.makeConstraints { (make) in
                make.centerY.equalTo(contentBGView.snp.centerY)
                make.right.equalTo(contentBGView).offset(-24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            addTokenBGView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            addTokenLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            addTokenButton.snp.makeConstraints { (make) in
                make.top.equalTo(addTokenLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            addTokenButton.titleEdgeInsets = UIEdgeInsets(top: -20.auto(), left: 0, bottom: 0, right: 0)
         
            addTokenButton.addSubview(tokenButton)
            
            tokenButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-7.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 20).auto() )
            }
        }
        
        func relayoutForTx(contentHeight: CGFloat, _ showAdd: Bool = false) {
            
            imageView.isHidden = !showAdd
            addTokenBGView.isHidden = !showAdd
            contentBGView.backgroundColor = UIColor.white
            contentBGView.snp.remakeConstraints { (make) in
                make.edges.equalTo(contentBoxVie)
            }
            
            subTitleLabel.isHidden = false
            if !showAdd {
                
                subTitleLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                    make.left.equalTo(contentBGView).offset(24.auto())
                    make.right.equalTo(contentBGView).offset(-24.auto())
                    make.height.equalTo(24.auto())
                }
                
                textLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(subTitleLabel.snp.bottom).offset(8.auto())
                    make.left.equalTo(contentBGView).offset(24.auto())
                    make.right.equalTo(contentBGView).offset(-24.auto())
                    make.bottom.lessThanOrEqualToSuperview().offset(-24.auto())
                }
            } else {
                
                subTitleLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                    make.left.equalTo(contentBGView).offset(24.auto())
                    make.right.equalTo(contentBGView).offset(-24.auto())
                    make.height.equalTo(24.auto())
                }
                
                textLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(subTitleLabel.snp.bottom).offset(8.auto())
                    make.left.equalTo(contentBGView).offset(24.auto())
                    make.right.equalTo(contentBGView).offset(-96.auto())
                    make.bottom.lessThanOrEqualToSuperview().offset(-24.auto())
                }
                
                addTokenLabel.snp.updateConstraints { (make) in
                    make.top.equalTo(contentHeight + 16.auto())
                }
            }
        }
    }
}
