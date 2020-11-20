import Hero
import RxCocoa
import RxSwift
import TrustWalletCore
import WKKit
typealias CompletionHandler = ((SetLanguageViewController.Language?) -> Void)
extension SetLanguageViewController {
    override class func instance(with context: [String: Any] = [:]) -> UIViewController? {
        let vc = SetLanguageViewController()
        vc.completionHandler = context["handler"] as? CompletionHandler
        return vc
    }
}

class SetLanguageViewController: FxRegularPopViewController {
    var viewModel = ViewModel()
    var completionHandler: CompletionHandler?
    override var dismissWhenTouch: Bool { false }
    override func bindListView() {
        listBinder.push(ContentCell.self) { self.bindContentCell(cell: $0) }
        listBinder.push(ActionCell.self) { self.bindActionCell(cell: $0) }
    }

    private func bindContentCell(cell: ContentCell) {
        cell.closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            Router.dismiss(self)
        }).disposed(by: cell.defaultBag)
        cell.tableView.viewModels = { [weak self] section in
            self?.viewModel.items.each { vm in
                section.push(ItemCell.self, m: vm)
            }
            return section
        }
        cell.tableView.nextEventResponder = self
        cell.tableView.didSeletedBlock = { table, idx in
            if let _cell = table.cellForRow(at: idx as IndexPath) as? ItemCell {
                _cell.router(event: "selected")
            }
        }
    }

    private func bindActionCell(cell: ActionCell) {
        cell.confirmButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.confirmAction()
        }).disposed(by: cell.defaultBag)
    }

    override var next: UIResponder? { nil }
    override func router(event: String, context: [String: Any]) {
        if event == "selected", let cell = context[eventSender] as? ItemCell,
            let vm = cell.model as? CellViewModel
        {
            for item in viewModel.items {
                if item.item.name == vm.item.name {
                    item.selected.accept(!item.selected.value)
                } else {
                    item.selected.accept(false)
                }
            }
        }
    }

    private func confirmAction() {
        completionHandler?(viewModel.selecdItem())
        Router.dismiss(self)
    }

    override func layoutUI() {
        hideNavBar()
    }
}
