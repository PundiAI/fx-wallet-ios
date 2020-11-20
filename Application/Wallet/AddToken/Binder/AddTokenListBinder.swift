import WKKit
extension AddTokenViewController {
    class ListBinder: NSObject, UITableViewDelegate, UITableViewDataSource, EventResponder {
        init(view: View) {
            self.view = view
            super.init()
            listView.nextEventResponder = self
        }

        let view: View
        var listView: WKTableView { view.mainListView }
        var viewModel: ListViewModel!
        var didAdded: ((Coin) -> Void)?
        var didScroll: ((UITableView) -> Void)?
        func bind(_ viewModel: ListViewModel) {
            self.viewModel = viewModel
            listView.register(AddCoinListCell.self, forCellReuseIdentifier: "cell")
            listView.delegate = self
            listView.dataSource = self
        }

        func scrollViewDidScroll(_: UIScrollView) {
            didScroll?(listView)
        }

        func numberOfSections(in _: UITableView) -> Int {
            return viewModel?.items.count ?? 0
        }

        func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 40.auto() }
        func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            return section == 0 ? view.suggestedSection : view.availableSection
        }

        func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 24.auto() }
        func tableView(_: UITableView, titleForFooterInSection _: Int) -> String? { return "" }
        func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.items[section].count
        }

        func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return viewModel.items[indexPath.section][indexPath.row].height
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AddCoinListCell
            cell.bind(viewModel.items[indexPath.section][indexPath.row])
            return cell
        }

        var nextEventResponder: EventResponder? { nil }
        func router(event: String, context: [String: Any]) {
            guard event == "add", let coin = (context["eventSender"] as? AddCoinListCell)?.viewModel?.rawValue else { return }
            didAdded?(coin)
        }
    }
}
