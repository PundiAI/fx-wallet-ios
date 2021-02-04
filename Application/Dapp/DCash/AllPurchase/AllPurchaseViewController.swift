//
//  AllPurchaseViewController.swift
//  fxWallet
//
//  Created by Pundix54 on 2021/1/7.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import Foundation
import UIKit
import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == AllPurchaseViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension AllPurchaseViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        return AllPurchaseViewController()
    }
}

class AllPurchaseViewController: WKViewController {
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        bind()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("CryptoBank.All.Purchase"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func bind() {
        let listView = wk.view.listView
        listView.viewModels = { section in
            section.push(TopCell.self) { cell in
                cell.tipButton.isEnabled = false
                cell.tipButton.rx.tap.throttle(.milliseconds(30), scheduler: MainScheduler.instance)
                    .subscribe(onNext: {
                        Router.showWebViewController(url: ThisAPP.WebURL.helpPurchaseURL)
                }).disposed(by: cell.reuseBag)
            }
            
            for coin in RampAssets.shared.assets {
                section.push(ItemContentCell.self) { cell in
                    cell.cView.tokenIV.setImage(urlString: coin.imgUrl, placeHolderImage: coin.imgPlaceholder)
                    cell.cView.tokenLabel.text = coin.token
                    cell.cView.buyButton.rx.tap.subscribe(onNext: { value in
                        Router.showCashBuyController(coin: coin)
                    }).disposed(by: cell.reuseBag)
                }
            }
             
            section.push(BottomCell.self)
            return section
        }
    } 
}
