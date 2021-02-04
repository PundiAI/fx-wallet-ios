//
//  ChatListViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/3/9.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit
import RxSwift
import FunctionX
import TrustWalletCore

extension WKWrapper where Base == ChatListViewController {
    var view: ChatListViewController.View { return base.view as! ChatListViewController.View }
}

extension ChatListViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        guard let privateKey = context["privateKey"] as? PrivateKey else { return nil }
        
        return ChatListViewController(privateKey: privateKey)
    }
}

extension Router {
    
    func pushToTestChatListVC() {
        
        let receiver = SmsUser()
        receiver.name = "kzxn0"
        receiver.address = "cosmos1g7sn2yy3ph8669fdy8u08gnpdqf2z8708kzxn0"
        receiver.chatRoomId = "032b5b61cd8fee2f95f02ec09a7a51f9f9108ac6851e9514346c77465bba52f7"
        receiver.publicKey = Data(hex: "0263dbe2da50ec7272eb93b15b675499a6e570548944cecb8e98ee4b2cbd6889e9")
        
        let wallet = FxWallet(privateKey: PrivateKey(data: Data(hex: "8de0357fdbcc3ee3ab44930557a75c3abb5d296acb0f95fbb0374591d6ddf7ab"))!)
        Router.pushToChatList(privateKey: wallet.privateKey)
    }
}


class ChatListViewController: WKViewController {
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(privateKey: PrivateKey) {
        self.viewModel = ViewModel(privateKey)
        super.init(nibName: nil, bundle: nil)
    }
    
    let viewModel: ViewModel
    fileprivate lazy var listBinder = WKTableViewBinder<CellViewModel>(view: wk.view.listView)
    
    override func loadView() { self.view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bindList()
        bindNavBar()
        bindListHeader()
        
        fetchData()
    }
    
    private func fetchData() {
        
        listBinder.refresh()
        viewModel.fetchName.execute()
    }
    
    private func bindNavBar() {
        
        navigationBar.isHidden = true
        weak var welf = self
        wk.view.navBar.backButton.rx.tap.subscribe(onNext: { (_) in
            welf?.navigationController?.popViewController(animated: true)
        }).disposed(by: defaultBag)
        
        wk.view.newMessageButton.rx.tap.subscribe(onNext: { (_) in
            welf?.presentNewChat()
        }).disposed(by: defaultBag)
    }
    
    private func bindList() {
        
        let listView = wk.view.listView

        weak var welf = self
        listView.viewModels = { _ in NSMutableArray.viewModels(from: welf?.viewModel.items, Cell.self) }
        listView.didSeletedBlock = { (_, indedPath) in
            guard let this = welf else { return }

            this.viewModel.items[indedPath.row].readToEnd()
            let receiver = this.viewModel.items[indedPath.row].rawValue
            Router.pushToChat(receiver: receiver, wallet: this.viewModel.wallet)
        }
        
        viewModel.needReload
            .delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in listView.reloadData() })
            .disposed(by: defaultBag)
        
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { (_) in
                welf?.viewModel.items.each{ $0.updateUnreadCountIfNeed() }
        }).disposed(by: defaultBag)

        listBinder.bindListError = {}
        listBinder.bindListFooter = {}
        listBinder.bind(viewModel)
    }
    
    private func bindListHeader() {
        
        weak var welf = self
        viewModel.fetchName.elements.subscribe(onNext: { (name) in
            
            welf?.wk.view.nameLabel.text = name
            welf?.wk.view.avatarIV.set(text: name)
        }).disposed(by: defaultBag)
        
        wk.view.addressButton.title = viewModel.address
        wk.view.addressButton.setTitlePosition(.left, for: .normal, withAdditionalSpacing: 10)
        wk.view.addressButton.rx.tap.subscribe(onNext: { (_) in
            welf?.hud?.text(m: TR("Copied"))
            UIPasteboard.general.string = welf?.viewModel.address
        }).disposed(by: defaultBag)
    }
    
    private func presentNewChat() {
        
        Router.presentNewChat(wallet: viewModel.wallet) { [weak self] in
            self?.listBinder.refresh()
        }
    }
}
