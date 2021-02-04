//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import pop
import SnapKit
import RxSwift 
import SwipeCellKit
import RxCocoa


extension NotificationPanelViewController {
    class View: UIView {
        var rootView:TokenRootViewController.View? {
            return self.superview as? TokenRootViewController.View
        }
        
        var isAnimating:Bool = false
        var headHeight: CGFloat {
            return NotificationPanelViewController.minContentHeight - 10.auto()
        }
         
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
            $0.backgroundColor = HDA(0xF4F4F4).withAlphaComponent(0.88)
        }
 
        var headerView = ListHeaderView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        lazy var expandButton = UIButton()
        lazy var listView: UICollectionView = {
            let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: foldLayout)
            v.backgroundColor = UIColor.clear
            v.contentInsetAdjustmentBehavior = .never
            v.alwaysBounceVertical = true
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        let foldLayout: NotificationFoldLayout
        let hideLayout: NotificationHideLayout
        let expandLayout: NotificationExpandLayout
        init(foldLayout: NotificationFoldLayout, expandLayout: NotificationExpandLayout, hideLayout:NotificationHideLayout) {
            self.foldLayout = foldLayout
            self.expandLayout = expandLayout
            self.hideLayout = hideLayout
            super.init(frame: ScreenBounds)
            self.logWhenDeinit()
            
            self.layoutUI()
            self.configuration() 
        }
        
        private func configuration() {
            backgroundColor = .clear
            blurView.alpha = 0 
            blurView.layer.masksToBounds = false
        }
        
        private func layoutUI() {
            addSubview(blurView) 
            backgroundColor = UIColor.clear
            blurView.snp.makeConstraints { (make) in
                make.bottom.left.right.equalToSuperview() 
                make.top.equalToSuperview()
            }
            
            addSubview(listView)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            } 
            
            listView.insertSubview(headerView, at: 0)
            
            headerView.frame = CGRect(x: 0, y: -1 * headHeight,
                                  width:bounds.width, height: headHeight)
            headerView.headerBlurView.isHidden = true
            headerView.fold(animated: false)
        
            addSubview(expandButton)
            expandButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
        }
    }
}

extension NotificationPanelViewController.View {
    fileprivate func showBlurView(show:Bool) {
        if let anim = POPSpringAnimation(propertyNamed: kPOPLayerOpacity) {
            anim.toValue = show ? 1 : 0
            blurView.layer.pop_add(anim, forKey: "opacity")
            headerView.headerBlurView.layer.pop_add(anim, forKey: "opacity")
        }
    }
    
    func expand(animated:Bool = true) ->Observable<Void> {
        let _headHeight = headHeight
        let headerView = self.headerView
        let listView = self.listView
        let expandButton = self.expandButton
         
        isAnimating = true
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let this = self else { return Disposables.create() }
            
            expandButton.isEnabled = false
            expandButton.isHidden = false
            headerView.headerBlurView.isHidden = true
            this.blurView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview()
            })
            this.snp.remakeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
            this.layoutIfNeeded()
            this.setNeedsLayout()
            headerView.fold(animated: false)
            listView.collectionViewLayout.invalidateLayout()
            
            
            let completion:(Bool)->Void = { (_) in
                listView.sendSubviewToBack(headerView)
                headerView.expand()
                listView.contentInset = UIEdgeInsets(top: _headHeight, left: 0, bottom: 0, right: 0)
                this.isAnimating = false
                observer.onNext(())
                observer.onCompleted()
                listView.setContentOffset(CGPoint(x: 0, y: _headHeight * -1), animated: false)
            }
            
            let layout = this.expandLayout
            let aBlock:()->Void = {
                this.showBlurView(show: true)
                listView.contentInset = UIEdgeInsets(top: _headHeight, left: 0, bottom: 0, right: 0)
                listView.setCollectionViewLayout(layout, animated: true)
                listView.layoutIfNeeded() 
                listView.setContentOffset(CGPoint(x: 0, y: _headHeight * -1), animated: true)
                (Router.tabBarController as? FxTabBarController)?.tabBar.alpha = 0
            }
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut,
                               animations: aBlock, completion: completion )
            }else {
                aBlock()
                completion(true)
            }
            expandButton.isHidden = true
            expandButton.isEnabled = true
            return Disposables.create { }
        }
    }
    
    @discardableResult
    func fold(animated:Bool = true) ->Observable<Void> {
        let headHeight = self.headHeight + 10
        let headerView = self.headerView
        let listView = self.listView
        let expandButton = self.expandButton
        
        listView.sendSubviewToBack(headerView)
        isAnimating = true
        
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let this = self else { return Disposables.create() }
             
            expandButton.isEnabled = false
            expandButton.isHidden = false
            headerView.fold(animated: animated)
            this.blurView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview()
            })
            headerView.top = -1 * this.headHeight
            headerView.headerBlurView.isHidden = true
            this.showBlurView(show: false)
            
            let completion:(Bool)->Void = { (_) in
                this.snp.remakeConstraints({ (make) in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(headHeight)
                })
                this.layoutIfNeeded()
                expandButton.isHidden = false
                expandButton.isEnabled = true
                this.isAnimating = false
                observer.onNext(())
                observer.onCompleted()
            }
            
            let layout = this.foldLayout
            let aBlock:()->Void = {
                listView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                listView.setCollectionViewLayout(layout, animated: animated, completion: completion)
                listView.setContentOffset(CGPoint.zero, animated: true)
                (Router.tabBarController as? FxTabBarController)?.tabBar.alpha = 1
                listView.sendSubviewToBack(headerView)
            }
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut,
                               animations: aBlock, completion: completion )
            }else {
                aBlock()
                completion(true)
            }
            return Disposables.create { }
        }
    }
    
    @discardableResult
    func hide(animated:Bool = true) ->Observable<Void> {
        let headerView = self.headerView
        let listView = self.listView
        let expandButton = self.expandButton
        
        listView.sendSubviewToBack(headerView)
        isAnimating = true
        
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let this = self else { return Disposables.create() }
            expandButton.isEnabled = false
            expandButton.isHidden = false
            headerView.fold(animated: true)
            this.blurView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview()
            })
            this.snp.remakeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
            headerView.top = -1 * this.headHeight
            headerView.headerBlurView.isHidden = true
            this.showBlurView(show: false)
            
            let completion:(Bool)->Void = { (_) in
                this.layoutIfNeeded()
                expandButton.isHidden = false
                expandButton.isEnabled = true
                this.isAnimating = false
                observer.onNext(())
                observer.onCompleted()
                listView.setContentOffset(CGPoint.zero, animated: false)
            }
            let layout = this.hideLayout
            let aBlock:()->Void = {
                listView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                listView.setCollectionViewLayout(layout, animated: true, completion: completion)
                listView.setContentOffset(CGPoint.zero, animated: true)
                (Router.tabBarController as? FxTabBarController)?.tabBar.alpha = 1
                listView.sendSubviewToBack(headerView)
            }
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut,
                               animations: aBlock, completion: completion )
            }else {
                aBlock()
                completion(true)
            }
            return Disposables.create { }
        }
         
    }
}


 

 

 
