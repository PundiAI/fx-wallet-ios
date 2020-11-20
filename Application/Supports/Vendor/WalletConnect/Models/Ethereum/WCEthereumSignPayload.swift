// Copyright © 2017-2019 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Web3
import BigInt
import Foundation
import TrustWalletCore

public enum WCEthereumSignPayload {
    case sign(data: Data, raw: [String])
    case personalSign(data: Data, raw: [String])
    case signTypeData(id: Int64, data: Data, raw: [String])
}

extension WCEthereumSignPayload: Decodable {
    private enum Method: String, Decodable {
        case eth_sign
        case personal_sign
        case eth_signTypedData
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case method
        case params
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let method = try container.decode(Method.self, forKey: .method)
        let params = try container.decode([AnyDecodable].self, forKey: .params)
        guard params.count > 1 else { throw WCError.badJSONRPCRequest }
        let strings = params.compactMap { $0.value as? String }
        switch method {
        case .eth_sign:
            self = .sign(data: Data(hex: strings[1]), raw: strings)
        case .personal_sign:
            self = .personalSign(data: Data(hex: strings[0]), raw: strings)
        case .eth_signTypedData:
            let id = try container.decode(Int64.self, forKey: .id)
            let address = params[0].value as? String ?? ""
            if let string = params[1].value as? String,
               let data = string.data(using: .utf8) {
                self = .signTypeData(id: id, data: data, raw: [address, string])
            } else if let dict = params[1].value as? [String: Any] {
                let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                let json = String(data: data, encoding: .utf8) ?? ""
                self = .signTypeData(id: id, data: data, raw: [address, json])
            } else {
                throw WCError.badJSONRPCRequest
            }
        }
    }

    public var data: Data {
        switch self {
        case .sign(let data, _):
            let prefix = "\u{19}Ethereum Signed Message:\n\(data.count)".data(using: .utf8)!
            return prefix + data
        case .personalSign(let data, _):
            let prefix = "\u{19}Ethereum Signed Message:\n\(data.count)".data(using: .utf8)!
            return prefix + data
        case .signTypeData(_, let data, _):
            return data
        }
    }

    public var method: String {
        switch self {
        case .sign: return Method.eth_sign.rawValue
        case .personalSign: return Method.personal_sign.rawValue
        case .signTypeData: return Method.eth_signTypedData.rawValue
        }
    }

    public var message: String {
        switch self {
        case .sign(_, let raw):
            return raw[1]
        case .personalSign(let data, let raw):
            return String(data: data, encoding: .utf8) ?? raw[0]
        case .signTypeData(_, _, let raw):
            return raw[1]
        }
    }
}

struct DappCommand: Decodable {

    enum Method: String, Decodable {
        //case getAccounts
        case sendTransaction
        case signTransaction
        case signPersonalMessage
        case signMessage
        case signTypedMessage
        case unknown

        init(string: String) {
            self = Method(rawValue: string) ?? .unknown
        }
    }

    let name: Method
    let id: Int
    let object: [String: DappCommandObjectValue]
}

struct DappCallback {
    let id: Int
    let value: DappCallbackValue
}

enum DappCallbackValue {
    case signTransaction(Data)
    case sentTransaction(Data)
    case signMessage(Data)
    case signPersonalMessage(Data)
    case signTypedMessage(Data)
}

struct DappCommandObjectValue: Decodable {
    public var value: String = ""
    public var array: [EthTypedData] = []
    public init(from coder: Decoder) throws {
        let container = try coder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = String(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else {
            var arrayContainer = try coder.unkeyedContainer()
            while !arrayContainer.isAtEnd {
                self.array.append(try arrayContainer.decode(EthTypedData.self))
            }
        }
    }
}

enum SolidityJSONValue: Decodable {
    case none
    case bool(value: Bool)
    case string(value: String)
    case address(value: String)

    // we store number in 64 bit integers
    case int(value: Int64)
    case uint(value: UInt64)

    var string: String {
        switch self {
        case .none:
            return ""
        case .bool(let bool):
            return bool ? "true" : "false"
        case .string(let string):
            return string
        case .address(let address):
            return address
        case .uint(let uint):
            return String(uint)
        case .int(let int):
            return String(int)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(value: boolValue)
        } else if let uint = try? container.decode(UInt64.self) {
            self = .uint(value: uint)
        } else if let int = try? container.decode(Int64.self) {
            self = .int(value: int)
        } else if let string = try? container.decode(String.self) {
            if AnyAddress.isValid(string: string, coin: .ethereum) {
                self = .address(value: string)
            } else {
                self = .string(value: string)
            }
        } else {
            self = .none
        }
    }
}

struct EthTypedData: Decodable {
    //for signTypedMessage
    let type: String
    let name: String
    let value: SolidityJSONValue

    var schemaString: String {
        return "\(type) \(name)"
    }

    var schemaData: Data {
        return Data(Array(schemaString.utf8))
    }

    var typedData: Data {
        switch value {
        case .bool(let bool):
            let byte: UInt8 = bool ? 0x01 : 0x00
            return Data([byte])
        case .address(let address):
            let data = Data(hex: String(address.dropFirst(2)))
            return data
        case .uint(let uint):
            if type.starts(with: "bytes") {
                return uint.getHexData()
            }
            let size = parseIntSize(type: type, prefix: "uint")
            guard size > 0 else { return Data() }
            return uint.getTypedData(size: size)
        case .int(let int):
            if type.starts(with: "bytes") {
                return int.getHexData()
            }
            let size = parseIntSize(type: type, prefix: "int")
            guard size > 0 else { return Data() }
            return int.getTypedData(size: size)
        case .string(let string):
            if type.starts(with: "bytes") {
                if string.isHexEncoded {
                    return Data(hex: string)
                }
            } else if type.starts(with: "uint") {
                let size = parseIntSize(type: type, prefix: "uint")
                guard size > 0 else { return Data() }
                if let uint = UInt64(string) {
                    return uint.getTypedData(size: size)
                } else if let bigInt = BigUInt(string) {
                    let hex = try? ABI.encodeParameter(type: .uint256, value: bigInt)
                    return Data(hex: hex ?? "")
                }
            } else if type.starts(with: "int") {
                let size = parseIntSize(type: type, prefix: "int")
                guard size > 0 else { return Data() }
                if let int = Int64(string) {
                    return int.getTypedData(size: size)
                } else if let bigInt = BigInt(string) {
                    let hex = try? ABI.encodeParameter(type: .int256, value: bigInt)
                    return Data(hex: hex ?? "")
                }
            }
            return Data(Array(string.utf8))
        case .none:
            return Data()
        }
    }
}

extension FixedWidthInteger {
    func getHexData() -> Data {
        var string = String(self, radix: 16)
        if string.count % 2 != 0 {
            //pad to even
            string = "0" + string
        }
        let data = Data(hex: string)
        return data
    }

    func getTypedData(size: Int) -> Data {
        var intValue = bigEndian
        var data = Data(buffer: UnsafeBufferPointer(start: &intValue, count: 1))
        let num = size / 8 - 8
        if num > 0 {
            data.insert(contentsOf: [UInt8].init(repeating: 0, count: num), at: 0)
        } else if num < 0 {
            data = data.advanced(by: abs(num))
        }
        return data
    }
}

private func parseIntSize(type: String, prefix: String) -> Int {
    guard type.starts(with: prefix) else {
        return -1
    }
    guard let size = Int(type.dropFirst(prefix.count)) else {
        if type == prefix {
            return 256
        }
        return -1
    }

    if size < 8 || size > 256 || size % 8 != 0 {
        return -1
    }
    return size
}

extension String {

    var isHexEncoded: Bool {
        guard starts(with: "0x") else {
            return false
        }
        let regex = try! NSRegularExpression(pattern: "^0x[0-9A-Fa-f]*$")
        if regex.matches(in: self, range: NSRange(startIndex..., in: self)).isEmpty {
            return false
        }
        return true
    }
}
