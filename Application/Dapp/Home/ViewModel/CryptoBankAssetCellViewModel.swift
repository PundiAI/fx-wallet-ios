

import WKKit
import RxSwift
import RxCocoa

class CryptoBankAssetCellViewModel {
    
    init(coin: Coin) {
        self.coin = coin
    }
    
    let coin: Coin
    let height: CGFloat = 80.auto()
    lazy var reserveData = AAveReserveData.data(of: coin)
    
    var apy: String {
        
        var v = reserveData.value.value.liquidityRate
        v = v.isZero ? unknownAmount : String(format: "%.2f", v.div10(18 + 7).d)
        return "\(v)%"
    }
}
        


class CryptoBankPurchaseCellViewModel {
    
    init(coin: Coin) {
        self.coin = coin
    }
    
    let coin: Coin
    let height: CGFloat = 80.auto()
}
