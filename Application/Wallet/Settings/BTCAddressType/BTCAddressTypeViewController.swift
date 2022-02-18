//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua
//  Copyright © 2017 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore

extension WKWrapper where Base == BTCAddressTypeViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension BTCAddressTypeViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        return BTCAddressTypeViewController(wallet: wallet)
    }
}

class BTCAddressTypeViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    let wallet: WKWallet
    
    private var current: Cell?
    private lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindListView()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Setting.ToggleBTCAddressType"))
    }
    
    private func bindListView() {
        
        listBinder.push(Cell.self){ self.bind(cell: $0, purpose: .bip44) }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(Cell.self){ self.bind(cell: $0, purpose: .bip49) }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: 24.auto()))
        listBinder.push(Cell.self){ self.bind(cell: $0, purpose: .bip84) }
        
        listBinder.didSeletedBlock = { [weak self](_,_,cell) in
            guard let cell = cell as? Cell else { return }
            
            if let purpose = cell.purpose,
               purpose != XWallet.BTCPurpose {
                
                self?.select(cell: cell)
                XWallet.reset(btcPurpose: purpose)
                if self?.hasBTC == true {
                    Router.resetRootController(wallet: self?.wallet.rawValue, animated: true)
                } else {
                    Router.pop(self)
                }
            }
        }
    }
    
    private func bind(cell: Cell, purpose: Purpose) {
        
        var path = ""
        cell.purpose = purpose
        switch purpose {
        case .bip44:
            path = "m/44'/0'/0'/0/0"
            cell.pathLabel.text = path
            cell.titleLabel.text = TR("ToggleBTCAddressType.P2PKH")
        case .bip84:
            path = "m/84'/0'/0'/0/0"
            cell.pathLabel.text = path
            cell.titleLabel.text = TR("ToggleBTCAddressType.P2WSH")
        default:
            path = "m/49'/0'/0'/0/0"
            cell.pathLabel.text = path
            cell.titleLabel.text = TR("ToggleBTCAddressType.P2SH")
        }
        
        if let hdWallet = wallet.hd, path.count > 0 {
            
            let privateKey = hdWallet.getKey(derivationPath: path)
            let address = BitcoinAddress.address(forPublicKey: privateKey.getPublicKeySecp256k1(compressed: false), purpose: purpose) ?? ""
            cell.addressLabel.text = address
        }
        
        if purpose == XWallet.BTCPurpose {
            select(cell: cell)
        }
    }
    
    private func select(cell: Cell) {
        current?.checkIV.isHidden = true
        current = cell
        current?.checkIV.isHidden = false
    }
    
    private var hasBTC: Bool {
        
        var hasBTC = false
        if let btc = CoinService.current.btc {
            hasBTC = wallet.coinManager.has(btc)
        }
        return hasBTC
    }
}
        
