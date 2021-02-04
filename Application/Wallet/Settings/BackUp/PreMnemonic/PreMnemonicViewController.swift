//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == PreMnemonicViewController {
    var view: PreMnemonicViewController.View { return base.view as! PreMnemonicViewController.View }
}

extension PreMnemonicViewController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let mnemonic = context["mnemonic"] as? String else { return nil }
        let vc = PreMnemonicViewController(mnemonic: mnemonic)
        return vc
    }
}

class PreMnemonicViewController: WKViewController {
    let mnemonic: String
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(mnemonic: String) {
        self.mnemonic = mnemonic
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
        
        
        XEvent.App.ApplicationUserDidTakeScreenshot.on {[weak self] (_) in
            let title = TR("PreMnemonic.Alert.Title")
            let message = TR("PreMnemonic.Alert.SubTitle")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: TR("Button.OK"), style: .default, handler: { (_) in
                 
            }))
            self?.present(alertController, animated: true, completion: nil)
        }.disposed(by: defaultBag)
    }
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindList()
        bindAction()
        logWhenDeinit()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("PreMnemonic.Title"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindNavBar()
    }
    
    
    private func bindList() {
        wk.view.backgroundColor = .white
        listBinder.view.backgroundColor = .white
        
        listBinder.push(Cell.self, vm: BackUpNoticeViewController.CellViewModel(TR("PreMnemonic.MainTitle"),
                                                                                TR("PreMnemonic.SubTitle")))
        
        let tags = mnemonic.split(separator: " ")
        var temp: [String] = []
        for tag in tags {
            temp.append(String(tag))
        }
        listBinder.push(TagsCell.self, vm: temp)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(54.auto(), 0, .white))
    }
    
    private func bindAction() {
        wk.view.startButton.action { [weak self] in
            guard let weakself = self else { return }
            Router.pushToCheckBackUp(mnemonic: weakself.mnemonic)
        }
    }
}

/// Hero
extension PreMnemonicViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? { 
        switch (from, to) {
        case (_, "PreMnemonicViewController"): return animators["0"]
        case ("PreMnemonicViewController","CheckBackUpViewController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        animators["0"] = WKHeroAnimator.Share.push()
    }
}
