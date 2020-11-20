import RxCocoa
import RxSwift
import WKKit
import XLPagerTabStrip
class TokenInfoPageViewController: BaseButtonBarPagerTabStripViewController<TokenInfoPageBarCell> {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, coin: Coin) {
        viewModel = ViewModel(wallet: wallet, coin: coin)
        dappList = TokenInfoDappListBinder(viewModel.dappListVM)
        addressList = TokenInfoAddressListBinder(viewModel.addressListVM)
        super.init(nibName: nil, bundle: nil)
        logWhenDeinit()
        configuration()
        layoutUI()
    }

    let viewModel: ViewModel
    let dappList: TokenInfoDappListBinder
    let addressList: TokenInfoAddressListBinder
    var listControllers: [TokenInfoSubListBinder] { [addressList, dappList] }
    private var lineView: PagerTabStriButtonBarViewDecorator?
    var buttonBarHeight: CGFloat { TokenInfoSubListBinder.topEdge }
    func refresh() {
        viewModel.refresh()
    }

    func viewWillAppear() {
        addressList.refresh()
    }

    private func didMove(to index: TokenInfoPageBarCell?) {
        guard let type = index?.type else { return }
        switch type {
        case .dapp:
            dappList.refresh()
        case .address:
            addressList.refresh()
        }
    }

    override func viewControllers(for _: PagerTabStripViewController) -> [UIViewController] { return listControllers }
    override func configure(cell: TokenInfoPageBarCell, for indicatorInfo: IndicatorInfo) {
        cell.bind(indicatorInfo)
    }

    private func configuration() {
        settings.style.buttonBarHeight = 0
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarLeftContentInset = 5
        settings.style.buttonBarRightContentInset = 5
        settings.style.buttonBarMinimumLineSpacing = 10
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        buttonBarItemSpec = ButtonBarItemSpec.cellClass(width: { _ in (ScreenWidth - 160) / 5 })
        changeCurrentIndexProgressive = { [weak self] (oldCell: TokenInfoPageBarCell?, newCell: TokenInfoPageBarCell?,
                                                       _: CGFloat, changeCurrentIndex: Bool, _: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.isSelected = false
            newCell?.isSelected = true
            self?.didMove(to: newCell)
        }
    }

    private func layoutUI() {
        view.backgroundColor = HDA(0x080A32)
        view.addSubview(buttonBarView)
        lineView = PagerTabStriButtonBarViewDecorator(view: buttonBarView)
        buttonBarView.backgroundColor = HDA(0x080A32)
        buttonBarView.size = CGSize(width: ScreenWidth - 100, height: buttonBarHeight)
        buttonBarView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(buttonBarHeight)
        }

        containerView.rx.contentOffset.subscribe(onNext: { [weak self] point in
            self?.tabProgress(offset: point)
        }).disposed(by: defaultBag)

        if let interactivePopGestureRecognizer = Router.currentNavigator?.interactivePopGestureRecognizer {
            containerView.panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
        }
    }

    private func tabProgress(offset: CGPoint) {
        let pageIndex = pageFor(contentOffset: offset.x)
        let pageWidth = self.pageWidth
    }
}

extension IndicatorInfo {
    fileprivate init(title: String, type: TokenInfoPageBarCell.Types) {
        self.init(title: title)
        userInfo = type
    }

    fileprivate var type: TokenInfoPageBarCell.Types? {
        return userInfo as? TokenInfoPageBarCell.Types
    }
}

extension TokenInfoAddressListBinder: IndicatorInfoProvider {
    func indicatorInfo(for _: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Address"), type: .address)
    }
}

extension TokenInfoDappListBinder: IndicatorInfoProvider {
    func indicatorInfo(for _: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: TR("Discover"), type: .dapp)
    }
}
