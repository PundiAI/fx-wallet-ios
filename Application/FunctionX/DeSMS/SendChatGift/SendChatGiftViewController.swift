//
//  SendChatGiftViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import FunctionX

extension WKWrapper where Base == SendChatGiftViewController {
    var view: SendChatGiftViewController.View { return base.view as! SendChatGiftViewController.View }
}

extension SendChatGiftViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let receiver = context["receiver"] as? SmsUser,
            let wallet = context["wallet"] as? FxWallet else { return nil }

        return SendChatGiftViewController(receiver: receiver, wallet: wallet)
    }
}

class SendChatGiftViewController: WKViewController {
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(receiver: SmsUser, wallet: FxWallet) {
        self.fx = FunctionX(wallet: wallet)
        self.receiver = receiver
        super.init(nibName: nil, bundle: nil)
    }
    
    fileprivate let fx: FunctionX
    fileprivate let receiver: SmsUser
    fileprivate var wallet: FxWallet{ fx.sms.wallet! }
    
    fileprivate var sender: SmsUser?
    fileprivate var fetchSenderInfo: APIAction<SmsUser>!
    
    fileprivate var selectedCrypto = BehaviorRelay<SmsCoin>(value: SmsCoin.default)
    fileprivate lazy var selectedFee = BehaviorRelay<FeeItemView>(value: wk.view.normalFeeView)
    
    fileprivate var commitTx: JsonAPIAction!
    
    override func loadView() { self.view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindFee()
        bindNavBar()
        bindCommit()
        bindPayment()
        bindCryptoList()
        bindSenderInfo()
        bindReceiverInfo()
        bindKeyboard()

        fetchData()
    }
    
    private func fetchData() {
        fetchSenderInfo.execute()
    }
    
    //MARK: Bind
    
    private func bindNavBar() {
        
        navigationBar.isHidden = true
        wk.view.navBar.rightButton.rx.tap.subscribe(onNext: { [weak self](_) in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: defaultBag)
    }
    
    private func bindReceiverInfo() {
        
        wk.view.toNameLabel.text = receiver.name
        wk.view.toNameFxLabel.text = "(\(receiver.name).fx)"
        wk.view.toAddressLabel.text = receiver.address
    }
    
    private func bindSenderInfo() {

        fetchSenderInfo = APIAction<SmsUser>(fx.sms.query().map{ SmsUser.instance(fromQuery: $0) })
        
        let itemHeight = CryptoCell.height(model: nil)
        fetchSenderInfo.bind(self, onNext: { [weak self] (sender) in
            self?.sender = sender
            
            self?.wk.view.cryptoArrowIV.isHidden = sender.coins.count <= 1
            self?.wk.view.cryptoActionButton.isHidden = sender.coins.count <= 1
            if sender.coins.count >= 1 {
                
                self?.selectedCrypto.accept(sender.coins.first!)
                self?.wk.view.cryptoListView.snp.updateConstraints({ (make) in
                    make.height.equalTo(min(3, CGFloat(sender.coins.count)) * itemHeight)
                })
            }
            
            self?.wk.view.cryptoListView.reloadData()
        })
    }

    private func bindCryptoList() {
        
        weak var welf = self
        wk.view.cryptoActionButton.rx.tap.subscribe(onNext: { (_) in
            welf?.wk.view.cryptoListView.isHidden = false
        }).disposed(by: defaultBag)
        
        wk.view.hideActionButton.rx.tap.subscribe(onNext: { (_) in
            welf?.wk.view.cryptoListView.isHidden = true
        }).disposed(by: defaultBag)
        
        wk.view.cryptoListView.viewModels = { section in
            guard let coins = welf?.sender?.coins else { return section }
            
            for coin in coins {
                section.push(CryptoCell.self) {
                    $0.titleLabel.text = coin.denom.uppercased()
                }
            }
            return section
        }
        
        wk.view.cryptoListView.didSeletedBlock = { (_, indexPath) in
            
            welf?.wk.view.cryptoListView.isHidden = true
            if let crypto = welf?.sender?.coins[indexPath.row] {
                welf?.selectedCrypto.accept(crypto)
            }
        }
        
        selectedCrypto.subscribe(onNext: { (coin) in
            
            welf?.wk.view.cryptoNameLabel.text = coin.denom.uppercased()
            welf?.wk.view.usableAmountLabel.text = "≤ \(coin.amount.fxc.thousandth())"
        }).disposed(by: defaultBag)
    }
    
    private func bindFee() {
        
        selectFee(wk.view.normalFeeView.actionButton)
        wk.view.fasterFeeView.actionButton.bind(self, action: #selector(selectFee(_:)), forControlEvents: .touchUpInside)
        wk.view.normalFeeView.actionButton.bind(self, action: #selector(selectFee(_:)), forControlEvents: .touchUpInside)
        wk.view.slowerFeeView.actionButton.bind(self, action: #selector(selectFee(_:)), forControlEvents: .touchUpInside)
        
        weak var welf = self
        selectedCrypto.subscribe(onNext: { (coin) in
            
            welf?.wk.view.fasterFeeView.amountLabel.text = "0.00182 \(coin.denom.uppercased())"
            welf?.wk.view.normalFeeView.amountLabel.text = "0.00419 \(coin.denom.uppercased())"
            welf?.wk.view.slowerFeeView.amountLabel.text = "0.0021 \(coin.denom.uppercased())"
        }).disposed(by: defaultBag)
        
        wk.view.fasterFeeView.estimateLabel.text = TR("SendGift.Estimated$", "39 secs")
        wk.view.fasterFeeView.legalAmountLabel.text = "$ 0.03"
        
        wk.view.normalFeeView.estimateLabel.text = TR("SendGift.Estimated$", "1 min 39 secs")
        wk.view.normalFeeView.legalAmountLabel.text = "$ 0.09"
        
        wk.view.slowerFeeView.estimateLabel.text = TR("SendGift.Estimated$", "2 min 10 secs")
        wk.view.slowerFeeView.legalAmountLabel.text = "$ 0.015"
    }
    
    @objc private func selectFee(_ sender: UIButton) {
        guard let fee = sender.superview as? FeeItemView else { return }
        
        self.selectedFee.value.isSelected = false
        self.selectedFee.accept(fee)
        self.selectedFee.value.isSelected = true
    }
    
    private func bindPayment() {
        
        weak var welf = self
        Observable.combineLatest(wk.view.amountInputTF.rx.text, selectedCrypto, selectedFee)
            .subscribe(onNext: { (t) in
                let (text, coin, fee) = t
                
                let amount = text?.isEmpty == true ? "0" : text!
                welf?.wk.view.totalPaymentLabel.text = "\(amount) \(coin.denom.uppercased())"
//                welf?.wk.view.totalLegalPaymentLabel.text = String(format: "$ %.2f", amount.f * 0.1)
            }).disposed(by: defaultBag)
    }
    
    private func bindCommit() {
        
        let service = SmsServiceManager.service(forWallet: wallet, receiver: receiver)
        let privateKey = wallet.privateKey
        let tx = FxTransaction([:])
        tx.to = receiver.address
        tx.from = wallet.address
        tx.txType = .smsSend
        tx.txChain = .sms
        wk.view.sendButton.rx.tap.subscribe(onNext: { [weak self](_) in
            guard let this = self,
                let token = self?.selectedCrypto.value,
                var amount = self?.wk.view.amountInputTF.text, amount.f > 0.00001 else {
                    self?.hud?.text(m: "please input valid amount")
                    return
            }
            
            amount = amount.fwei
            guard amount.isLessThan(decimal: token.amount) else {
                self?.hud?.text(m: "no enough token")
                return
            }
            self?.view.endEditing(true)
            
            tx.rawValue = ["amount": ["amount": amount, "denom": token.denom]]
            let tokens = [TransactionMessage.Coin(amount: amount, denom: token.denom)]
            let commitTxImp = service.send(sms: this.wk.view.messageInputTV.text, transferTokens: tokens)
            Router.showAuthorizeDappAlert(dapp: .sms, authorityTypes: [1]) { (authVC, allow) in
                authVC?.dismiss(animated: false, completion: {
                    guard allow else {
                        self?.hud?.text(m: "user denied")
                        return
                    }
                    
                    Router.showBroadcastTxAlert(tx: tx, privateKey: privateKey, commitTxImp: commitTxImp) { (error, result) in
                        
                        if WKError.canceled.isEqual(to: error) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                })
            }
        }).disposed(by: defaultBag)
    }
    
    private func bindKeyboard() {
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y
                
                this.wk.view.containerView.snp.updateConstraints( { (make) in
                    make.bottom.equalTo(this.view).offset(-margin)
                })
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                this.wk.view.containerView.snp.updateConstraints( { (make) in
                    make.bottom.equalTo(this.view)
                })
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
        }).disposed(by: defaultBag)
    }
}
