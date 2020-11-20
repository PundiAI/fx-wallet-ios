
import pop
import PromiseKit
import RxCocoa
import RxSwift
import SnapKit
import SwipeCellKit
import WKKit
extension NotificationListViewController {
    class View: UIView {
        var isAnimating: Bool = false
        var headHeight: CGFloat {
            return NotificationListViewController.minContentHeight - 10.auto()
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

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        let foldLayout: NotificationFoldLayout
        let expandLayout: NotificationExpandLayout
        init(foldLayout: NotificationFoldLayout, expandLayout: NotificationExpandLayout) {
            self.foldLayout = foldLayout
            self.expandLayout = expandLayout
            super.init(frame: ScreenBounds)
            logWhenDeinit()
            layoutUI()
            configuration()
        }

        private func configuration() {
            backgroundColor = .clear
            blurView.alpha = 0 blurView.layer.masksToBounds = false
        }

        private func layoutUI() {
            addSubview(blurView) backgroundColor = UIColor.clear
            blurView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview() make.top.equalToSuperview()
            }
            addSubview(listView)
            listView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            } listView.insertSubview(headerView, at: 0)
            headerView.frame = CGRect(x: 0, y: -1 * headHeight,
                                      width: bounds.width, height: headHeight)
            headerView.headerBlurView.isHidden = true
            headerView.fold(animated: false)
            addSubview(expandButton)
            expandButton.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
            }
        }
    }
}

extension NotificationListViewController.View {
    fileprivate func showBlurView(show: Bool) {
        if let anim = POPSpringAnimation(propertyNamed: kPOPLayerOpacity) {
            anim.toValue = show ? 1 : 0
            blurView.layer.pop_add(anim, forKey: "opacity")
            headerView.headerBlurView.layer.pop_add(anim, forKey: "opacity")
        }
    }

    func expand(animated _: Bool = true) -> Guarantee<Bool> {
        let _headHeight = headHeight
        isAnimating = true
        return Guarantee<Bool> { [weak self] seal in
            guard let this = self else { return }
            self?.expandButton.isEnabled = false
            self?.expandButton.isHidden = false
            self?.headerView.headerBlurView.isHidden = true
            self?.blurView.snp.updateConstraints { make in
                make.top.equalToSuperview()
            }
            self?.snp.remakeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalToSuperview()
            }
            self?.layoutIfNeeded()
            self?.setNeedsLayout()
            self?.headerView.fold(animated: false)
            self?.listView.collectionViewLayout.invalidateLayout()
            UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self?.showBlurView(show: true)
                self?.listView.contentInset = UIEdgeInsets(top: _headHeight, left: 0, bottom: 0, right: 0)
                self?.listView.setCollectionViewLayout(this.expandLayout, animated: true)
                self?.listView.setContentOffset(CGPoint(x: 0, y: _headHeight * -1), animated: true)
                (Router.tabBarController as? FxTabBarController)?.tabBar.alpha = 0
            }, completion: { _ in
                self?.listView.sendSubviewToBack(self!.headerView)
                self?.headerView.expand()
                self?.listView.contentInset = UIEdgeInsets(top: _headHeight, left: 0, bottom: 0, right: 0)
                self?.isAnimating = false
                seal(true)
                self?.listView.setContentOffset(CGPoint(x: 0, y: _headHeight * -1), animated: false)
            })
            self?.expandButton.isHidden = true
            self?.expandButton.isEnabled = true
        }
    }

    @discardableResult
    func fold(animated: Bool = true) -> Guarantee<Bool> {
        let headHeight = self.headHeight + 10
        listView.sendSubviewToBack(headerView)
        isAnimating = true
        return Guarantee<Bool> { [weak self] seal in
            guard let this = self else { return }
            self?.expandButton.isEnabled = false
            self?.expandButton.isHidden = false
            self?.headerView.fold(animated: animated)
            self?.blurView.snp.updateConstraints { make in
                make.top.equalToSuperview()
            }
            self?.headerView.top = -1 * (self?.headHeight ?? 0)
            self?.headerView.headerBlurView.isHidden = true
            self?.showBlurView(show: false)
            let block: (Bool) -> Void = { _ in
                self?.snp.remakeConstraints { make in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(headHeight)
                }
                self?.layoutIfNeeded()
                self?.expandButton.isHidden = false
                self?.expandButton.isEnabled = true
                self?.isAnimating = false
                seal(true)
                self?.listView.setContentOffset(CGPoint.zero, animated: false)
            }
            let layout = this.foldLayout
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self?.listView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    self?.listView.setCollectionViewLayout(layout, animated: animated, completion: block)
                    self?.listView.setContentOffset(CGPoint.zero, animated: true)
                    (Router.tabBarController as? FxTabBarController)?.tabBar.alpha = 1
                    self?.listView.sendSubviewToBack(self!.headerView)
                }, completion: { _ in
                    block(true)
                })
            } else {
                self?.listView.setCollectionViewLayout(layout, animated: false)
                self?.listView.sendSubviewToBack(self!.headerView)
                self?.listView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                (Router.tabBarController as? FxTabBarController)?.tabBar.alpha = 1
                block(false)
            }
        }
    }
}
