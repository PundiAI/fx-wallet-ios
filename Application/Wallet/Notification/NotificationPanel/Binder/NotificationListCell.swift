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

extension NotificationPanelViewController {
    class FoldCell: Cell {
        var alertNumRelay = BehaviorRelay<Int>(value: 0)
        
        lazy var topMaskView = UIView(.white)
        
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
            inchView()
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
            
            alertNumRelay.distinctUntilChanged()
                .filter { (count) -> Bool in
                    return count > 0
            }.delay(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: {[weak self] _ in
                    self?.alertNumView.shake()
                    self?.leftAletView.shake()
                }).disposed(by: defaultBag)
        }
        
        override func layoutUI() {
            super.layoutUI()
            
            contentView.insertSubview(topMaskView, aboveSubview: contentBGView)
            topMaskView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(contentBGView.snp.centerY)
            }
            
            contentView.addSubviews([leftAletView,alertNumView])
            leftAletView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalToSuperview().offset(24.auto())
                make.centerY.equalTo(textLabel).offset(2)
            }
            
            alertNumView.isHidden = true
            alertNumView.setTitle("0", for: .normal)
            alertNumView.snp.makeConstraints { (make) in
                make.left.equalTo(leftAletView.snp.right).offset(-10.auto())
                make.bottom.equalTo(leftAletView.snp.top).offset(10.auto())
                make.height.equalTo(16.auto())
                make.width.greaterThanOrEqualTo(16.auto())
            }
            
            textLabel.snp.remakeConstraints { (make) in
                make.bottom.equalTo(contentBGView).offset(-29.auto())
                make.right.equalTo(contentBGView).inset(24.auto())
                make.left.equalTo(leftAletView.snp.right).offset(24.auto())
                make.height.equalTo(34.auto())
                make.bottom.lessThanOrEqualToSuperview().offset(-24.auto())
            }
        }
        
        private func inchView() {
            topMaskView.isHidden = false
            topMaskView.inch(.iFull)?.isHidden = true
        }
    }
}
                


extension NotificationPanelViewController {
    
    class ExpandCell: Cell {
        
        var viewModel: CellViewModel?
        func bind(_ vm: CellViewModel) {
            self.viewModel = vm
            
            dateLabel.text = vm.dateText
            textLabel.attributedText = vm.message
            titleLabel.text = vm.titleMsg
            typeImage.image = vm.msgIcon 
            if !vm.showAddToken {
                self.isRead = vm.rawValue.isRead
            } else {
                self.isRead = false
            }
            
            
        }
        
        override func configuration() {
            super.configuration()
            swipeOffset = 120.auto()
        }
    }
}

extension NotificationPanelViewController {
    
    class TransactionCell: ExpandCell {
        
        override func bind(_ vm: CellViewModel) {
            super.bind(vm)

            subTitleLabel.text = vm.rawValue.title
            
            relayoutForTx(contentHeight: vm.contentHeight, vm.showAddToken) 
            if let coin = vm.coin, vm.showAddToken {
                
                imageView.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
                addTokenLabel.text = TR("Notif.AddTokenNotice$", coin.token)
                addTokenButton.title = TR("Notif.AddToken$", coin.token)
                
                tokenButton.bind(coin)
                
                addTokenButton.rx.tap.subscribe(onNext: { [weak self](_) in
                    self?.router(event: "addToken")
                }).disposed(by: reuseBag)
            }
        }
        
        override func configuration() {
            super.configuration()
            swipeOffset = 120.auto() 
        }
        
        override func layoutUI() {
            super.layoutUI()
            super.layoutForTx()
        }
    }
}
