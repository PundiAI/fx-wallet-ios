

import WKKit
import RxSwift
import RxCocoa

extension FxStakingOverviewViewController {
    
    class ViewModel: RxObject {
        
        init(wallet: WKWallet, npxs: Coin, fx: Coin) {
            
            self.wallet = wallet
            self.npxsVM = StakingCellViewModel(wallet: wallet, coin: npxs)
            self.fxVM = StakingCellViewModel(wallet: wallet, coin: fx)
            super.init()
            
            Observable.combineLatest(npxsVM.totalRewards, fxVM.totalRewards)
                .subscribe(onNext: { [weak self](v1, v2) in
                    self?.totalRewards.accept(v1.add(v2, fx.decimal))
            }).disposed(by: defaultBag)
        }
        
        let wallet: WKWallet
        
        let fxVM: StakingCellViewModel
        let npxsVM: StakingCellViewModel
        lazy var totalRewards = BehaviorRelay<String>(value: unknownAmount)
        var rewardsCoin: Coin { fxVM.coin }
        
        func filter(coin: Coin) -> Bool { return coin.id == fxVM.coin.id || coin.id == npxsVM.coin.id }
        
        func accept(account: Keypair) {
            if fxVM.account.value.address == account.address { return }
            
            totalRewards.accept(unknownAmount)
            fxVM.accept(account)
            npxsVM.accept(account)
        }
        
        func refreshIfNeed() {
            if npxsVM.account.value.isEmpty { return }
            
            fxVM.refresh()
            npxsVM.refresh()
        }
    }
}
        

extension FxStakingOverviewViewController {
    
    class StakingCellViewModel {
        
        init(wallet: WKWallet, coin: Coin) {
            self.coin = coin
            self.wallet = wallet
        }
        
        let coin: Coin
        let wallet: WKWallet
        lazy var account = BehaviorRelay<Keypair>(value: .empty)
        
        lazy var avaStake = BehaviorRelay<String>(value: unknownAmount)
        lazy var staked = BehaviorRelay<String>(value: unknownAmount)
        lazy var rewards = BehaviorRelay<String>(value: unknownAmount)
        lazy var locked = BehaviorRelay<String>(value: unknownAmount)
        lazy var totalRewards = BehaviorRelay<String>(value: unknownAmount)
        
        lazy var apyText = BehaviorRelay<NSAttributedString?>(value: self.apyText(unknownAmount))
        
        fileprivate func accept(_ account: Keypair) {
            
            self.account.accept(account)
            self.refresh()
        }
        
        private var refreshBag: DisposeBag!
        fileprivate func refresh() {
            refreshBag = DisposeBag()
            
            weak var welf = self
            let address = self.account.value.address
            let balance = wallet.balance(of: address, coin: coin)
            balance.refreshIfNeed()
            balance.value.subscribe(onNext: { value in
                welf?.avaStake.accept(value)
            }).disposed(by: refreshBag)
            
            let bank = FxStaking.current.bank(of: coin)
//            bank.earned(of: address).subscribe(onNext: { value in
//                welf?.rewards.accept(value)
//            }).disposed(by: refreshBag)
            
            bank.balance(of: address, tokenContract: bank.address).subscribe(onNext: { value in
                welf?.staked.accept(value)
            }).disposed(by: refreshBag)
            
            bank.rewardPart(of: address).subscribe(onNext: { value in
                welf?.locked.accept(value.locked)
                welf?.rewards.accept(value.unlocked)
                welf?.totalRewards.accept(value.unlocked.add(value.locked, 18))
            }).disposed(by: refreshBag)
            
            if apyText.value?.string.contains(unknownAmount) == true {
                
                _ = bank.rewardEndTime().subscribe()
                FxStaking.current.apy(of: coin)
                    .subscribe(onNext: { value in welf?.apyText.accept(welf?.apyText(value)) })
                    .disposed(by: refreshBag)
            }
        }
        
        private func apyText(_ rate: String) -> NSAttributedString? {
            
            let text = "\(rate.thousandth(2))% \(TR("APY"))"
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 16, weight: .medium), .foregroundColor: HDA(0x71A800)])
            attText.addAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.5)], range: text.nsRange(of: TR("APY"))!)
            return attText
        }
    }
}
