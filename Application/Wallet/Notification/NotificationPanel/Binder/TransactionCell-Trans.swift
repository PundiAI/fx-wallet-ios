//
//  TransactionCell-Trans.swift
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


extension NotificationPanelViewController {
    class FoldPendingCell: FoldBaseCell {
        lazy var waittingView = FxTxLoadingView.loading24().then { $0.loading() }
        lazy var subTextLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        lazy var timerLabel = TimerLabel()
        lazy var textBoxView = UIView()
        
        override func layoutUI() {
            super.layoutUI()
            contentBoxVie.addSubviews([waittingView, textBoxView])
            textBoxView.addSubviews([titleLabel, timerLabel, subTextLabel])
             
            textBoxView.snp.remakeConstraints { (make) in
                make.left.equalTo(waittingView.snp.right).offset(30.auto())
                make.right.equalToSuperview()
                let inser = 33.ifull(55).auto()
                make.top.equalToSuperview().inset(inser)
                make.bottom.equalToSuperview().inset(20.auto())
            }
            
            waittingView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalToSuperview().offset(10.auto())
                make.centerY.equalTo(textBoxView)
            }
            
            subTextLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(timerLabel.snp.bottom)
            }
             
            timerLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            titleLabel.text = TR("Notice.Progress.Title")
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(timerLabel.snp.top)
            }
        }

        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            guard let _data = model.rawValue.userInfoData else { return }
            let info = TokenInfoTxInfo.loadfromCache(with: JSON(_data))
            waittingView.setNeedsLayout()
            timerLabel.bind(time: Int(info.timestamp).d, content: info.transferType)
            let title = TR("Amount") + ": " + info.amountDisplay + " " + info.unit.displayCoinSymbol
            subTextLabel.text = title
        }
    }

    class FoldFailureCell: FoldBaseCell {
        lazy var alertView = UIImageView(image:IMG("attentionR"))
        lazy var subTextLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: HDA(0xFA6237))
        lazy var textBoxView = UIView()
        
        override func layoutUI() {
            super.layoutUI()
            contentBoxVie.addSubviews([alertView, textBoxView])
            textBoxView.addSubviews([titleLabel, subTextLabel])
             
            textBoxView.snp.remakeConstraints { (make) in
                make.left.equalTo(alertView.snp.right).offset(30.auto())
                make.right.equalToSuperview()
                let inser = 11.ifull(44 + 11).auto()
                make.top.equalToSuperview().inset(inser)
                make.bottom.equalToSuperview().inset(20.auto())
            }
            
            alertView.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalToSuperview().offset(10.auto())
                make.centerY.equalTo(textBoxView).offset(2)
            }
            
            subTextLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(18.auto())
                make.top.equalTo(textBoxView.snp.centerY)
            }
             
            titleLabel.text = TR("Transaction Failed")
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(18.auto())
                make.bottom.equalTo(textBoxView.snp.centerY)
            }
        }
        
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            self.viewModel = model
            guard let _data = model.rawValue.userInfoData else { return }
            let info = TokenInfoTxInfo.loadfromCache(with: JSON(_data))
            let title = TR("Amount") + ": " + info.amount.thousandth() + " " + info.unit.displayCoinSymbol
            subTextLabel.text = title
        }
    }
}

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
}



extension NotificationPanelViewController {
    
    class TransactionCell: ExpandNormalCell {
        lazy var subTitleLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        
        override func layoutUI() {
            super.layoutUI()
            contentBoxVie.addView(subTitleLabel)
            subTitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(5.auto())
                make.height.equalTo(20.auto())
            }
            textBoxView.snp.remakeConstraints { (make) in
                make.top.equalTo(subTitleLabel.snp.bottom)
                make.left.right.equalTo(contentBoxVie)
                make.bottom.equalTo(dateLabel.snp.top)
            }
        }
        
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            super.update(model: model, args)
            subTitleLabel.text = model.rawValue.title
        }
        
        open override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            let width = ScreenWidth - (24.auto() * 2) * 2
            let messageHeigt:CGFloat = messageSize(model: model).height
            let coententHeight:CGFloat = (72 + 56 + 20) + max(20, messageHeigt)
            return CGSize(width: width, height: coententHeight.auto())
        }
    }
}


extension NotificationPanelViewController {
    class TransactionFailureCell: ExpandNormalCell {
        lazy var subTitleLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: HDA(0xFA6237))
        
        lazy var helpButton: UIButton = {
            let v = UIButton().doNormal(title: TR("Help"))
            v.image = IMG("infoW")
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleColor = .white
            v.cornerRadius = 28.auto()
            v.backgroundColor = COLOR.title
            return v
        }()
        
        override func layoutUI() {
            super.layoutUI()
            contentBoxVie.addView(subTitleLabel)
            contentBoxVie.addView(helpButton)
            
            subTitleLabel.text = TR("Notice.Transaction.Failed.Title")
            subTitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.height.equalTo(20.auto())
            }
            textBoxView.snp.remakeConstraints { (make) in
                make.top.equalTo(subTitleLabel.snp.bottom)
                make.left.right.equalTo(contentBoxVie)
                make.bottom.equalTo(dateLabel.snp.top)
            }
            
            dateLabel.snp.remakeConstraints { (make) in
                make.left.right.equalTo(contentBoxVie)
                make.height.equalTo(20.auto())
                make.top.equalTo(textLabel.snp.bottom)
            }
            
            helpButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-24.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(56.auto())
            }
        }
        
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            textLabel.text = "\(TR("Amount")): ~"
            super.update(model: model, args)
            guard let _data = model.rawValue.userInfoData else { return }
            let info = TokenInfoTxInfo.loadfromCache(with: JSON(_data))
            let title = TR("Amount") + ": " + info.amountDisplay.thousandth() + " " + info.unit.displayCoinSymbol
            textLabel.text = title
            isRead = false
            helpButton.rx.tap.subscribe(onNext: { [weak self](_) in
                self?.router(event: "Help")
            }).disposed(by: reuseBag)
        }
        
        open override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            let width = ScreenWidth - (24.auto() * 2) * 2
            return CGSize(width: width, height: 221.auto())
        }
    }
    
    
    class TransactionInProgressCell: ExpandNormalCell {
        
        lazy var mtitleLabel = UILabel(text: TR("Notice.Progress.Title"),
                                      font: XWallet.Font(ofSize: 18, weight: .bold),
                                      textColor: COLOR.title,
                                      alignment: .center)
        
        lazy var timerLabel: TimerLabel = {
             let v = TimerLabel()
            v.textColor = COLOR.subtitle
            v.textAlignment = .center
            return v
        }()
        
        lazy var amountLabel = UILabel(text: TR("Amount: ~"), font: XWallet.Font(ofSize: 16, weight: .bold),
                                       textColor: COLOR.title,
                                         alignment: .center)
        
        let containerView = UIView(.white, cornerRadius: 36)
        
        lazy var loadingView: FXCommitTxLoadingView = {
            let v = FXCommitTxLoadingView.standard()
            v.textLabel.textColor = HDA(0x000000).withAlphaComponent(0.04)
            v.relayout(height: 60)
            v.clipsToBounds = true
            return v
        }()
        
        override func layoutUI() {
            super.layoutUI()
            
            contentBoxVie.isHidden = true
            titleLabel.isHidden = true
            dateLabel.isHidden = true
            loadingView.loading(true)
            contentView.insertSubview(containerView, belowSubview: contentBGView) 
            containerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            contentBGView.snp.remakeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(145.auto() + 4).priorityMedium()
                make.height.lessThanOrEqualTo(149.auto() + 4).priorityRequired()
                make.bottom.equalToSuperview().priorityHigh()
            }
             
            contentBGView.addSubviews([loadingView, mtitleLabel, timerLabel])
            loadingView.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(60)
            }
             
            mtitleLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(loadingView.snp.bottom).offset(8.auto())
            }
            
            timerLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(16.auto())
                make.bottom.lessThanOrEqualTo(contentBGView.snp.bottom).offset(-24.auto()).priorityHigh()
                make.bottom.equalTo(mtitleLabel.snp.bottom).offset(26.auto()).priorityLow()
            }
                 
            containerView.addSubview(amountLabel)
            amountLabel.adjustsFontSizeToFitWidth = true
            amountLabel.snp.makeConstraints { (make) in
                make.height.equalTo(44.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(containerView.snp.bottom).offset(-8.auto())
            }
        }
        
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            self.viewModel = model
            textLabel.text = "\(TR("Amount")): ~"
            guard let _data = model.rawValue.userInfoData else { return }
            let info = TokenInfoTxInfo.loadfromCache(with: JSON(_data))
            amountLabel.text = TR("Amount") + ": " + info.amountDisplay + " " + info.unit.displayCoinSymbol
            timerLabel.bind(time: Int(info.timestamp).d, content: info.transferType)
        }
         
        open override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            let width = ScreenWidth - (24.auto() * 2) * 2
            let coententHeight:CGFloat = (149 + 60).auto() + 4
            return CGSize(width: width, height: coententHeight)
        }
    }
}


extension NotificationPanelViewController {
        class TransactionAddTokenCell: TransactionCell {
            var addTokenView = AddTokenContentView()
            lazy var imageView = CoinImageView(size: CGSize(width: 48, height: 48).auto())
            
            override func layoutUI() {
                super.layoutUI()
                contentView.insertSubview(addTokenView, belowSubview: contentBGView)
                contentBoxVie.addSubview(imageView)
                
                addTokenView.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                imageView.snp.makeConstraints { (make) in
                    make.centerY.equalTo(contentBoxVie.snp.centerY)
                    make.right.equalTo(contentBoxVie)
                    make.size.equalTo(CGSize(width: 48, height: 48).auto())
                }
                
                textBoxView.snp.remakeConstraints { (make) in
                    make.top.equalTo(subTitleLabel.snp.bottom).offset(8.auto())
                    make.left.equalTo(contentBGView).offset(24.auto())
                    make.right.equalTo(contentBGView).offset(-96.auto())
                    make.bottom.equalToSuperview().offset(-24.auto())
                }

                contentBoxVie.snp.remakeConstraints { (make) in
                    make.top.bottom.equalTo(contentBGView)
                    make.centerX.equalToSuperview()
                    make.width.equalTo(messageCotentWidth)
                }
            }
             
            override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
                super.update(model: model, args)
                
                let contentHeight = TransactionAddTokenCell.topContentHeight(model: model)
                contentBGView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.height.lessThanOrEqualTo(contentHeight).priorityMedium()
                    make.bottom.equalToSuperview().priorityLow()
                }
                
                if let coin = model.coin {
                    imageView.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
                    addTokenView.addTokenLabel.text = TR("Notif.AddTokenNotice$", coin.token)
                    addTokenView.addTokenButton.title = TR("Notif.AddToken$", coin.token)
                    addTokenView.tokenButton.bind(coin)
                    addTokenView.addTokenButton.rx.tap.subscribe(onNext: { [weak self](_) in
                        self?.router(event: "addToken")
                    }).disposed(by: reuseBag)
                }
            }
            
            static func topContentHeight(model: NotificationPanelViewController.CellViewModel) ->CGFloat {
                let messageHeight = TransactionAddTokenCell.messageSize(model: model).height
                let contentHeight = 144.auto() + max(10.auto(), messageHeight)
                return contentHeight
            }
            
            override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
                let width:CGFloat = ScreenWidth - (24.auto() * 2) * 2
                if let coin = model.coin {
                    let contentHeight = TransactionAddTokenCell.topContentHeight(model: model)
                    let noticeHeight = TR("Notif.AddTokenNotice$", coin.token)
                        .heightWithConstrainedWidth(width: width, font: XWallet.Font(ofSize: 14, weight: .medium))
                    let height = contentHeight + noticeHeight + 112.auto()
                    return CGSize(width: width, height:height)
                }
                
                return CGSize.zero
            }
            
            override class func messageSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
                let width = ScreenWidth - (24 + 96).auto()
                let height:CGFloat = model.message?.string.heightWithConstrainedWidth(width: width,
                                                                                      font: XWallet.Font(ofSize: 14)) ?? 0
                return CGSize(width: width, height: height)
            }
        }
}
