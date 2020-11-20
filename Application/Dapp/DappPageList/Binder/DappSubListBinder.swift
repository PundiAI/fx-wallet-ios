import RxCocoa
import RxSwift
import WKKit
import XLPagerTabStrip
class DappSubListBinder: WKViewController {
    static var topEdge: CGFloat { 59.auto() + 19.auto() + StatusBarHeight }
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        logWhenDeinit()
        layoutUI()
        configuration()
    }

    func refresh() {}
    func configuration() {
        view.backgroundColor = .clear
    }

    func layoutUI() {
        navigationBar.isHidden = true
    }

    var listTop: CGFloat { DappSubListBinder.topEdge + 24.auto() }
    var listBottom: CGFloat { TabBarHeight + 24.auto() }
    var listView: WKTableView { fatalError("listView has not been implemented") }
}
