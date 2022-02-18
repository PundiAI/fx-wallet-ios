//
//  CryptoBankHomeFxStakingCellViewModel.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/3/8.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension CryptoBankViewController {
    
    class FxStakingCellViewModel {
        
        init(wallet: WKWallet) {
            self.wallet = wallet
        }
        
        let wallet: WKWallet
        var display:Bool {
            if Node.Current(.ethereum).isKovan { return false }
            return ThisAPP.AuthPath.fxPundixStakingDisplay
        }
        
        var npxs: Coin { return CoinService.current.coin(forId: "\(Coin.FxSwapSymbol)_60") ?? .empty }
        var fx: Coin { return CoinService.current.coin(forId: "fx_60") ?? .empty }
        
        lazy var fxAPYText = BehaviorRelay<NSAttributedString?>(value: apyText(unknownAmount))
        lazy var npxsAPYText = BehaviorRelay<NSAttributedString?>(value: apyText(unknownAmount))
        
        func refresh() {
            guard display else { return }
            
            weak var welf = self
            let staking = FxStaking.current
            _ = staking.apy(of: fx).subscribe(onNext: { value in welf?.fxAPYText.accept(welf?.apyText(value)) })
            _ = staking.apy(of: npxs).subscribe(onNext: { value in welf?.npxsAPYText.accept(welf?.apyText(value)) })
        }
        
        private func apyText(_ rate: String) -> NSAttributedString? {
            let text = "\(rate.thousandth(2))% \(TR("APY"))"
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 16), .foregroundColor: HDA(0x71A800)])
            attText.addAttributes([.foregroundColor: COLOR.subtitle], range: text.nsRange(of: TR("APY"))!)
            return attText
        }
        
        lazy var height: CGFloat = {
            
            let descHeight = TR("FxStaking.Desc").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let titleHeight = 62.auto() + descHeight
            return 24.auto() + titleHeight + 220.auto()
        }()
    }
}
