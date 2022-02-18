//
//  TokenInfoHistoryCell.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension UIStackView {
    func removeAll() {
        for  v in self.subviews {
            v.isHidden = true
        }
    }
}

extension TokenInfoHistoryListBinder {
    class ReFreshCell: FxTableViewCell {
        
        lazy var view = UpdateStateView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? BehaviorRelay<(String, UpdateStateView.State)> else { return }
            weak var welk = self
            
            vm.subscribe(onNext: { (rs) in
                welk?.view.upLabel.text = rs.0
                welk?.view.dataType = rs.1
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat { return 51.auto() }
    }
}


extension TokenInfoHistoryListBinder {
    class BTCCell: FxTableViewCell {
        
        lazy var view = BTCView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            view.txIcon.image = vm.txIcon
            view.moneyContainer.removeAll()
            view.stateContainer.removeAll()
            view.addressContainer.removeAll()
            let amountLabel = view.titleLabel(text: vm.btcAmountText)
            amountLabel.textColor = vm.btcAmountColor
            view.moneyContainer.addArrangedSubview(amountLabel)
            initStateView(vm)
            view.timeLabel.text = vm.dateText
            
            let complateBlock:((String, Int) -> Void) = { [weak self](fee, status) in
                vm.txInfo.state = Int64(status)
                self?.view.stateContainer.removeAll()
                self?.initStateView(vm)
                self?.view.timeLabel.text = vm.dateText
            }
            
            if let task = ChainTransactionServer.shared?.txTransaction(chainId: Int(vm.txInfo.chainId), tx: vm.txInfo.txHash, txType: vm.txInfo.txType) {
                task.observeOn(MainScheduler.instance).takeLast(1)
                    .subscribe(onNext: { (s) in
                        if s.1 == true {
                            complateBlock(s.0[0].fees, s.0[0].status)
                        }
                    }).disposed(by: reuseBag)
            }else {
                complateBlock("", Int(vm.txInfo.state))
            }
            
            for address in vm.btcAddressList {
                let addressView = AddressView()
                addressView.amountLabel.text = vm.amountPrefix + address.amount
                addressView.addressLabel.text = address.sortAddress()
                view.addressContainer.addArrangedSubview(addressView)
            }
        }
        
        private func initStateView(_ vm: CellViewModel) {
            switch vm.txInfo.txState {
            case .pending:
                let pendinglabe = view.stateLabel(text: TR("Token.History.Pending"), state: .pending)
                let waitView = view.waittingView()
                view.stateContainer.addArrangedSubview(pendinglabe)
                view.stateContainer.addArrangedSubview(waitView)
                waitView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16, height: 16).auto())
                }
                waitView.setNeedsLayout()
                break
            case .success:
                view.stateContainer.addArrangedSubview(view.stateLabel(text: TR("Success"), state: .success))
            case .failed:
                view.stateContainer.addArrangedSubview(view.stateLabel(text: TR("Failed"), state: .failed))
                let helpview = view.helpView()
                    helpview.tapBtn.rx.tap.subscribe(onNext: { [weak self](_) in
                    self?.router(event: "Help")
                }).disposed(by: reuseBag)
                view.stateContainer.addArrangedSubview(helpview)
            case .cancel:
                view.stateContainer.addArrangedSubview(view.stateLabel(text: TR("Cancel"), state: .failed))
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? CellViewModel else { return 0}
            return vm.height
        }
    }
}


extension TokenInfoHistoryListBinder {
    class ETHCell: FxTableViewCell {
        
        lazy var view = ETHView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            
            guard let vm = viewModel as? CellViewModel else { return }
            view.txIcon.image = vm.txIcon
            
            view.feeLabel.text = vm.feeText
            view.feeLabel.isHidden = !vm.showFee()

            
            view.stateContainer.removeAll()
            view.infoContainer.removeAll()
            view.moneyLabel.text = vm.txInfo.amount.thousandth()
            
            if let coin = vm.coin {
                view.moneyLabel.text = vm.txInfo.amount.thousandth(coin.decimal) + " \(coin.symbol)"
            }
            
            
            let method = vm.txInfo.transferType
            if method.length > 0 {
                view.functionLabel.text = method
            } else {
                view.functionLabel.text = "Transfer"
            }

            initTxInfo(vm)
            initStateView(vm)
            view.timeLabel.text = vm.dateText
            
            let complateBlock:((String, Int) -> Void) = { [weak self](fee, state) in
                vm.txInfo.state = Int64(state)
                self?.view.stateContainer.removeAll()
                self?.initStateView(vm)
                self?.view.timeLabel.text = vm.dateText
                if fee.length > 0, fee != "0" {
                    self?.view.feeLabel.text = vm.feeContent(money: fee)
                }
            }
            
            if let task = ChainTransactionServer.shared?.txTransaction(chainId: Int(vm.txInfo.chainId),
                                                                       tx: vm.txInfo.txHash,
                                                                       txType: vm.txInfo.txType, txAction: Int(vm.txInfo.type)) {
                task.observeOn(MainScheduler.instance).subscribe(onNext: { (s) in
                    if s.1 == true {
                        complateBlock(s.0[0].fees, s.0[0].status)
                    }
                    
                    }).disposed(by: reuseBag)
            }else {
                complateBlock("", Int(vm.txInfo.state))
            }
        }
        
        private func addTagView(tagName: String) {
            let markView = view.tagButton(text: tagName)
            view.infoContainer.addArrangedSubview(markView)
            
            markView.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(50)
                make.width.lessThanOrEqualTo(100)
                make.height.equalTo(22.auto())
                make.centerY.equalToSuperview()
            }
        }
        
        private func defaultTxInfo(_ vm: CellViewModel) {
            view.infoContainer.addArrangedSubview(view.defaultLabel(text: TR("From")))
            if let remark =  vm.remark.value, remark.length > 0  {
                addTagView(tagName: remark)
                
            } else {
                view.infoContainer.addArrangedSubview(view.subTitleLabel(text: vm.fromText, textColor: vm.addressColor(address: vm.txInfo.fromAddress)))
            }
            view.infoContainer.addArrangedSubview(view.defaultLabel(text: TR("To")))
            
            if let toRemark = vm.toRemark.value, toRemark.length > 0  {
                addTagView(tagName: toRemark)
            } else {
                view.infoContainer.addArrangedSubview(view.subTitleLabel(text: vm.toText, textColor: vm.addressColor(address: vm.txInfo.toAddress)))
            }
        }
        
        private func initTxInfo(_ vm: CellViewModel) {
            
            if vm.txInfo.isFxCoreAction() {
                defaultTxInfo(vm)
                return
            }
            
            if vm.txInfo.isUnKnow() {
                defaultTxInfo(vm)
                return 
            }
            
            if vm.isTransIn {
                
                if view.functionLabel.text != "Transfer" {
                    
                    view.infoContainer.addArrangedSubview(view.defaultLabel(text: TR("From")))
                    view.infoContainer.addArrangedSubview(view.contractButton(text: "Contract"))
                    view.infoContainer.addArrangedSubview(view.defaultLabel(text: TR("To")))
                    
                    if let toRemark = vm.toRemark.value, toRemark.length > 0  {
                        addTagView(tagName: toRemark)
                    } else {
                        
                        if vm.isLocalData() {
                            view.infoContainer.addArrangedSubview(view.subTitleLabel(text: vm.fromText, textColor: vm.addressColor(address: vm.txInfo.fromAddress)))
                        } else {
                            view.infoContainer.addArrangedSubview(view.subTitleLabel(text: vm.toText, textColor: vm.addressColor(address: vm.txInfo.toAddress)))
                        }
                    }
                    
                } else {
                    defaultTxInfo(vm)
                }
                
            } else {
                if view.functionLabel.text != "Transfer" {
                    view.infoContainer.addArrangedSubview(view.defaultLabel(text: TR("From")))
                    if let remark =  vm.remark.value, remark.length > 0  {
                        addTagView(tagName: remark)
                    } else {
                        view.infoContainer.addArrangedSubview(view.subTitleLabel(text: vm.fromText, textColor: vm.addressColor(address: vm.txInfo.fromAddress)))
                    }
                    view.infoContainer.addArrangedSubview(view.defaultLabel(text: TR("To")))
                    view.infoContainer.addArrangedSubview(view.contractButton(text: "Contract"))
                } else {
                    defaultTxInfo(vm)
                }
            }
        }
        
        private func initStateView(_ vm: CellViewModel) {
            switch vm.txInfo.txState {
            case .pending:
                let pendinglabe = view.stateLabel(text: TR("Token.History.Pending"), state: .pending)
                let waitView = view.waittingView()
                view.stateContainer.addArrangedSubview(pendinglabe)
                view.stateContainer.addArrangedSubview(waitView)
                waitView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16, height: 16).auto())
                }
                waitView.setNeedsLayout()
            case .success:
                view.stateContainer.addArrangedSubview(view.stateLabel(text: TR("Success"), state: .success))
            case .failed:
                view.stateContainer.addArrangedSubview(view.stateLabel(text: TR("Failed"), state: .failed))
                let helpview = view.helpView()
                    helpview.tapBtn.rx.tap.subscribe(onNext: { [weak self](_) in
                    self?.router(event: "Help")
                }).disposed(by: reuseBag)
                view.stateContainer.addArrangedSubview(helpview)
            case .cancel:
                view.stateContainer.addArrangedSubview(view.stateLabel(text: TR("Cancel"), state: .failed))
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? CellViewModel else { return 0}
            return vm.height
        }
    }
}



extension TokenInfoHistoryListBinder {
    class CorssChainCell: FxTableViewCell {
        
        lazy var view = CorssChainView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            
            guard let vm = viewModel as? CellViewModel else { return }
            view.txIcon.image = vm.txIcon
            
            view.fromInfoContainer.removeAll()
            view.fromStateContainer.removeAll()
            view.toInfoContainer.removeAll()
            view.toStateContainer.removeAll()
            
            let chainNames = config(vm.infoType)
            view.crossChainLogo.config(vm.infoType)
            
            view.fromMoneyLabel.text = vm.txInfo.amount.thousandth()
            if let coin = vm.coin {
                view.fromMoneyLabel.text = vm.txInfo.amount.thousandth(coin.decimal) + " \(coin.symbol)"
            }
            
            view.fromInfoContainer.addArrangedSubview(view.defaultLabel(text: TR("From")))
            if let remark =  vm.remark.value, remark.length > 0  {
                addTagView(tagName: remark, tagView: view.fromInfoContainer)
            } else {
                view.fromInfoContainer.addArrangedSubview(view.subTitleLabel(text: vm.fromText, textColor: vm.crossAddressColor(address: vm.txInfo.fromAddress)))
            }
            
            view.fromInfoContainer.addArrangedSubview(view.contractButton(text: chainNames.0))
            view.feeLabel.text = vm.feeText
            view.feeLabel.isHidden = !vm.showFee()
            
            if !vm.showFee() {
                view.bridgeFeeLabel.isHidden = true
                view.fromStateContainer.snp.remakeConstraints { (make) in
                    make.height.equalTo(16.auto())
                    make.left.equalTo(view.fromInfoContainer.snp.left)
                    make.top.equalTo(view.fromInfoContainer.snp.bottom).offset(8.auto())
                }
            } else {
                view.bridgeFeeLabel.isHidden = !vm.txInfo.showBridageFee()
                if vm.txInfo.showBridageFee() {
                    view.bridgeFeeLabel.text = vm.bridgeFeeText
                    
                    view.bridgeFeeLabel.snp.remakeConstraints { (make) in
                        make.height.equalTo(16.auto())
                        make.left.equalTo(view.feeLabel.snp.left)
                        make.top.equalTo(view.feeLabel.snp.bottom).offset(8.auto())
                    }
                    
                    view.fromStateContainer.snp.remakeConstraints { (make) in
                        make.height.equalTo(16.auto())
                        make.left.equalTo(view.feeLabel.snp.left)
                        make.top.equalTo(view.bridgeFeeLabel.snp.bottom).offset(8.auto())
                    }
                } else {
                    view.fromStateContainer.snp.remakeConstraints { (make) in
                        make.height.equalTo(16.auto())
                        make.left.equalTo(view.feeLabel.snp.left)
                        make.top.equalTo(view.feeLabel.snp.bottom).offset(8.auto())
                    }
                }
            }
            
            initStateView(vm, stackViw: view.fromStateContainer)
            
            view.fromTimeLabel.text = vm.dateText
            
            
            view.toMoneyLabel.text = vm.txInfo.amount.thousandth()
            if let coin = vm.coin {
                view.toMoneyLabel.text = vm.txInfo.amount.thousandth(coin.decimal) + " \(coin.symbol)"
            }
            view.toInfoContainer.addArrangedSubview(view.defaultLabel(text: TR("To")))
            
            if let remark =  vm.toRemark.value, remark.length > 0  {
                addTagView(tagName: remark, tagView: view.toInfoContainer)
            } else {
                view.toInfoContainer.addArrangedSubview(view.subTitleLabel(text: vm.toText, textColor: vm.crossAddressColor(address: vm.txInfo.toAddress)))
            }
            
            view.toInfoContainer.addArrangedSubview(view.contractButton(text: chainNames.1))
            initStateView(vm, stackViw: view.toStateContainer)
            view.toTimeLabel.text = vm.dateText
            
            let complateBlock:(([FxTransactionState], Bool) -> Void) = { [weak self](states, rs) in

                guard let this = self else {
                    return
                }
                
                if rs {
                    if let rshx = ChainTransactionServer.shared?.csHash(forKey: vm.txInfo.txHash) {
                        if let crossChain =  vm.txInfo.crossChain {
                            crossChain.transactionHash = rshx
                        }
                    }
                    if states.count >= 2 {
                        this.initStateView(states[0].reslut, stackViw: this.view.fromStateContainer)
                        this.initStateView(states[1].reslut, stackViw: this.view.toStateContainer)
                    }
                    vm.txInfo.state = 1
                    
                    this.view.fromTimeLabel.text = vm.dateText
                    this.view.toTimeLabel.text = vm.dateText
                } else {
                    this.view.fromTimeLabel.text = vm.dateText
                    
                    if states.count >= 2 { 
                        let state = states[0].reslut
                        var state1 = states[1].reslut
                        this.initStateView(state, stackViw: this.view.fromStateContainer)
                        if state == .success && state1 == .empty {
                            state1 = .pending
                        }
                        this.initStateView(state1, stackViw: this.view.toStateContainer)
                    }
                    
                    let fee = states[0].fees
                    if fee.length > 0, fee != "0" {
                        self?.view.feeLabel.text = vm.feeContent(money: fee)
                    }
                }
            }
            
            if let task =  ChainTransactionServer.shared?.txTransaction(chainId: Int(vm.txInfo.chainId),
                                                                        tx: vm.txInfo.txHash, txType: vm.txInfo.txType) {
                task.observeOn(MainScheduler.instance).subscribe(onNext: { (s) in 
                    complateBlock(s.0, s.1)
                    }).disposed(by: reuseBag)
            }else {
                complateBlock([FxTransactionState](), true)
            }
        }
        
        private func config(_ txType: FxTransaction.TxType) -> (String, String) {
            let fx = Node.Chain.functionX.rawValue
            let payc = Node.Chain.fxPayment.rawValue
            let eth = "Ethereum"
            var rs: (String, String) = ("", "")
            if txType == .ethereumToFx || txType == .ethereumToPay {
                rs.0 = eth
            } else if txType == .fxToEthereum || txType == .fxToPay {
                rs.0 = fx
            } else if txType == .payToFx || txType == .payToEthereum {
                rs.0 = payc
            }
            if txType == .fxToEthereum || txType == .payToEthereum {
                rs.1 = eth
            } else if txType == .payToFx || txType == .ethereumToFx {
                rs.1 = fx
            } else if txType == .fxToPay || txType == .ethereumToPay {
                rs.1 = payc
            }
            return rs
        }
        
        
        private func initStateView(_ vm: CellViewModel, stackViw: UIStackView) {
            stackViw.removeAll()
            switch vm.txInfo.txState {
            case .pending:
                let pendinglabe = view.stateLabel(text: TR("Token.History.Pending"), state: .pending)
                let waitView = view.waittingView()
                stackViw.addArrangedSubview(pendinglabe)
                stackViw.addArrangedSubview(waitView)
                waitView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16, height: 16).auto())
                }
                waitView.setNeedsLayout()
            case .success:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Success"), state: .success))
            case .failed:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Failed"), state: .failed))
                let helpview = view.helpView()
                helpview.tapBtn.rx.tap.subscribe(onNext: { [weak self](_) in
                    self?.router(event: "Help")
                }).disposed(by: reuseBag)
                stackViw.addArrangedSubview(helpview)
            case .cancel:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Cancel"), state: .failed))
            }
        }
        
        private func initStateView(_ state: TokenInfoTxInfo.TxState, stackViw: UIStackView) {
            stackViw.removeAll()
            switch state {
            case .pending:
                let pendinglabe = view.stateLabel(text: TR("Token.History.Pending"), state: .pending)
                let waitView = view.waittingView()
                stackViw.addArrangedSubview(pendinglabe)
                stackViw.addArrangedSubview(waitView)
                waitView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16, height: 16).auto())
                }
                waitView.setNeedsLayout()
            case .success:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Success"), state: .success))
            case .failed:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Failed"), state: .failed))
                let helpview = view.helpView()
                helpview.tapBtn.rx.tap.subscribe(onNext: { [weak self](_) in
                    self?.router(event: "Help")
                }).disposed(by: reuseBag)
                stackViw.addArrangedSubview(helpview)
            case .cancel:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Cancel"), state: .failed))
            }
        }
        
        private func initStateView(_ state: FxTransactionState.Result, stackViw: UIStackView) {
            stackViw.removeAll()
            switch state {
            case .pending:
                let pendinglabe = view.stateLabel(text: TR("Token.History.Pending"), state: .pending)
                let waitView = view.waittingView()
                stackViw.addArrangedSubview(pendinglabe)
                stackViw.addArrangedSubview(waitView)
                waitView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 16, height: 16).auto())
                }
                waitView.setNeedsLayout()
            case .success:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Success"), state: .success))
            case .failure:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Failed"), state: .failed))
                let helpview = view.helpView()
                helpview.tapBtn.rx.tap.subscribe(onNext: { [weak self](_) in
                    self?.router(event: "Help")
                }).disposed(by: reuseBag)
                stackViw.addArrangedSubview(helpview)
            case .empty:
                stackViw.addArrangedSubview(view.stateLabel(text: TR("Waiting"), state: .success))
            }
        }
        
        
        private func addTagView(tagName: String, tagView: UIStackView) {
            let markView = view.tagButton(text: tagName)
            tagView.addArrangedSubview(markView)

            markView.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(50)
                make.width.lessThanOrEqualTo(100)
                make.height.equalTo(22.auto())
                make.centerY.equalToSuperview()
            }
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? CellViewModel else { return 0}
            return vm.height
        }
    }
}
