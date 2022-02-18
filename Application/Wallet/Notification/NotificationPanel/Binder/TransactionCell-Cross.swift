//
//  TransactionCell-Cross.swift
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
    
    class TransactionCrossInProgressCell: ExpandNormalCell {
        let topContentView = UIView().then { $0.clipsToBounds = true }
        
        lazy var progressView: FxCrossProgressView = {
            let view = FxCrossProgressView.notification()
            return view
        }()
        
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
        
        override func layoutUI() {
            super.layoutUI()
            contentBoxVie.isHidden = true
            titleLabel.isHidden = true
            dateLabel.isHidden = true
            contentView.insertSubview(containerView, belowSubview: contentBGView)
            containerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            contentBGView.snp.remakeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.lessThanOrEqualTo(250.auto()).priorityRequired()
                make.bottom.equalToSuperview().priorityHigh()
            }
            
            contentBGView.addSubviews([topContentView, mtitleLabel, timerLabel])
            topContentView.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(mtitleLabel.snp.top).offset(-8.auto())
            }
            topContentView.addSubview(progressView)
            progressView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(163.auto())
            }
            
            mtitleLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22.auto())
                make.centerX.equalToSuperview()
                make.width.equalTo(messageCotentWidth)
                make.bottom.equalToSuperview().offset(-40.auto()).priorityHigh()
            }
             
            timerLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.width.equalTo(messageCotentWidth)
                make.height.equalTo(16.auto())
                make.bottom.lessThanOrEqualTo(contentBGView.snp.bottom).offset(-24.auto()).priorityHigh()
                make.bottom.equalTo(mtitleLabel.snp.bottom).offset(26.auto()).priorityLow()
            }
            
            containerView.addSubview(amountLabel)
            amountLabel.adjustsFontSizeToFitWidth = true
            amountLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(containerView.snp.bottom).offset(-24.auto())
            }
            
            self.rx.observe(CGRect.self, "bounds")
                .filterNil().map { $0.size.height <= NotificationPanelViewController.minFoldContentHeight }
                .subscribe(onNext: {[weak self] value in
                    self?.mtitleLabel.isHidden = value
                    self?.timerLabel.isHidden = value
                    self?.amountLabel.isHidden = value
                }).disposed(by: defaultBag)
        }
  
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) { 
            textLabel.text = "\(TR("Amount")): ~"
            guard let _data = model.rawValue.userInfoData else { return }
            let info = TokenInfoTxInfo.loadfromCache(with: JSON(_data))
            amountLabel.text = TR("Amount") + ": " + info.amountDisplay + " " + info.unit.displayCoinSymbol
            timerLabel.bind(time: Int(info.timestamp).d, content: info.transferType)
            let model = FxCrossModel.build(transferType: info.txType)
            progressView.stateSubject.onNext(model)
            
            let task = ChainTransactionServer.shared?.txTransaction(chainId: info.chainType.rawValue, tx: info.txHash, txType: info.txType) 
            task?.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] result in
                self?.updateCrossUI(txType:info.txType, status: result.0, finish: result.1)
            }).disposed(by: reuseBag)
        }
        
        func updateCrossUI(txType:String, status: [FxTransactionState], finish:Bool) { 
            let model = FxCrossModel.build(transferType: txType)
            if status.count == 2, let from = status.get(0), let to = status.get(1) {
                let fromState = TxState(rawValue: from.status) ?? .pending
                let toState = TxState(rawValue: to.status) ?? .empty
                model.from.setTxState(fromState)
                model.to.setTxState(fromState == .success ? .pending : toState)
                progressView.stateSubject.onNext(model)
                 
                let isSuccess = status.filter { $0.status == TxState.success.rawValue }.count == status.count
                if isSuccess , finish {
                    model.from.setTxState(.success)
                    model.to.setTxState(.success)
                    progressView.stateSubject.onNext(model)
                }
                
                let isFailure = status.filter { $0.status == TxState.failure.rawValue }.count > 0
                if isFailure {
                    model.from.setTxState(.failure)
                    model.to.setTxState(.failure)
                    progressView.stateSubject.onNext(model)
                }
            } 
        }
         
        open override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            let width = ScreenWidth - (24.auto() * 2) * 2
            let coententHeight:CGFloat = (250 + 44 + 16).auto()
            return CGSize(width: width, height: coententHeight)
        }
    }
    
    class TransactionCrossFailureCell: ExpandNormalCell {
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
            
            contentView.addView(helpButton)
            contentBoxVie.addView(subTitleLabel)
            subTitleLabel.text = TR("Notice.Transaction.Failed.Title")
            subTitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(6.auto())
                make.height.equalTo(20.auto())
            }
            textBoxView.snp.remakeConstraints { (make) in
                make.top.equalTo(subTitleLabel.snp.bottom)
                make.left.right.equalTo(contentBoxVie)
                make.bottom.equalTo(dateLabel.snp.top)
            }
            
            contentBoxVie.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(messageCotentWidth)
                make.bottom.equalTo(helpButton.snp.top)
            }
            
            helpButton.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalToSuperview().offset(-24.auto())
                make.height.equalTo(56.auto())
            }
        }
 
        override func update(model: NotificationPanelViewController.CellViewModel, _ args: CVarArg...) {
            textLabel.text = "\(TR("Amount")): ~"
            super.update(model: model, args)
            guard let _data = model.rawValue.userInfoData else { return }
            let info = TokenInfoTxInfo.loadfromCache(with: JSON(_data))
            let title = TR("Amount") + ": " + info.amount.thousandth() + " " + info.unit.displayCoinSymbol
            textLabel.text = title
            
            isRead = false
            helpButton.rx.tap.subscribe(onNext: { [weak self](_) in
                self?.router(event: "Help")
            }).disposed(by: reuseBag)
        }
        
        open override class func contentSize(model: NotificationPanelViewController.CellViewModel) -> CGSize {
            let width = ScreenWidth - (24.auto() * 2) * 2
            let messageHeight = messageSize(model: model).height
            let coententHeight:CGFloat = (200 + max(messageHeight, 21)).auto()
            return CGSize(width: width, height: coententHeight)
        }
    }
}
