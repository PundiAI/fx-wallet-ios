import RxCocoa
import RxSwift
import WKKit
import XLPagerTabStrip
class TokenInfoDappListBinder: TokenInfoSubListBinder {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindListView()
    }

    let viewModel: ViewModel
    private func bindListView() {
        weak var welf = self
        let listView = self.listView
        let listViewModel = viewModel
        listViewModel.refreshItems.elements.subscribe(onNext: { _ in
            listView.reloadData()
        }).disposed(by: defaultBag)
        listView.viewModels = { _ in
            if listViewModel.items.isNotEmpty {
                return NSMutableArray.viewModels(from: listViewModel.items, DappCell.self)
            } else {
                return NSMutableArray.viewModels(from: [(TR("Dapp.Blank.Unavailable"), TR("Dapp.Blank.Subtitle"))], DappBlankCell.self) { $0.view.switchTheme(true) }
            }
        }
        listView.didSeletedBlock = { tableView, indexPath in
            if let _ = tableView.cellForRow(at: indexPath as IndexPath) as? DappCell {
                let cellVM = listViewModel.items[indexPath.row]
                if cellVM.dapp.isExplorer {
                    Router.showExplorer(listViewModel.coin, push: true)
                } else {
                    Router.pushToDappBrowser(dapp: cellVM.dapp, wallet: welf?.viewModel.wallet)
                }
            }
        }
    }

    override func refresh() {
        guard viewModel.items.count == 0 else { return }
        viewModel.refreshItems.execute()
    }

    override func router(event: String, context: [String: Any]) {
        if event == "selected", let dapp = (context[eventSender] as? DappCell)?.viewModel {
            dapp.update()
            if dapp.star.value {
                Router.topViewController?.hud?.text(m: TR("Dapp.FavoritedTip"))
            }
        }
    }

    override func layoutUI() {
        navigationBar.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: listTop, left: 0, bottom: 0, right: 0))
        }
    }

    override var listView: WKTableView { tableView }
    lazy var tableView: WKTableView = {
        let v = WKTableView(frame: ScreenBounds, style: UITableView.Style.plain)
        v.backgroundColor = HDA(0x080A32)
        return v
    }()
}
