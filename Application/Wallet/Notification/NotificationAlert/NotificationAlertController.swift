import Hero
import RxSwift
import TrustWalletCore
import WKKit
class NotificationAlertController: FxRegularPopViewController {
    override var dismissWhenTouch: Bool { false }
    override var interactivePopIsEnabled: Bool { false }
    override func bindListView() {
        listBinder.push(ContentCell.self)
        listBinder.push(ActionCell.self) { self.bindAction($0) }
    }

    override func dismiss(animated _: Bool, completion _: (() -> Void)? = nil) {
        Router.pop(self)
    }

    private func bindAction(_ cell: ActionCell) {
        weak var welf = self
        cell.cancelButton.rx.tap.subscribe(onNext: { _ in
            Router.dismiss(welf)
        }).disposed(by: cell.defaultBag)
        cell.confirmButton.action {
            WKRemoteServer.request()
            Router.dismiss(welf)
        }
    }

    override func layoutUI() {
        hideNavBar()
        setBackgoundOverlayViewImage()
    }
}
