
import RxCocoa
import RxSwift
import Web3
import WKKit

typealias TokenModel = SwapViewController.TokenModel
typealias RouterModel = SwapViewController.RouterModel
typealias ApprovedListModel = SwapViewController.ApprovedListModel
typealias ApprovedModel = SwapViewController.ApprovedModel
extension SwapViewController {
    class TokenModel {
        let account: Keypair?
        var token: Coin?
        init(token: Coin?, account: Keypair?) {
            self.account = account
            self.token = token
        }
    }

    class RouterModel {
        var token: String = ""
        var address: EthereumAddress
        init(address: EthereumAddress, token: String) {
            self.address = address
            self.token = token
        }

        var path: String {
            return "https:--"
        }
    }

    class ApprovedModel: NSObject {
        var token: String = ""
        var amount: String = "0"
        var txHash: String = ""
        var coin: Coin
        init(token: String, amount: String, txHash: String, coin: Coin) {
            self.amount = amount
            self.token = token
            self.txHash = txHash
            self.coin = coin
        }
    }

    class ApprovedListModel {
        var items: [ApprovedModel] = []
        func add(item: ApprovedModel) {
            if let _item = items.find(condition: { $0.token == item.token }) {
                _item.amount = item.amount
                _item.txHash = item.txHash
            } else {
                items.append(item)
            }
        }

        func get(_ token: String) -> ApprovedModel? {
            return items.find(condition: { $0.token == token })
        }

        func remove(_ token: String) {
            if let item = items.find(condition: { $0.token == token }) {
                items.remove(element: item)
            }
        }
    }
}
