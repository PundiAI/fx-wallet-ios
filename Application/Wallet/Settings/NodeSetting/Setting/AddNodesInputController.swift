//
//  AddFunctionXChainInputController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/1/19.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit

 
extension AddNodesInputController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let handler = context["handler"] as? ((String) -> Void) else { return nil }
        let vc = AddNodesInputController(handler: handler)
        return vc
    }
}

class AddNodesInputController: WKViewController {
    override var preferFullTransparentNavBar: Bool { true }
    override var interactivePopIsEnabled: Bool { false }
    
    init(handler:@escaping ((String) -> Void)) {
        self.handler = handler
        super.init(nibName: nil, bundle: nil)
        self.bindHero()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 18)
        v.textColor = COLOR.title
        v.numberOfLines = 0
        v.autoFont = true
        v.text = TR("URL")
        v.backgroundColor = .clear
        return v
    }()
    
    lazy var subTitleLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 14)
        v.textColor = COLOR.subtitle
        v.numberOfLines = 0
        v.autoFont = true
        v.text = TR("Only Function X Chain supported currently")
        v.backgroundColor = .clear
        return v
    }()
    
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
        v.title = TR("Button.Save")
        v.bgImage = UIImage.createImageWithColor(color: COLOR.title)
        v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
        v.titleColor = .white
        v.cornerRadius = 25
        return v
    }()
    
    override func navigationItems(_ navigationBar: WKNavigationBar) {
        weak var welf = self
        navigationBar.action(.right, imageName: "Menu.Scan"){ welf?.scan() }
        navigationBar.action(.title, title: TR("Setting.Newtrok.Add.Title"))
        navigationBar.action(.left, imageName: "ic_close_white") {
            Router.pop(self)
        }
    }
    
    var handler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = HDA(0xe5e5e5)
        self.view.addSubviews([titleLabel, subTitleLabel, textInputTV, saveButton])
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(FullNavBarHeight + 20.auto())
            make.left.right.equalToSuperview().inset(24.auto())
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5.auto())
            make.left.right.equalToSuperview().inset(24.auto())
        }
        
        textInputTV.snp.makeConstraints { (make) in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(10.auto())
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
}


// MARK:- Hero Animator
extension AddNodesInputController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "AddNodesInputController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        animators["0"] = WKHeroAnimator.Share.pageIn()
    }
}
