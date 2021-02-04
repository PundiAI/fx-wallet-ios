//
//  FxCloudWidgetActionViewController.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2020/5/19.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import SwiftyJSON

extension WKWrapper where Base: FxCloudWidgetActionViewController {
    var view: FxCloudWidgetActionViewController.View { return base.view as! FxCloudWidgetActionViewController.View }
}

class FxCloudWidgetActionViewController: WKViewController {
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(hrp: String, chainName: String) {
        self.hrp = hrp
        self.chainName = chainName
        super.init(nibName: nil, bundle: nil)
    }
    
    let hrp: String
    let chainName: String
    var parameter: JSON?
    
    override var preferFullTransparentNavBar: Bool { true }
    override func loadView() { self.view = getView() }
    func getView() -> View { View(frame: ScreenBounds) }
    
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration()
        logWhenDeinit()
        
        bindList()
        bindAction()
        
        
    }
    
    var titleText: String { "" }
    var subtitleText: String { "" }
    func bindList() {
        
        weak var welf = self
        wk.view.listView.isScrollEnabled = false
        listBinder.push(TitleCell.self, vm: parameter?["doc", "title"].string ?? titleText)
        if subtitleText.isNotEmpty { listBinder.push(SubtitleCell.self, vm: subtitleText) }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(30, 0, .clear))
        listBinder.push(BlockchainInfoCell.self) { cell in
            cell.chainHrpLabel.text = welf?.hrp ?? ""
            cell.chainNameLabel.text = welf?.chainName ?? ""
        }
    }
    
    func bindAction() {}
    
    func configuration() {}
}

