

import WKKit
import pop
import SnapKit
import RxSwift 
import SwipeCellKit
import RxCocoa


extension NotificationPanelViewController {
    class FxTimer {
        var timer: Observable<Int>!
        let begin:TimeInterval
        
        init(begin:TimeInterval) {
            self.begin = begin
            timer = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance)
        }
        
        func start() ->Observable<String> {
            return timer.map {[weak self] (input) -> Int in
                guard let this = self else { return 0}
                let now =  NSDate().timeIntervalSince1970
                var tagIndx = Int(now - this.begin)
                if tagIndx <= 0 { tagIndx = 0 }
                return tagIndx
            }.map(self.stringFromTimeInterval).share(replay: 1, scope: .forever)
        }
 
        func stringFromTimeInterval(ms: NSInteger) -> String {
            let h = ms / 3600
            let m = (ms % 3600) / 60
            let s = (ms % 3600) % 60
            return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
        }
    }
    
    class TimerLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.font = XWallet.Font(ofSize: 14)
            self.textColor = COLOR.title
            self.text = text
        }
        var time: TimeInterval = 0
        var timer:FxTimer?
        var bag = DisposeBag()
        
        deinit {
            bag = DisposeBag()
        }
        
        func bind(time: TimeInterval, content: String) {
            bag = DisposeBag()
            timer = FxTimer(begin: time)
            timer?.start().map { content + " ... " + $0 }.bind(to: rx.text).disposed(by: bag)
        }
 
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
     
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
             
            addSubview(headerView)
            headerView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(0)
                make.height.equalTo(headHeight)
            }
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
    
    func expand(animated:Bool = true, duration:TimeInterval = 0.25, curve: UIView.AnimationCurve = .easeIn) ->Observable<Void> {
        let _headHeight = headHeight
        let headerView = self.headerView
        let listView = self.listView
        let expandButton = self.expandButton
        let blurView = self.blurView
        
        isAnimating = true
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let this = self else { return Disposables.create() }
            expandButton.isEnabled = false
            expandButton.isHidden = false
            headerView.headerBlurView.isHidden = true
            
            blurView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview()
            })
            this.snp.remakeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
            this.layoutIfNeeded()
            this.setNeedsLayout()
            listView.collectionViewLayout.invalidateLayout()
             
            let completion:(Bool)->Void = { (_) in
                listView.sendSubviewToBack(headerView)
                listView.contentInset = UIEdgeInsets(top: _headHeight, left: 0, bottom: 0, right: 0)
                this.isAnimating = false
                observer.onNext(())
                observer.onCompleted()
                listView.setContentOffset(CGPoint(x: 0, y: _headHeight * -1), animated: false)
            }
            
            let layout = this.expandLayout
            let aBlock:()->Void = {
                listView.contentInset = UIEdgeInsets(top: _headHeight, left: 0, bottom: 0, right: 0)
                listView.setCollectionViewLayout(layout, animated: true)
                listView.layoutIfNeeded()
                listView.setContentOffset(CGPoint(x: 0, y: _headHeight * -1), animated: true)
            }
            
            if animated {
                var runningAnimators:[UIViewPropertyAnimator] = []
                let basicAnimator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: nil)
                basicAnimator.addAnimations {
                     aBlock()
                }
                
                let headAnimator = UIViewPropertyAnimator(duration: duration, curve: curve) {
                    headerView.contentView.transform = CGAffineTransform.identity
                    headerView.contentView.alpha = 1
                }
                
                let blurAnimator = UIViewPropertyAnimator(duration: duration, controlPoint1: CGPoint(x: 0.8, y: 0.2),
                                                          controlPoint2: CGPoint(x: 0.8, y: 0.2)) {
                    blurView.alpha = 1
                    headerView.headerBlurView.alpha = 1
                    Router.fxTabBarController?.setAlpha(alpha: 0)
                }
                
                basicAnimator.addCompletion { position in
                    completion(true)
                }
                
                runningAnimators.append(headAnimator)
                runningAnimators.append(basicAnimator)
                runningAnimators.append(blurAnimator)
                runningAnimators.forEach { $0.startAnimation() }
            }else {
                aBlock()
                completion(true)
            }
            expandButton.isHidden = true
            expandButton.isEnabled = true
            return Disposables.create { }
        }.subscribeOn(MainScheduler.instance)
    }
    
    @discardableResult
    func fold(animated:Bool = true) ->Observable<Void> {
        let headHeight = self.headHeight + 10
        let headerView = self.headerView
        let listView = self.listView
        let expandButton = self.expandButton
        isAnimating = true
        
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let this = self else { return Disposables.create() }
            listView.sendSubviewToBack(headerView)
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
                Router.fxTabBarController?.setAlpha(alpha: 1)
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
        }.subscribeOn(MainScheduler.instance)
    }
    
    @discardableResult
    func hide(animated:Bool = true, duration:TimeInterval = 0.25, curve: UIView.AnimationCurve = .easeIn) ->Observable<Void> {
        let headerView = self.headerView
        let listView = self.listView
        let expandButton = self.expandButton
        let blurView = self.blurView
        
        isAnimating = true
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let this = self else { return Disposables.create() }
            listView.bringSubviewToFront(headerView)
            expandButton.isEnabled = false
            expandButton.isHidden = false
            blurView.snp.updateConstraints({ (make) in
                make.top.equalToSuperview()
            })
            this.snp.remakeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview()
            })
            headerView.top = -1 * this.headHeight
            headerView.headerBlurView.isHidden = true
            
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
                listView.bringSubviewToFront(headerView)
            }
            if animated {
                var runningAnimators:[UIViewPropertyAnimator] = []
                let basicAnimator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: nil)
                basicAnimator.addAnimations {
                     aBlock()
                }
                
                let headAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                    headerView.contentView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -100.auto())
                    headerView.contentView.alpha = 0
                }
                
                let blurAnimator = UIViewPropertyAnimator(duration: duration, controlPoint1: CGPoint(x: 0.8, y: 0.2),
                                                          controlPoint2: CGPoint(x: 0.8, y: 0.2)) {
                    blurView.alpha = 0
                    headerView.headerBlurView.alpha = 0
                    Router.fxTabBarController?.setAlpha(alpha: 1)
                }
                
                basicAnimator.addCompletion { position in
                    completion(true)
                }
                
                runningAnimators.append(headAnimator)
                runningAnimators.append(basicAnimator)
                runningAnimators.append(blurAnimator)
                runningAnimators.forEach { $0.startAnimation() }
            }else {
                aBlock()
                completion(true)
            }
            
            return Disposables.create { }
        }.subscribeOn(MainScheduler.instance)
         
    }
}


 

 

 
