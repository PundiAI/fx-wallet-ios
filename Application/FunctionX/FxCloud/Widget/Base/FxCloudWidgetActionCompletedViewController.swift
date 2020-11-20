import WKKit
class FxCloudWidgetActionCompletedViewController: FxCloudWidgetActionViewController {
    override func bindList() {
        wk.view.listView.isScrollEnabled = false
        listBinder.push(ResultTitleCell.self)
    }

    override func bindAction() {
        wk.view.confirmButton.title = TR("ReturnToHome")
        wk.view.confirmButton.rx.action = CocoaAction {
            Router.currentNavigator?.popToRootViewController(animated: true)
        }
    }
}
