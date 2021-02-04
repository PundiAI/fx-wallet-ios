//
//  AddFunctionXChainInputController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

class AddFunctionXChainInputController: WKViewController {
    
    override func bindNavBar() {
        super.bindNavBar()
        
        weak var welf = self
        navigationBar.hideLine()
        navigationBar.action(.right, imageName: "Menu.Scan"){ welf?.scan() }
        navigationBar.action(.title, title: "Add Chains")
    }
    
    var handler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = HDA(0xe5e5e5)
        self.view.addSubviews([textInputTV, saveButton])
        textInputTV.snp.makeConstraints { (make) in
            make.top.equalTo(FullNavBarHeight + 8.auto())
            make.left.right.equalToSuperview().inset(24.auto())
            make.height.equalTo(120.auto())
        }
        
        saveButton.snp.makeConstraints { (make) in
            make.top.equalTo(textInputTV.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(24.auto())
            make.height.equalTo(50.auto())
        }
        
        saveButton.action { [weak self] in
            self?.save()
        }
    }
    
    @objc func save() {
        let text = textInputTV.text.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        if !text.hasPrefix("http") {
            self.hud?.text(m: "invalid URL")
            return
        }
        
        handler?(text)
        Router.pop(self)
    }
    
    func scan() {
        
        Router.pushToFxScanQRCode { [weak self](text) in
            Router.pop(Router.currentNavigator?.topViewController, animated: false, completion: nil)
            
            self?.textInputTV.text = text
        }
    }
    
    lazy var textInputTV: FxTextView = {
        let v = FxTextView(limit: 200)
        v.width = ScreenWidth - 24.auto()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        
        v.limitLabel.isHidden = true
        
        v.interactor.font = XWallet.Font(ofSize: 16)
        v.interactor.tintColor = COLOR.title
        v.interactor.textColor = COLOR.title
        v.interactor.isScrollEnabled = true
        v.interactor.backgroundColor = .clear
        v.interactor.showsHorizontalScrollIndicator = true
        
        v.placeHolderLabel.font = XWallet.Font(ofSize: 16)
        v.placeHolderLabel.text = "Input or paste the URL here"
        
        v.interactor.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 15, bottom: 4, right: 15))
        }
        
        v.placeHolderLabel.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 18, bottom: 4, right: 10))
        }
        
        return v
    }()
    
    lazy var saveButton: UIButton = {
        let v = UIButton()
        v.title = TR("Save")
        v.bgImage = UIImage.createImageWithColor(color: COLOR.title)
        v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
        v.titleColor = .white
        v.cornerRadius = 25
        return v
    }()
}
