import RxCocoa
import RxSwift
import WKKit
extension ResetWalletViewController {
    static var resetWalletMessage: String = TR("ResetWallet.Border.Title")
    class ViewModel {
        init() {
            cellmodel = CellViewModel(TR("ResetWallet.MainTitle"),
                                      TR("ResetWallet.SubTitle"),
                                      TR("ResetWallet.Warnning"))
            tipMessage = TR("ResetWallet.ConfirmTitle")
            checkMessage = resetWalletMessage
        }

        let cellmodel: CellViewModel
        let tipMessage: String
        let checkMessage: String
    }
}
