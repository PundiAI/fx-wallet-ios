//
//  ERC20ToFxTransferAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/6/7.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import Macaw

extension ERC20ToFxTransferAlertController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let coin = context["coin"] as? Coin,
              let account = context["account"] as? Keypair,
              let wallet = context["wallet"] as? WKWallet else { return nil }
        
        return ERC20ToFxTransferAlertController(wallet: wallet, coin: coin, account: account)
    }
}

class ERC20ToFxTransferAlertController: FxPopViewController {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin, account: Keypair) {
        self.coin = coin
        self.wallet = wallet
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    let coin: Coin
    let wallet: WKWallet
    let account: Keypair
    
    override func getView() -> FxPopViewController.BaseView {
        super.getView().then {
            _ = $0.mainView.backgroundColor(Color.white)
                .border(Color.clear, 0)
        }
    }
    
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let erc20FxBalance = wallet.balance(of: account.address, coin: coin).value.value
        listBinder.push(ContentCell.self) {
            $0.ethereumBalanceLabel.text = erc20FxBalance.div10(self.coin.decimal).thousandth(autoTrim: false)
        }
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            self?.pushToCrossChainTransfer()
        }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: PopBottom))
        
        let contentHeight = wk.view.navBarHeight + listBinder.estimatedHeight
        wk.view.mainView.snp.remakeConstraints { (make) in
            make.height.equalTo(contentHeight)
            make.bottom.left.right.equalToSuperview()
        }
        
        wk.view.listView.snp.remakeConstraints { (make) in
            make.top.equalTo(wk.view.navBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self)
    }
    
    private func pushToCrossChainTransfer() {
        
        let tx = FxTransaction([:])
        let amount = wallet.balance(of: account.address, coin: coin).value.value
  
        tx.coin = coin
        tx.from = account.address
        tx.set(amount: amount, denom: coin.symbol)
        Router.pushToSendTokenCommit(tx: tx, wallet: wallet, account: account) { [weak self]_ in
            Router.currentNavigator?.remove([self])
        }
    }
    
    override func layoutUI() {
        super.layoutUI()
        wk.view.navBar.backButton.image = IMG("Menu.Close")
        wk.view.navBar.backButton.tintColor = COLOR.title
    }
}

extension ERC20ToFxTransferAlertController {
    class ContentCell: FxTableViewCell {
        
        lazy var iconIV = UIImageView(image: IMG("SendToken.CrossChain")?.reRender(color: .white))
        lazy var iconIVBackground = UIView(COLOR.title, cornerRadius: 24)
        private lazy var titleLabel = UILabel(text: TR("SmartCS.Title"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: COLOR.title, alignment: .center)
        fileprivate lazy var descLabel = UILabel(text: TR("SmartCS.Desc"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, lines: 0, alignment: .center)
        
        private lazy var ethereumContainer = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        private lazy var ethereumTitleLabel = UILabel(text: "Ethereum", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white, alignment: .center, bgColor: COLOR.title)
        private lazy var ethereumBalanceTLabel = UILabel(text: TR("$Balance", Coin.ERC20FxSymbol), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center)
        lazy var ethereumBalanceLabel = UILabel(text: "0", font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 2, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrowCS"))
        
        private lazy var fxContainer = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        private lazy var fxTitleLabel = UILabel(text: Node.Chain.functionX.rawValue, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: .white, alignment: .center, bgColor: COLOR.title)
        private lazy var fxBalanceTLabel = UILabel(text: TR("$Balance", Coin.ERC20FxSymbol), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle, alignment: .center)
        lazy var fxBalanceLabel = UILabel(text: unknownAmount, font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title, lines: 2, alignment: .center).then{ $0.adjustsFontSizeToFitWidth = true }
        
        override class func height(model: Any?) -> CGFloat {
            let textString = TR("SmartCS.Desc")
            let descHeight = textString.height(ofWidth: ScreenWidth - 24.auto() * 2, attributes: [.font: XWallet.Font(ofSize: 14)])
            let height = 274.auto() + descHeight
            return height
        }
        
        override func layoutUI() {
            contentView.backgroundColor = UIColor.yellow
            contentView.addSubviews([iconIVBackground, iconIV, titleLabel, descLabel, ethereumContainer, fxContainer, arrowIV])
            fxContainer.addSubviews([fxTitleLabel, fxBalanceTLabel, fxBalanceLabel])
            ethereumContainer.addSubviews([ethereumTitleLabel, ethereumBalanceTLabel, ethereumBalanceLabel])
            
            iconIVBackground.snp.makeConstraints { (make) in
                make.top.equalTo(0)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            iconIV.snp.makeConstraints { (make) in
                make.center.equalTo(iconIVBackground)
                make.size.equalTo(CGSize(width: 20, height: 20).auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(iconIVBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(29.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }

            let size = CGSize(width: (ScreenWidth - 48.auto() - 48.auto()) * 0.5, height: 124.auto())
            ethereumContainer.snp.makeConstraints { (make) in
                make.top.equalTo(descLabel.snp.bottom).offset(40.auto())
                make.left.equalTo(24.auto())
                make.size.equalTo(size)
            }
            
            ethereumTitleLabel.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40.auto())
            }
            
            ethereumBalanceTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(ethereumTitleLabel.snp.bottom).offset(12.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            ethereumBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(ethereumBalanceTLabel.snp.bottom).offset(2.auto())
                make.left.right.equalToSuperview().inset(10.auto())
            }
            
            fxContainer.snp.makeConstraints { (make) in
                make.top.equalTo(descLabel.snp.bottom).offset(40.auto())
                make.right.equalTo(-24.auto())
                make.size.equalTo(size)
            }
            
            fxTitleLabel.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40.auto())
            }
            
            fxBalanceTLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxTitleLabel.snp.bottom).offset(12.auto())
                make.left.right.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            fxBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(fxBalanceTLabel.snp.bottom).offset(2.auto())
                make.left.right.equalToSuperview().inset(10.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(ethereumContainer)
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
        }
    }
}

extension ERC20ToFxTransferAlertController {
    class ActionCell: WKTableViewCell.ActionCell {
        
        override func configuration() {
            super.configuration()
            submitButton.bgImage = UIImage.createImageWithColor(color: COLOR.title)
            submitButton.titleColor = .white
            submitButton.title = TR("GoToTransfer")
        }
    }
}
