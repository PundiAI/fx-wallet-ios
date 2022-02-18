

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension CryptoBankViewController {
    
    class ViewModel {
        
        let wallet: WKWallet
        init(wallet: WKWallet) {
            self.wallet = wallet
        }
        
        lazy var fxStakingVM = FxStakingCellViewModel(wallet: wallet)
        lazy var npxsSwapVM = NPXSSwapCellViewModel(wallet: wallet)
        lazy var delegateVM = DelegateCellViewModel(wallet: wallet)
        lazy var depositVM = DepositCellViewModel(wallet: wallet)
        lazy var purchaseVM = PurchaseCellViewModel(wallet: wallet)
        
        lazy var checkDisplayItems = APIAction(checkDisplayItemsQ)
        
        func refresh() {
            
            fxStakingVM.refresh()
            npxsSwapVM.refresh()
            delegateVM.refresh()
            depositVM.refresh()
            purchaseVM.refresh()
            
            if NodeManager.shared.currentEthereumNode.isMainnet {
                checkDisplayItems.execute()
            }
        }
        
        private var checkDisplayItemsQ: Observable<JSON> {
            return APIManager.fx.searchClientSwitch() 
        }
    }
}
        
