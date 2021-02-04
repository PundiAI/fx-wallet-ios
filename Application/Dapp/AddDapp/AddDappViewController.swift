//
//  AddDappsViewController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/25.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension WKWrapper where Base == AddDappViewController {
    var view: AddDappViewController.View { return base.view as! AddDappViewController.View }
}

extension AddDappViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? Wallet else { return nil }
        
        return AddDappViewController(wallet: wallet)
    }
}

class AddDappViewController: WKViewController {
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    private let wallet: Wallet
    private var manager: DappManager { DappManager.manager(forWallet: wallet) }
    
    var dapp: Dapp?
    weak var timer: Timer?
    override func loadView() { self.view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        logWhenDeinit()
        
        bind()
    }
    
    override var preferGadientBackground: Bool { return true }
    
    private func bind() {
        
        navigationBar.isHidden = true
        wk.view.backButton.rx.tap.subscribe(onNext: { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: defaultBag)
        
        wk.view.inputTF.delegate = self
        wk.view.addDAppButton.bind(self, action: #selector(addDapp), forControlEvents: .touchUpInside)
        wk.view.inputTF.rx.text.subscribe(onNext: { [weak self](_) in
            if self?.wk.view.inputTF.text?.isEmpty == true { return }
            
            self?.timer?.invalidate()
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
                self?.addDappIfNeed()
            })
        }).disposed(by: defaultBag)
        
        wk.view.inputTF.becomeFirstResponder()
    }
    
    @objc private func addDapp() {
        guard let addDapp = self.dapp else { return }
        
        for dapp in manager.apps {
            if dapp.id == addDapp.id {
                self.hud?.text(m: TR("AddDapps.AlreadyExists"))
                return
            }
        }
        
        manager.add(addDapp)
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func addDappIfNeed() {
        var urlString = wk.view.inputTF.text ?? ""
        urlString = urlString.trimmed
        guard urlString.isNotEmpty,
            urlString.hasPrefix("http") else {
            wk.view.tipView.isHidden = false
            return
        }
        
        if urlString == self.dapp?.url { return }
        
        let view = wk.view
        view.dappContainer.isHidden = true
        view.refreshView.startAnimating()
        manager.parse(urlString) { [weak self](dapp) in
            DispatchQueue.main.async {
                view.refreshView.stopAnimating()
                
                view.tipView.isHidden = false
                guard let dapp = dapp else { return }
                view.tipView.isHidden = true
                view.inputTFContainer.backgroundColor = .black
                
                view.endEditing(true)
                view.dappContainer.isHidden = false
                view.dappNameLabel.text = dapp.name
                view.dappDescLabel.text = dapp.detail
                view.dappIconIV.setImage(urlString: dapp.icon, placeHolderImage: dapp.placeholderIcon)
                self?.dapp = dapp
            }
        }
    }
}
 
//MARK: UITextFieldDelegate
extension AddDappViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        wk.view.tipView.isHidden = true
        wk.view.inputTFContainer.backgroundColor = HDA(0x303030)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addDappIfNeed()
        return textField.resignFirstResponder()
    }
}
