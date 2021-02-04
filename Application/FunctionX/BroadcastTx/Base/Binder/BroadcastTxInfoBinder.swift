//
//  BroadcastTxInfoBinder.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import FunctionX

private typealias InfoCell = WKTableViewCell.InfoCell
private typealias InfoCellViewModel = WKTableViewCell.InfoCellViewModel

extension BroadcastTxAlertController {
    class InfoBinder {
        
        let view: InfoView
        init(view: InfoView) { self.view = view }
        
        func bind(_ tx: FxTransaction, closeAction: CocoaAction, confirmAction: CocoaAction) {
            
            view.titleLabel.text = tx.title
            view.closeButton.rx.action = closeAction
            if tx.isEthereumBusiness {
                
                if tx.txType != .depositERC20Approve {
                    bind(ethTx: tx, confirmAction: confirmAction)
                } else {
                    bind(ethApproveTx: tx, confirmAction: confirmAction)
                }
            } else {
                
                if tx.txType == .createValidator {
                    bind(createValidatorTx: tx, confirmAction: confirmAction)
                } else {
                    bind(fxTx: tx, confirmAction: confirmAction)
                }
            }
            
            view.addCorner(view.listView.estimatedHeight)
        }
        
        private func bind(fxTx tx: FxTransaction, confirmAction: CocoaAction) {
            
            view.listView.viewModels = { section in
                
                section.push(WKSpacingCell.self, m: WKSpacing(25, 0, .clear))
                section.push(AmountCell.self) {
                    
                    $0.amountLabel.text = "\(tx.amount.fxc.thousandth(8)) \(tx.token)"
                    $0.typeLabel.text = (tx.isValidatorBusiness || tx.isMsgSend) ? "\(tx.title) amount" :  ""
                    
                    if tx.txType == .withdrawDelegatorReward {
                        
                        $0.typeLabel.text = TR("BroadcastTx.EstimatedReward")
                        $0.amountLabel.text = "\(tx.reward.fxc.thousandth()) \(tx.token)"
                        $0.amountLabel.adjustsFontSizeToFitWidth = true
                    } else if tx.txType == .userRegister {
                        $0.amountLabel.text = tx.registerName
                    }
                }
                section.push(WKSpacingCell.self, m: WKSpacing(tx.isValidatorBusiness ? 32 : 12, 0, .clear))
                
                switch tx.txType {
                    
                case .userRegister: fallthrough
                case .nameAuthorization:
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.from, contentIsLink: true))
                    
                case .undelegate: fallthrough
                case .withdrawDelegatorReward: fallthrough
                case .withdrawValidatorCommission:
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.validator, contentIsLink: true))
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("To"), content: tx.delegator, contentIsLink: true))
                
                default:
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("To"), content: tx.to, contentIsLink: true))
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.from, contentIsLink: true))
                }
                
                if tx.memo.isNotEmpty {
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Memo_U"), content: tx.memo))
                }
                
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("MinerFee"), content: "\(tx.fee.fxc.thousandth()) \(tx.feeToken)"))
                section.push(WKSpacingCell.self, m: WKSpacing(24, 0, .clear))
                
                section.push(WKTableViewCell.GradientActionCell.self) { cell in
                    cell.submitButton.title = (tx.isSmsSend || tx.isMsgSend) ? TR("Confirm_U") : tx.title.uppercased()
                    cell.submitButton.rx.action = confirmAction
                }
                section.push(WKSpacingCell.self, m: WKSpacing(42, 0, .clear))
                return section
            }
            
            
            var chain = "core"
            if tx.txChain == .sms {
                chain = "sms"
            } else if tx.txChain == .order {
                chain = "peggy"
            }
            view.listView.didSeletedBlock = { (listView, indexPath) in
                
                guard let cell = listView.cellForRow(at: indexPath as IndexPath) as? InfoCell,
                    let vm = cell.viewModel, vm.contentIsLink else { return }
                
                var path = ""
                if vm.title == TR("From") || vm.title == TR("To") {
                    
                    if vm.content.string.contains("valoper") {
                        path = "/#/\(chain)/validator/\(vm.content.string)"
                    } else {
                        path = "/#/\(chain)/account/\(vm.content.string)"
                    }
                }
                
                if path.isNotEmpty {
                    Router.showFxExplorer(path: path)
                }
            }
        }
        
        private func bind(createValidatorTx tx: FxTransaction, confirmAction: CocoaAction) {
            
            view.listView.viewModels = { section in
                
                let token = tx.rawValue["denom"].stringValue.uppercased()
                section.push(WKSpacingCell.self, m: WKSpacing(25, 0, .clear))
                section.push(AmountCell.self) {
                    $0.amountLabel.text = "\(tx.amount.fxc.thousandth(8)) \(token)"
                }
                section.push(WKSpacingCell.self, m: WKSpacing(12, 0, .clear))
                
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("To"), content: tx.to))
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.from))
                
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("MinerFee"), content: "\(tx.fee.fxc.thousandth()) \(token)"))
                section.push(WKSpacingCell.self, m: WKSpacing(24, 0, .clear))
                
                section.push(WKTableViewCell.GradientActionCell.self) { cell in
                    cell.submitButton.title = tx.title.uppercased()
                    cell.submitButton.rx.action = confirmAction
                }
                section.push(WKSpacingCell.self, m: WKSpacing(42, 0, .clear))
                return section
            }
        }
        
        private func bind(ethTx tx: FxTransaction, confirmAction: CocoaAction) {
            
            if tx.isDepositETHBusiness {
                let fee = tx.gasPrice.mul(tx.estimatedGas)
                tx.rawValue["fee"] = ["amount": fee, "denom": "eth"]
            }
            view.listView.viewModels = { section in
                
                section.push(WKSpacingCell.self, m: WKSpacing(25, 0, .clear))
                section.push(AmountCell.self) {
                    $0.amountLabel.text = "\(tx.amount.eth.thousandth()) \(tx.token)"
                }
                section.push(WKSpacingCell.self, m: WKSpacing(12, 0, .clear))
                
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("To"), content: tx.to, contentIsLink: true))
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.from, contentIsLink: true))
                
                if tx.memo.isNotEmpty {
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Memo_U"), content: tx.memo))
                }
                if tx.isDepositETHBusiness {
                    
                    section.push(InfoCell.self) { cell in
                        let fee = tx.fee.eth
                        cell.bind(InfoCellViewModel(title: TR("Fee"), content: "\(fee.thousandth()) ETH"))
                        cell.contentLabel.appendUSD(forToken: "ETH", amount: fee, disposeBag: cell.reuseBag)
                    }
                } else {
//                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Fee"), content: "\(tx.fee.fxc.thousandth()) \(tx.feeToken)"))
                }
                
                let bridgeContract = FunctionX.shared.bridges.eth.bridgeContractAddress ?? ""
                let contract = tx.contract.isNotEmpty ? tx.contract : bridgeContract
                section.push(ContractCell.self, m: ContractCellViewModel(title: "", content: contract, contentIsLink: true))
                section.push(WKSpacingCell.self, m: WKSpacing(24, 0, .clear))
                
                section.push(WKTableViewCell.GradientActionCell.self) { cell in
                    cell.submitButton.title = TR("Transfer").uppercased()
                    cell.submitButton.rx.action = confirmAction
                }
                section.push(WKSpacingCell.self, m: WKSpacing(42, 0, .clear))
                return section
            }
            
            view.listView.didSeletedBlock = { (listView, indexPath) in
                
                let cell = listView.cellForRow(at: indexPath as IndexPath)
                if let cell = cell as? ContractCell, let vm = cell.viewModel {
                    Router.showWebViewController(url: "https://etherscan.io/address/\(vm.content.string)")
                } else if let cell = cell as? InfoCell,
                    let vm = cell.viewModel, vm.contentIsLink,
                    (vm.title == TR("From") || vm.title == TR("To")) {
                    
                    let address = vm.content.string
                    if address.hasPrefix("cosmos") {
                        Router.showFxExplorer(path: "/#/peggy/account/\(address)")
                    } else {
                        Router.showWebViewController(url: "https://etherscan.io/address/\(address)")
                    }
                }
            }
        }
        
        private func bind(ethApproveTx tx: FxTransaction, confirmAction: CocoaAction) {
            
            let token = ERC20.token(forContract: tx.contract)
            view.listView.viewModels = { [weak self]section in
                
                section.push(TokenCell.self) {
                    $0.titleLabel.text = TR("BroadcastTx.$Approve$", "Ethereum Cross Chain", (token?.symbol ?? "").uppercased())
                    $0.iconIV.setImage(urlString: token?.icon ?? "", placeHolderImage: IMG("Dapp.Placeholder"))
                }
                section.push(WKSpacingCell.self, m: WKSpacing(12, 0, .clear))
                
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.ApproveAmount"), content: TR("BroadcastTx.ApproveUnlimited")))
                
                section.push(WKSpacingCell.self, m: WKSpacing(12, 0, .clear))
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.ApproveContract"), content: tx.contract, contentIsLink: true))
                
                section.push(FeeCell.self) { self?.bindFee($0, tx: tx) }
                section.push(WKSpacingCell.self, m: WKSpacing(24, 0, .clear))
                
                section.push(WKTableViewCell.GradientActionCell.self) { cell in
                    cell.submitButton.title = TR("Next_U")
                    cell.submitButton.rx.action = confirmAction
                }
                section.push(WKSpacingCell.self, m: WKSpacing(42, 0, .clear))
                return section
            }
            
            view.listView.didSeletedBlock = { (listView, indexPath) in
                guard let cell = listView.cellForRow(at: indexPath as IndexPath) as? InfoCell,
                    let vm = cell.viewModel, vm.contentIsLink else { return }

                if vm.title == TR("BroadcastTx.ApproveContract") {
                    Router.showWebViewController(url: "https://etherscan.io/address/\(vm.content.string)")
                }
            }
        }
        
        private func bindFee(_ cell: FeeCell, tx: FxTransaction) {
            
            var minPrice: Float = 10
            var maxPrice: Float = 100 - minPrice
            let approveGasEstimated = "40000"
            tx.rawValue["fee"] = ["amount": "400000".gwei, "denom": "eth"]
            tx.rawValue["amount"] = ["amount": String(Int64.max).wei, "denom": "eth"]
            tx.rawValue["gas"].string = "90000"
            tx.rawValue["gasPrice"].string = "10".gwei
            
            FunctionX.shared.bridges.eth.gasPrice().subscribe(onNext: { (recommend) in
                
                let recommendPrice = Float(recommend.geth) ?? 0
                if recommendPrice > 0 {
                    
                    minPrice = recommendPrice
                    if recommendPrice <= 100 {
                        maxPrice = 100 - minPrice
                    } else {
                        maxPrice = minPrice * 1.5
                    }
                    cell.sliderView.reactiveValue = cell.sliderView.value
                }
            }).disposed(by: cell.reuseBag)
            
            var rate: String?
            "eth".toUSDT().subscribe(onNext: { rate = $0 }).disposed(by: cell.reuseBag)
            
            cell.sliderView.reactiveValue = 0.1
            cell.sliderView.rx.value.subscribe(onNext: { [weak cell] (percent) in
                
                let price = String(format: "%.2f", minPrice + maxPrice * percent)
                let fee = price.mul(approveGasEstimated)
                cell?.feeLabel.text = "\(fee.geth) ETH"
                cell?.gasLabel.text = "\(price) gwei"
                tx.rawValue["gasPrice"].string = price.gwei
                tx.rawValue["fee", "amount"].string = fee.gwei
                
                if let rate = rate, let text = cell?.feeLabel.text {
                    let usd = fee.geth.mul(rate, 4)
                    cell?.feeLabel.text = text + " (~ \(usd) USD)"
                }
            }).disposed(by: cell.reuseBag)
        }
    }
}


//MARK: ContractCell
extension BroadcastTxAlertController {
    
    class ContractCellViewModel: WKTableViewCell.InfoCellViewModel {
        override var font: UIFont { XWallet.Font(ofSize: 12) }
    }
    
    class ContractCell: WKTableViewCell {
        
        fileprivate lazy var view = ContractItemView(frame: ScreenBounds)
        override class func height(model: Any?) -> CGFloat { return 81 }
        
        var viewModel: ContractCellViewModel?
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? ContractCellViewModel else { return }
            self.viewModel = vm
            
//            view.titleLabel.text = vm.title
            view.contractLabel.attributedText = vm.content
        }
        
        override public func initSubView() {
            layoutUI()
            configuration()
            
            logWhenDeinit()
        }
        
        private func configuration() {
            
            self.backgroundColor = .clear
            self.contentView.backgroundColor = .clear
        }
        
        private func layoutUI() {
            
            self.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}
