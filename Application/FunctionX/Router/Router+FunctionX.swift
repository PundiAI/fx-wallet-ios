import FunctionX
import RxSwift
import SwiftyJSON
import TrustWalletCore
import WKKit
extension Router {
    static func pushToFxWalletConnect(url: String, wallet: WKWallet) {
        pushViewController("FxWalletConnectViewController", context: ["url": url, "wallet": wallet])
    }

    static func pushToFxCloudWalletConnect(url: String, wallet: Wallet) {
        pushViewController("FxCloudWalletConnectViewController", context: ["url": url, "wallet": wallet])
    }

    static func showDisconnectWalletConnect(confirmHandler: @escaping (Bool) -> Void) {
        presentViewController("WalletConnectDisconnectAlertController", context: ["handler": confirmHandler])
    }

    static func showDisconnectWalletConnect() {
        presentViewController("WalletConnectBeKilledAlertController")
    }

    static func pushToAuthorizeWalletConnect(dapp: Dapp, types: [Int] = [0], account: Keypair? = nil, allowHandler: @escaping (UIViewController?, Bool) -> Void) {
        pushViewController("WalletConnectAuthorizeController", context: ["dapp": dapp, "types": types, "account": account, "handler": allowHandler])
    }

    static func showWalletConnectSign(dapp: Dapp, message: Any, account: Keypair, confirmHandler: @escaping (Bool) -> Void) {
        presentViewController("WalletConnectSignAlertController", context: ["dapp": dapp, "message": message, "account": account, "handler": confirmHandler])
    }

    static func pushToSubmitValidatorAddress(wallet: Wallet, hrp: String, chainName: String, parameter: [String: Any]? = nil, confirmHandler: @escaping ((Keypair) -> Void)) {
        pushViewController("FxCloudSubmitValidatorAddressViewController", context: ["wallet": wallet, "hrp": hrp, "chainName": chainName, "parameter": parameter ?? [:], "handler": confirmHandler])
    }

    static func pushToSubmitValidatorPublicKey(privateKey: PrivateKey, parameter: [String: Any]? = nil) {
        pushViewController("FxCloudSubmitValidatorPublicKeyViewController", context: ["privateKey": privateKey, "parameter": parameter ?? [:]])
    }

    static func pushToSubmitValidatorPublicKeyCompleted(keypair: FunctionXValidatorKeypair) {
        pushViewController("FxCloudSubmitValidatorPublicKeyCompletedViewController", context: ["keypair": keypair])
    }

    static func pushToSubmitValidatorKeypair(wallet: Wallet, hrp: String, chainName: String, parameter: [String: Any]? = nil, confirmHandler: @escaping ((Keypair) -> Void)) {
        pushViewController("FxCloudSubmitValidatorKeypairViewController", context: ["wallet": wallet, "hrp": hrp, "chainName": chainName, "parameter": parameter ?? [:], "handler": confirmHandler])
    }

    static func pushToCreateValidator(hrp: String, chainName: String, txParams: [String: Any], confirmHandler: @escaping () -> Void) {
        pushViewController("FxCloudCreateValidatorViewController", context: ["hrp": hrp, "chainName": chainName, "txParams": txParams, "handler": confirmHandler])
    }

    static func pushToUnjailValidator(tx: FxTransaction, confirmHandler: @escaping () -> Void) {
        pushViewController("FxCloudUnjailValidatorViewController", context: ["tx": tx, "handler": confirmHandler])
    }
}
