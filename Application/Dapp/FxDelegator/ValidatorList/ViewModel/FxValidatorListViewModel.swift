//
//
//  XWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension FxValidatorListViewController {
    
    class ListViewModel {
        
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            loadItems()
        }
        
        let wallet: WKWallet
        private var coins: [ValidatorsCellViewModel] = []
        
        var items: [ValidatorsCellViewModel] = []
        let itemCount = BehaviorRelay<Int>(value: 0)
        
        private var refreshBag = DisposeBag()
        
        var isloading: Bool = false
        
        func search(_ input: ControlProperty<String?>) -> Observable<[ValidatorsCellViewModel]> {
            
            return input
                .distinctUntilChanged()
                .flatMap{ [weak self] v -> Observable<[ValidatorsCellViewModel]> in
                    guard let this = self else { return .just([]) }
                    
                    let text = (v ?? "").lowercased()
                    this.items.last?.corners = (false, false)
                    if text.isEmpty {
                        this.items = this.coins
                    } else {
                        this.items = this.coins.filter {
                            $0.rawValue.validatorName.lowercased().contains(text)
                        }
                    }
                    this.items = this.sortIndex(items: this.items)
                    this.items.last?.corners = (false, true)
                    
                    this.itemCount.accept(this.items.count)
                    return .just(this.items)
            }
        }
        
    
        private func loadItems() {
            isloading = true
            APIManager.fx.fetchAllValidators().subscribe(onNext: { [weak self]  json in
                guard let this = self, let jsonArray = json.array else { return }
                this.items = this.sortIndex(items:jsonArray.map { ValidatorsCellViewModel(Validator(json: $0)) })
                this.items.last?.corners = (false, true)
                this.coins = this.items
                this.itemCount.accept(this.items.count)
        
            }, onError: { [weak self](_) in
                self?.itemCount.accept(0)
            }).disposed(by: refreshBag)
        }
        
        private func sortIndex(items: [ValidatorsCellViewModel]) -> [ValidatorsCellViewModel] {
            var temp = [ValidatorsCellViewModel]()
            for (idx, item) in items.enumerated() {
                item.rawValue.index = "\(idx + 1)"
                temp.append(item)
            }
            return temp
        }
    }
}
   


extension FxValidatorListViewController {

    class RightListViewModel {
        
        init(_ wallet: WKWallet) {
            self.wallet = wallet
            loadItems()
        }
        
        let wallet: WKWallet
        private var coins: [ValidatorsCellViewModel] = []
        
        var items: [ValidatorsCellViewModel] = []
        let itemCount = BehaviorRelay<Int>(value: 0)
        
        private var refreshBag = DisposeBag()
        
        func search(_ input: ControlProperty<String?>) -> Observable<[ValidatorsCellViewModel]> {
            
            return input
                .distinctUntilChanged()
                .flatMap{ [weak self] v -> Observable<[ValidatorsCellViewModel]> in
                    guard let this = self else { return .just([]) }
                    
                    let text = (v ?? "").lowercased()
                    this.items.last?.corners = (false, false)
                    if text.isEmpty {
                        this.items = this.coins
                    } else {
                        this.items = this.coins.filter {
                            $0.rawValue.validatorName.lowercased().contains(text)
                        }
                    }
                    this.items = this.sortIndex(items: this.items)
                    this.items.last?.corners = (false, true)
                    
                    this.itemCount.accept(this.items.count)
                    return .just(this.items)
            }
        }
        
        private func loadItems() {
            APIManager.fx.fetchActiveValidators().subscribe(onNext: { [weak self]  json in
                guard let this = self, let jsonArray = json.array else { return }
                this.items = this.sortIndex(items:jsonArray.map { ValidatorsCellViewModel(Validator(json: $0)) })
                this.items.last?.corners = (false, true)
                this.coins = this.items
                this.itemCount.accept(this.items.count)
            }, onError: { [weak self](_) in
                self?.itemCount.accept(0)
            }).disposed(by: refreshBag)
        }
        
        private func sortIndex(items: [ValidatorsCellViewModel]) -> [ValidatorsCellViewModel] {
            var temp = [ValidatorsCellViewModel]()
            for (idx, item) in items.enumerated() {
                item.rawValue.index = "\(idx + 1)"
                temp.append(item)
            }
            return temp
        }
    }
}
