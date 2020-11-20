import Hero
import RxSwift
import TrustWalletCore
import WKKit
extension BiometricsAlertViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        let vc = BiometricsAlertViewController()
        vc.completionHandler = context["handler"] as? (WKError?) -> Void
        return vc
    }
}

class BiometricsAlertViewController: FxRegularPopViewController {
    var completionHandler: ((WKError?) -> Void)?
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bindHero()
    }

    fileprivate lazy var viewModel = ViewModel(title: TR("BiometricsAlert.Title"),
                                               subTitle: TR("BiometricsAlert.SubTitle"),
                                               leftBTitle: TR("Button.Later"),
                                               rightBTitle: TR("Button.Start"))
    override var dismissWhenTouch: Bool { true }
    override func bindListView() {
        listBinder.push(ContentCell.self, vm: viewModel)
        listBinder.push(ActionCell.self, vm: viewModel) { self.bindAction($0) }
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { _ in
            Router.dismiss(self, animated: false) {
                DispatchQueue.main.async {
                    welf?.completionHandler?(.canceled)
                }
            }
        }).disposed(by: cell.defaultBag)
        cell.confirmButton.action {
            Router.dismiss(self, animated: false) {
                DispatchQueue.main.async {
                    welf?.completionHandler?(nil)
                }
            }
        }
    }

    override func layoutUI() {
        hideNavBar()
    }
}

extension BiometricsAlertViewController {
    override func heroAnimator(from _: String, to: String) -> WKHeroAnimator? {
        switch to {
        case "BiometricsAlertViewController": return animators["0"]
        default: return nil
        }
    }

    private func bindHero() { weak var welf = self
        let animator = WKHeroAnimator({ _ in
            welf?.wk.view.backgroundButton.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
            welf?.wk.view.backgroundBlur.hero.modifiers = [.fade, .useOptimizedSnapshot,
                                                           .useGlobalCoordinateSpace]
            let modifiers: [HeroModifier] = [.useGlobalCoordinateSpace,
                                             .useOptimizedSnapshot, .translate(y: 1000)]
            welf?.wk.view.contentBGView.hero.modifiers = modifiers
            welf?.wk.view.contentView.hero.modifiers = modifiers
        }, onSuspend: { _ in
            welf?.wk.view.backgroundButton.hero.modifiers = nil
            welf?.wk.view.backgroundBlur.hero.modifiers = nil
            welf?.wk.view.contentBGView.hero.modifiers = nil
            welf?.wk.view.contentView.hero.modifiers = nil
        })
        animators["0"] = animator
    }
}
