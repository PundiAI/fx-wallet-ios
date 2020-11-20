//
//  BroadcastTxResultBinder.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import WKKit

private typealias InfoCell = WKTableViewCell.InfoCell
private typealias InfoCellViewModel = WKTableViewCell.InfoCellViewModel

extension BroadcastTxAlertController {
    class ResultBinder {
        let view: ResultView
        init(view: ResultView) { self.view = view }

        var tx: FxTransaction?
        func bind(_ tx: FxTransaction, closeAction: CocoaAction, closeTitle: String? = nil) {
            self.tx = tx
            view.closeButton.rx.action = closeAction
            if tx.isEthereumBusiness {
                bind(ethTx: tx, closeAction: closeAction)
            } else {
                bind(fxTx: tx, closeAction: closeAction, closeTitle: closeTitle)
            }
        }

        func bind(fxTx tx: FxTransaction, closeAction: CocoaAction, closeTitle: String? = nil) {
            view.listView.viewModels = { [weak self] section in
                guard let tx = self?.tx else { return section }

                section.push(ResultTitleCell.self)
                section.push(WKTableViewCell.TitleCell.self) {
                    $0.titleLabel.adjustsFontSizeToFitWidth = true
                    $0.titleLabel.text = "\(tx.amount.fxc.thousandth()) \(tx.token)"
                    if tx.txType == .withdrawDelegatorReward {
                        $0.titleLabel.text = "\(tx.reward.fxc.thousandth()) \(tx.token)"
                    }
                }
                section.push(WKSpacingCell.self, m: WKSpacing(32, 0, .clear))

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Type"), content: tx.txType.description))

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Fee"), content: "\(tx.fee.fxc.thousandth()) \(tx.feeToken)"))

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Timestamp"), content: tx.formatTime))
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
                    if tx.to.isNotEmpty {
                        section.push(InfoCell.self, m: InfoCellViewModel(title: TR("To"), content: tx.to, contentIsLink: true))
                    }
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.from, contentIsLink: true))
                }

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.TXHash"), content: tx.txHash, contentIsLink: true))
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Height"), content: String(tx.txHeight), contentIsLink: true))
                section.push(WKSpacingCell.self, m: WKSpacing(24, 0, .clear))

                section.push(WKTableViewCell.GradientActionCell.self) { cell in
                    cell.submitButton.title = closeTitle != nil ? closeTitle : TR("Done_U")
                    cell.submitButton.rx.action = closeAction
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
            view.listView.didSeletedBlock = { listView, indexPath in

                guard let cell = listView.cellForRow(at: indexPath as IndexPath) as? InfoCell,
                    let vm = cell.viewModel, vm.contentIsLink else { return }

                var path = ""
                if vm.title == TR("BroadcastTx.TXHash") {
                    path = "/#/\(chain)/tx/\(vm.content.string)"
                } else if vm.title == TR("Height") {
                    path = "/#/\(chain)/block/\(vm.content.string)"
                } else if vm.title == TR("From") || vm.title == TR("To") {
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

        func bind(ethTx tx: FxTransaction, closeAction: CocoaAction) {
            view.listView.viewModels = { [weak self] section in
                guard let tx = self?.tx else { return section }

                section.push(ResultTitleCell.self)
                if tx.txType != .depositERC20Approve {
                    let amount = tx.amount.eth
                    section.push(WKTableViewCell.TitleCell.self) {
                        $0.titleLabel.adjustsFontSizeToFitWidth = true
                        $0.titleLabel.text = "\(amount.thousandth()) \(tx.token)"
                    }
                    section.push(ResultUSDCell.self) {
                        $0.usdLabel.appendUSD(forToken: tx.token, amount: amount, placeHolder: "", format: "%@~ %@ USD", disposeBag: $0.reuseBag)
                    }
                    section.push(WKSpacingCell.self, m: WKSpacing(32, 0, .clear))
                }

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Type"), content: tx.txType.description))

                if !tx.isDepositETHBusiness {
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Fee"), content: "\(tx.fee.fxc.thousandth()) \(tx.feeToken)"))
                } else {
                    if tx.txType == .depositERC20Approve {
                        section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.ApproveAmount"), content: TR("BroadcastTx.ApproveUnlimited")))
                        section.push(WKSpacingCell.self, m: WKSpacing(12, 0, .clear))
                    }

                    section.push(InfoCell.self) { cell in
                        let fee = tx.fee.eth
                        cell.bind(InfoCellViewModel(title: TR("Fee"), content: "\(fee.thousandth()) ETH"))
                        cell.contentLabel.appendUSD(forToken: "ETH", amount: fee, disposeBag: cell.reuseBag)
                    }
                }

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("Timestamp"), content: tx.formatTime))
                if tx.to.isNotEmpty {
                    section.push(InfoCell.self, m: InfoCellViewModel(title: TR("To"), content: tx.to, contentIsLink: true))
                }
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("From"), content: tx.from, contentIsLink: true))

                let bridgeContract = FunctionX.shared.bridges.eth.bridgeContractAddress ?? ""
                let contract = tx.contract.isNotEmpty ? tx.contract : bridgeContract
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.EthereumContract"), content: contract, contentIsLink: true))

                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.TXHash") + "\n(ETH)", content: tx.txHash, contentIsLink: true))
                section.push(WKSpacingCell.self, m: WKSpacing(12, 0, .clear))
                section.push(InfoCell.self, m: InfoCellViewModel(title: TR("BroadcastTx.TXHash") + "\n(FX)", content: "--"))

                section.push(WKSpacingCell.self, m: WKSpacing(24, 0, .clear))
                section.push(WKTableViewCell.GradientActionCell.self) { cell in
                    cell.submitButton.title = TR("Done_U")
                    cell.submitButton.rx.action = closeAction
                }

                section.push(WKSpacingCell.self, m: WKSpacing(42, 0, .clear))
                return section
            }

            view.listView.didSeletedBlock = { listView, indexPath in
                guard let cell = listView.cellForRow(at: indexPath as IndexPath) as? InfoCell,
                    let vm = cell.viewModel, vm.contentIsLink else { return }

                if vm.title.hasPrefix(TR("BroadcastTx.TXHash")) {
                    Router.showWebViewController(url: "https://etherscan.io/tx/\(vm.content.string)")
                } else if vm.title == TR("From") || vm.title == TR("To") || vm.title == TR("BroadcastTx.EthereumContract") {
                    let address = vm.content.string
                    if address.hasPrefix("cosmos") {
                        Router.showFxExplorer(path: "/#/peggy/account/\(address)")
                    } else {
                        Router.showWebViewController(url: "https://etherscan.io/address/\(address)")
                    }
                }
            }
        }
    }
}
