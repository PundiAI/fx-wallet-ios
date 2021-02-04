//
//  VisitSocialAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2020/12/21.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import Hero
import WKKit
import SwiftyJSON

extension VisitSocialAlertController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let social = context["social"] as? [String: Any] else { return nil }
        
        let vc = VisitSocialAlertController(social: social)
        vc.allowHandler = context["handler"] as? (Bool) -> Void
        return vc
    }
}

class VisitSocialAlertController: FxRegularPopViewController {
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(social: [String: Any]) {
        self.social = JSON(social)
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.bindHero()
    }
    
    let social: JSON
    private var allowHandler: ((Bool) -> Void)?
    
    override func bindListView() {
        
        let social = self.social
        listBinder.push(ContentCell.self) { cell in
            cell.iconIV.setImage(urlString: social["icon"].string, placeHolderImage: IMG("Dapp.Placeholder"))
            cell.nameLabel.text = social["title"].string
            cell.linkLabel.text = social["url"].stringValue
        }
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }
       
    private func bindAction(_ cell: ActionCell) {
       
        weak var welf = self
        cell.cancelButton.action { welf?.dismiss(userCanceled: true) }
        cell.confirmButton.action { welf?.dismiss(userCanceled: false) }
   }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.dismiss(self, animated: animated, completion: { [weak self] in
            self?.allowHandler?(!userCanceled)
        })
    }
    
    override func layoutUI() {
        hideNavBar()
        wk.view.backgroundBlur.isHidden = true
    }
}

//MARK:- hero
extension VisitSocialAlertController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case (_, "VisitSocialAlertController"): return animators["0"]
        default: return nil
        }
    }
    
    private func bindHero() {
        weak var welf = self
        let animator = WKHeroAnimator({ (_) in
            welf?.hero.modalAnimationType = .none
            welf?.wk.view.popAnimation(enabled: true)
        }, onSuspend: { (_) in
            welf?.wk.view.popAnimation(enabled: false)
        })
        self.animators["0"] = animator
    }
}

