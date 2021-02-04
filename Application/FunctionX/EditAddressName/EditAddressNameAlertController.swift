//
//  EditAddressNameAlertController.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/2/26.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension EditAddressNameAlertController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        
        let vc = EditAddressNameAlertController()
        vc.address = context["address"] as? String ?? ""
        if let completionHandler = context["handler"] as? (String) -> () {
            vc.didComplateBlock = completionHandler
        }
        return vc
    }
}

class EditAddressNameAlertController: WKPopViewController {
    
    var address = ""
    let viewS = View(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 285))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutUI()
        configuration()
        logWhenDeinit()
        
        bindUI()
        bindKeyboard()
        
        self.view.layoutIfNeeded()
        viewS.inputTF.becomeFirstResponder()
    }
    
    private func bindUI() {
        
        viewS.inputTF.text = UserDefaults.standard.remark(ofAddress: self.address)
        viewS.addressLabel.text = self.address
        viewS.confirmButton.isEnabled = false
        
        weak var welf = self
        viewS.inputTF.rx.text.distinctUntilChanged().subscribe(onNext: { (value) in
            
            let text = value ?? ""
            if text.isNotEmpty { welf?.viewS.confirmButton.isEnabled = true }
            if text.count >= 40 {
                welf?.viewS.inputTF.text = text.substring(to: 39)
            }
        }).disposed(by: defaultBag)
        
        viewS.backButton.rx.tap.subscribe(onNext: { (_) in
            welf?.view.endEditing(true)
            welf?.contentView.isHidden = true
            welf?.dismiss(animated: true, completion: nil)
        }).disposed(by: defaultBag)
        
        viewS.confirmButton.rx.tap.subscribe(onNext: { (_) in
            welf?.didComplateBlock?(welf?.viewS.inputTF.text ?? "")
            welf?.dismiss(animated: true, completion: nil)
        }).disposed(by: defaultBag)
    }
    
    private func bindKeyboard() {
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self,
                    this.presentedViewController == nil else { return }
                
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y
                
                this.contentView.snp.updateConstraints( { (make) in
                    make.bottom.equalTo(this.view).offset(-margin)
                })
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
    }
    
    //MARK: Utils
    private func configuration() {
        
        transitioning.alertType = .sheet
        transitioningDelegate = transitioning
        contentView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
    }
    
    private func layoutUI() {
        
        backgroundView.gradientBGLayerForPop.frame = ScreenBounds
        
        self.contentView.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.right.equalTo(view)
            make.height.equalTo(viewS.height)
        }

        contentView.addSubview(viewS)
        viewS.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
