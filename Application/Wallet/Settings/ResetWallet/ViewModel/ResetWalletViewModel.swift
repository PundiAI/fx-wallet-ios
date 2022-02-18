 
import WKKit
import RxSwift
import RxCocoa

extension ResetWalletViewController {
    static var resetWalletMessage:String = TR("RESET MY WALLET")
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
