//
//  BroadcastTxCommittingBinder.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/28.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import Web3
import WKKit

extension BroadcastTxAlertController {
    class CommittingBinder {
        let view: CommittingView
        init(view: CommittingView) { self.view = view }

        private var fx: FunctionX!
        private var tx: FxTransaction!

        private var timer: Timer?
        private var timeCount = 0
        private let bag = DisposeBag()

        private var commitTxImp: Observable<JSON>?
        weak var commitResultCell: CommittingProgressCell?

        lazy var commitAction = JsonAPIAction { [weak self] (_) -> Observable<JSON> in
            guard let this = self, let tx = self?.tx, let fx = self?.fx else { return Observable.error(WKError.default) }

            let broadcastTx: Observable<JSON>
            if let imp = this.commitTxImp {
                broadcastTx = imp.flatMap { this.format(with: $0) }
            } else {
                switch tx.txType {
                case .delegate: broadcastTx = this.delegate()
                case .undelegate: broadcastTx = this.undelegate()
                case .userRegister: broadcastTx = this.registerUser()
                case .depositERC20: broadcastTx = this.depositERC20()
                case .withdrawERC20: broadcastTx = this.withdrawERC20()
                case .createValidator: broadcastTx = this.createValidator()
                case .depositEthereum: broadcastTx = this.depositEthereum()
                case .withdrawEthereum: broadcastTx = this.withdrawEthereum()
                case .nameAuthorization: broadcastTx = this.nameAuthorize()
                case .depositERC20Approve: broadcastTx = this.approveDepositERC20()
                case .withdrawDelegatorReward: broadcastTx = this.withdrawDelegatorReward()
                case .withdrawValidatorCommission: broadcastTx = this.withdrawValidatorReward()
                default: broadcastTx = this.transfer()
                }
            }

            return broadcastTx.observeOn(MainScheduler.instance)
        }

        func bind(_ tx: FxTransaction, closeAction: CocoaAction, privateKey: PrivateKey, commitTxImp: Observable<JSON>? = nil) {
            self.tx = tx
            fx = FunctionX(wallet: FxWallet(privateKey: privateKey))
            self.commitTxImp = commitTxImp

            view.listView.viewModels = { [weak self] section in

                section.push(WKSpacingCell.self, m: WKSpacing(126, 0, .clear))
                section.push(WKTableViewCell.TitleCell.self) { $0.titleLabel.text = TR("BroadcastTx.CommittingTitle") }
                section.push(WKSpacingCell.self, m: WKSpacing(10, 0, .clear))

                section.push(CommittingDescCell.self)
                section.push(WKSpacingCell.self, m: WKSpacing(20, 0, .clear))

                section.push(CommittingProgressCell.self) { $0.type = .sign; $0.state = .success }
                section.push(CommittingProgressCell.self) { self?.bindCommit($0, tx: tx) }
                section.push(CommittingProgressCell.self) {
                    $0.type = .result
                    $0.state = .waiting
                    self?.commitResultCell = $0
                }

                section.push(WKSpacingCell.self, m: WKSpacing(36, 0, .clear))

                section.push(WKTableViewCell.ActionCell.self) { cell in
                    cell.submitButton.title = TR("Close_U")
                    cell.submitButton.rx.action = closeAction
                }
                section.push(WKSpacingCell.self, m: WKSpacing(64, 0, .clear))
                return section
            }

            let height = WKMTableView.contentHeight(section: view.listView._vModels)
            view.containerView.height = height
            view.containerView.addCorner()
            view.containerView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }

        private func bindCommit(_ cell: CommittingProgressCell, tx _: FxTransaction) {
            view.animationView.startAnimation()

            weak var welf = self
            cell.type = .commit
            cell.state = .executing
            commitAction.executing.subscribe(onNext: { executing in

                welf?.timer?.invalidate()
                if executing {
                    welf?.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                        guard let this = welf else { return }

                        cell.titleLabel.text = TR("BroadcastTx.CommittingP2") + [" |", " /", " -", " \\"][this.timeCount % 4]
                        this.timeCount += 1
                    })
                }
            }).disposed(by: bag)

            commitAction.elements.subscribe(onNext: { _ in
                welf?.timer?.invalidate()
                cell.state = .success
                welf?.commitResultCell?.state = .success
            }).disposed(by: bag)

            commitAction.errors.subscribe(onNext: { _ in
                welf?.timer?.invalidate()
                cell.state = .failed
                welf?.commitResultCell?.state = .failed
            }).disposed(by: bag)
        }

        private func transfer() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.sendTx(to: tx.to, amount: tx.amount, fee: tx.fee, gas: tx.gasLimitInt64, denom: tx.txChain.token).flatMap {
                return self.format(with: $0)
            }
        }

        private func registerUser() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.register(user: tx.registerName, fee: "0", gas: 80000).flatMap {
                return self.format(with: $0)
            }
        }

        private func nameAuthorize() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.authorize(name: tx.authorizeName, chainId: FxChain.sms.id, fee: "0", gas: 80000).flatMap {
                return self.format(with: $0)
            }
        }

        private func delegate() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.delegate(toValidator: tx.validator, amount: tx.amount, fee: tx.fee, gas: tx.gasLimitInt64).flatMap {
                return self.format(with: $0)
            }
        }

        private func undelegate() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.undelegate(fromValidator: tx.validator, amount: tx.amount, fee: tx.fee, gas: tx.gasLimitInt64).flatMap {
                return self.format(with: $0)
            }
        }

        private func withdrawDelegatorReward() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.withdrawReward(fromValidator: tx.validator, fee: tx.fee, gas: tx.gasLimitInt64).flatMap {
                return self.format(with: $0)
            }
        }

        private func withdrawValidatorReward() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            return fx.hub.withdrawValidatorReward(address: tx.validator, fee: tx.fee, gas: tx.gasLimitInt64).flatMap {
                return self.format(with: $0)
            }
        }

        private func depositEthereum() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx,
                let privateKey = try? EthereumPrivateKey(hexPrivateKey: fx.wallet?.privateKey.data.hexString ?? "") else { return Observable.error(WKError.default) }

            let sendTx = fx.bridges.eth.deposit(to: tx.to, amount: BigUInt(tx.amount) ?? 0, gasLimit: BigUInt(tx.gasLimit) ?? 0, gasPrice: BigUInt(tx.gasPrice) ?? 0, privateKey: privateKey)
            return sendTx.flatMap {
                return self.format(with: $0)
            }
        }

        private func approveDepositERC20() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx,
                let privateKey = try? EthereumPrivateKey(hexPrivateKey: fx.wallet?.privateKey.data.hexString ?? "") else { return .error(WKError.default) }

            let sendTx = fx.bridges.eth.approveDepositERC20(from: tx.contract, amount: BigUInt(tx.amount) ?? 0, gasLimit: BigUInt(tx.gasLimit) ?? 90000, gasPrice: BigUInt(tx.gasPrice) ?? 10.gwei, privateKey: privateKey)
            return sendTx.flatMap {
                return self.format(with: $0.0)
            }
        }

        private func depositERC20() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx,
                let privateKey = try? EthereumPrivateKey(hexPrivateKey: fx.wallet?.privateKey.data.hexString ?? "") else { return .error(WKError.default) }

            let sendTx = fx.bridges.eth.depositERC20(from: tx.contract, to: tx.to, amount: BigUInt(tx.amount) ?? 0, gasLimit: BigUInt(tx.gasLimit) ?? 0, gasPrice: BigUInt(tx.gasPrice) ?? 0, privateKey: privateKey)
            return sendTx.flatMap {
                return self.format(with: $0)
            }
        }

        private func withdrawEthereum() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            tx.from = fx.bridges.fx.wallet!.address
            let chainId = Int32(fx.bridges.eth.chainId.quantity)
            let contractAddress = fx.bridges.eth.bridgeContractAddress ?? ""

            let txMsg = TransactionMessage.withdrawEthereum(from: tx.from, to: tx.to, erc20ContractAddress: contractAddress, ethChainId: chainId, amount: tx.amount, symbol: tx.denom, fee: "0", feeDenom: tx.feeDenom, gas: 0)
            return fx.bridges.fx.estimatedFee(ofTx: txMsg).flatMap { t -> Observable<JSON> in

                let (gas, _, fee) = t
                tx.set(fee: fee, denom: FxChain.order.token)
                let sendTx = fx.bridges.fx.withdrawETH(to: tx.to, contractAddress: contractAddress, chainId: chainId, amount: tx.amount, fee: fee, feeSymbol: FxChain.order.token, gas: gas)
                return sendTx.flatMap {
                    return self.format(with: $0)
                }
            }
        }

        private func withdrawERC20() -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            tx.from = fx.bridges.fx.wallet!.address
            let chainId = Int32(fx.bridges.eth.chainId.quantity)
            let txMsg = TransactionMessage.withdrawEthereum(from: tx.from, to: tx.to, erc20ContractAddress: tx.contract, ethChainId: chainId, amount: tx.amount, symbol: tx.denom, fee: "0", feeDenom: tx.feeDenom, gas: 0)
            return fx.bridges.fx.estimatedFee(ofTx: txMsg).flatMap { t -> Observable<JSON> in

                let (gas, _, fee) = t
                tx.set(fee: fee, denom: FxChain.order.token)
                let sendTx = fx.bridges.fx.withdrawERC20(to: tx.to, contractAddress: tx.contract, chainId: chainId, symbol: tx.denom, amount: tx.amount, fee: fee, feeSymbol: FxChain.order.token, gas: gas)
                return sendTx.flatMap {
                    return self.format(with: $0)
                }
            }
        }

        private func createValidator() -> Observable<JSON> {
            guard let tx = self.tx, let wallet = fx.wallet, let nodeUrl = tx.rawValue["nodeUrl"].string else { return Observable.error(WKError.default) }

            let prams = tx.rawValue
            let fee = tx.estimatedGas.mul(tx.gasPrice)
            let node = FxNode(endpoints: FxNode.Endpoints(rpc: nodeUrl), wallet: wallet)
            let sendTx = node.create(validator: prams["validatorAddress"].stringValue,
                                     validatorPublicKey: prams["validatorPublicKey"].stringValue,
                                     delegator: prams["delegatorAddress"].stringValue,
                                     commissionRate: prams["commissionRate"].stringValue,
                                     commissionMaxRate: prams["maxCommissionRate"].stringValue,
                                     commissionMaxChangeRate: prams["maxChangeRate"].stringValue,
                                     details: prams["description"].stringValue,
                                     moniker: prams["name"].stringValue,
                                     website: prams["website"].stringValue,
                                     identity: prams["identity"].stringValue,
                                     securityContact: prams["securityContact"].stringValue,
                                     minSelfDelegation: prams["minSelfDelegation"].stringValue,
                                     amount: prams["delegatorAmount"].stringValue,
                                     fee: fee,
                                     denom: prams["denom"].string ?? "fxc",
                                     chainId: prams["chainId"].stringValue,
                                     gas: tx.gasLimitInt64)

            return sendTx.flatMap {
                return self.format(with: $0, recommendNode: node)
            }
        }

        private func format(with txResult: JSON, recommendNode: FxNode? = nil) -> Observable<JSON> {
            guard let tx = self.tx, let fx = self.fx else { return Observable.error(WKError.default) }

            tx.txHash = txResult["hash"].stringValue
            tx.txHeight = txResult["height"].uInt64Value

            var node: FxNode = fx.hub
            if tx.txChain == .sms {
                node = fx.sms
            } else if tx.txChain == .order {
                node = fx.order
            }
            if let recommendNode = recommendNode {
                node = recommendNode
            }

            let myAddress = node.wallet!.address
            var rewardAmount: String?
            for event in txResult["deliver_tx", "events"].arrayValue {
                if event["type"].stringValue == "transfer" {
                    var attribute = (address: "", reward: "")
                    for att in event["attributes"].arrayValue {
                        if att["key"].stringValue.base64Decoded == "amount" {
                            attribute.reward = att["value"].stringValue.base64Decoded
                        }
                        if att["key"].stringValue.base64Decoded == "recipient" {
                            attribute.address = att["value"].stringValue.base64Decoded
                        }
                    }
                    if attribute.address == fx.hub.wallet!.address {
                        rewardAmount = attribute.reward
                    }
                }

                if rewardAmount != nil {
                    tx.rawValue["reward"].string = rewardAmount!.positiveNumber()
                    break
                }
            }

            let height = txResult["height"].uInt64Value
            return node.block(at: height)
                .catchErrorJustReturn([:])
                .map { block in

                    var response: [String: Any] = [:]
                    let confirmTime = block["block_meta", "header", "time"].stringValue
                    let confirmDate: Date
                    if confirmTime.isNotEmpty {
                        confirmDate = Date(dateString: confirmTime, format: "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: TimeZone(abbreviation: "GMT")!)
                    } else {
                        confirmDate = Date()
                    }

                    let formatDate = confirmDate.format(with: "z YYYY-MM-dd HH:mm:ss")
                    tx.formatTime = formatDate

                    response["name"] = tx.registerName

                    switch tx.txType {
                    case .undelegate: fallthrough
                    case .withdrawDelegatorReward: fallthrough
                    case .withdrawValidatorCommission:
                        response["fromAddress"] = tx.validator
                        response["toAddress"] = tx.delegator

                    default:
                        response["toAddress"] = tx.to
                        response["fromAddress"] = myAddress
                    }

                    response["fee"] = tx.rawValue["fee"].dictionaryObject ?? ["amount": 0, "denom": tx.token]
                    response["hash"] = txResult["hash"].stringValue
                    response["height"] = height
                    response["amount"] = tx.rawValue["amount"].dictionaryObject ?? ["amount": 0, "denom": ""]
                    response["transferType"] = tx.txType.description
                    response["rewardAmount"] = rewardAmount ?? "0 \(FxChain.hub.token.uppercased())"

                    response["time"] = confirmDate.timestamp
                    response["formatTime"] = formatDate
                    return JSON(response)
                }
        }

        private func format(with hash: EthereumData) -> Observable<JSON> {
            guard let tx = self.tx else { return Observable.error(WKError.default) }

            var response: [String: Any] = [:]
            let confirmDate = Date()

            tx.txHash = Data(hash.bytes).hexString
            response["hash"] = tx.txHash
            response["toAddress"] = tx.to
            response["fromAddress"] = tx.from
            response["transferType"] = tx.txType.description

            if tx.isDepositETHBusiness {
                response["fee"] = ["amount": tx.fee, "denom": tx.txChain.token]
            } else {
                response["fee"] = tx.rawValue["fee"].dictionaryObject ?? ["amount": 0, "denom": tx.feeToken]
            }
            response["amount"] = tx.rawValue["amount"].dictionaryObject ?? ["amount": 0, "denom": tx.token]

            let formatDate = confirmDate.format(with: "z YYYY-MM-dd HH:mm:ss")
            tx.formatTime = formatDate
            response["time"] = confirmDate.timestamp
            response["formatTime"] = formatDate
            return Observable.just(JSON(response))
        }
    }
}

// MARK: CommittingProgressCell

extension BroadcastTxAlertController {
    class CommittingProgressCell: WKTableViewCell {
        enum Types {
            case sign
            case commit
            case result
        }

        enum State {
            case waiting
            case executing
            case success
            case failed
        }

        override class func height(model _: Any?) -> CGFloat { return 4 + 23 }

        fileprivate var type = Types.sign {
            didSet {
                switch type {
                case .sign:
                    titleLabel.text = TR("BroadcastTx.CommittingP1")
                case .commit:
                    titleLabel.text = TR("BroadcastTx.CommittingP2")
                case .result:
                    titleLabel.text = TR("BroadcastTx.CommitSuccess")
                }
            }
        }

        fileprivate var state = State.waiting {
            didSet {
                var font = XWallet.Font(ofSize: 14)
                if state == .executing ||
                    (type == .result && (state == .success || state == .failed))
                {
                    font = XWallet.Font(ofSize: 15, weight: .bold)
                }
                titleLabel.font = font
                titleLabel.textColor = state == .waiting ? UIColor.white.withAlphaComponent(0.3) : .white

                if type == .sign { return }
                if state == .success {
                    titleLabel.text = TR(type == .commit ? "BroadcastTx.CommittingP2Success" : "BroadcastTx.CommitSuccess")
                } else if state == .failed {
                    titleLabel.text = TR(type == .commit ? "BroadcastTx.CommittingP2Failed" : "BroadcastTx.CommitFailed")
                    titleLabel.textColor = HDA(0xFA6236)
                }
            }
        }

        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            return v
        }()

        override public func initSubView() {
            layoutUI()
            configuration()

            logWhenDeinit()
        }

        private func configuration() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        private func layoutUI() {
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 18, bottom: 0, right: 18))
            }
        }
    }
}
