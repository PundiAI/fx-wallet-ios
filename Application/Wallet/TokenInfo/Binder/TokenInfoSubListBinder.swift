import RxCocoa
import RxSwift
import WKKit
import XLPagerTabStrip
class TokenInfoSubListBinder: WKViewController {
    static var topEdge: CGFloat { 75 }
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        logWhenDeinit()
        layoutUI()
        configuration()
        bindListResponder()
    }

    let contentOffset = BehaviorRelay<CGPoint?>(value: nil)
    func refresh() {}
    func bindListResponder() {
        listView.isFirstScrollResponder = false
        listView.scrollViewDidScroll = { [weak self] _ in
            guard let this = self else { return }
            if this.contentOffset.value != this.listView.contentOffset {
                this.contentOffset.accept(this.listView.contentOffset)
            }
            if !this.listView.isFirstScrollResponder || this.listView.contentOffset.y <= 0 {
                this.listView.contentOffset = .zero
            }
        }
    }

    func configuration() {
        view.backgroundColor = HDA(0x080A32)
    }

    func layoutUI() {
        navigationBar.isHidden = true
    }

    var listTop: CGFloat { TokenInfoSubListBinder.topEdge + 20 }
    var listView: WKTableView { fatalError("listView has not been implemented") }
}
