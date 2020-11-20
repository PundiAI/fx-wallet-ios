import RxCocoa
import RxSwift
import WKKit
import XLPagerTabStrip
class DappPopularListBinder: DappSubListBinder {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindListView()
    }

    let viewModel: ViewModel
    private func bindListView() { let listView = self.listView
        let listViewModel = viewModel
        listView.nextEventResponder = self
        listViewModel.refreshItems.elements.subscribe(onNext: { _ in
            listView.reloadData()
        }).disposed(by: defaultBag)
        listView.viewModels = { _ in NSMutableArray.viewModels(from: listViewModel.items, DappCell.self) }
        listView.didSeletedBlock = { [weak self] tableView, indexPath in
            if let _ = tableView.cellForRow(at: indexPath as IndexPath) as? DappCell {
                let cellVM = listViewModel.items[indexPath.row]
                if cellVM.dapp.isExplorer {
                    Router.showExplorer(listViewModel.coin, push: true)
                } else {
                    Router.pushToDappBrowser(dapp: cellVM.dapp, wallet: self?.viewModel.wallet.wk)
                }
            }
        }
    }

    override var next: UIResponder? { nil }
    override func router(event: String, context: [String: Any]) {
        if event == "selected", let dapp = (context[eventSender] as? DappCell)?.viewModel {
            dapp.update()
            if dapp.star.value {
                Router.topViewController?.hud?.text(m: TR("Dapp.FavoritedTip"))
            }
        }
    }

    override func refresh() {
        viewModel.refreshItems.execute()
    }

    override func layoutUI() {
        navigationBar.isHidden = true
        view.backgroundColor = UIColor.clear
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: DappSubListBinder.topEdge + 5, left: 0, bottom: 0, right: 0))
        }
        tableView.contentInset = UIEdgeInsets(top: 24.auto(), left: 0, bottom: listBottom, right: 0)
    }

    override var listView: WKTableView { tableView }
    lazy var tableView: WKTableView = {
        let v = WKTableView(frame: ScreenBounds, style: UITableView.Style.plain)
        v.separatorStyle = .none
        v.backgroundColor = .clear
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.contentInsetAdjustmentBehavior = .never
        return v
    }()
}
