// Copyright © 2017-2019 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Web3

public struct WCEthereumTransaction: Codable {
    public let from: String
    public let to: String?
    public let nonce: String?
    public let gasPrice: String?
    public let gas: String?
    public let gasLimit: String?
    public let value: String?
    public let data: String

    var gasValue: String? { gas ?? gasLimit }
}

extension WCEthereumTransaction {
    var tx: EthereumTransaction {

        let to = self.to != nil ? EthereumAddress(hexString: self.to!) : nil
        return EthereumTransaction(nonce: nonce?.quantity(),
                                   gasPrice: gasPrice?.quantity(),
                                   gas: gasValue?.quantity(),
                                   from: EthereumAddress(hexString: from),
                                   to: to,
                                   value: value?.quantity() ?? EthereumQuantity(quantity: 0),
                                   data: EthereumData(bytes: Data(hex: data).bytes))
    }
}
