
import AudioToolbox
import HapticGenerator
import RxCocoa
import RxSwift
import WKKit
import XLPagerTabStrip
extension WKWrapper where Base == TokenInfoAddressListBinder {
    var view: TokenInfoAddressListBinder.View { return base.view as! TokenInfoAddressListBinder.View }
}

class TokenInfoAddressListBinder: TokenInfoSubListBinder {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindListView()
        bindMoveCell()
        bindAccount()
    }

    let viewModel: ViewModel
    override var listView: WKTableView { wk.view.listView }
    override func loadView() { view = View(frame: ScreenBounds) }
    override func refresh() {
        viewModel.refreshItems.execute()
    }

    private func bindListView() {
        let listView = self.listView
        let listViewModel = viewModel
        listViewModel.refreshItems.elements.subscribe(onNext: { _ in
            listView.reloadData()
        }).disposed(by: defaultBag)
        listView.viewModels = { _ in NSMutableArray.viewModels(from: listViewModel.items, Cell.self) }
        listView.didSeletedBlock = { _, indexPath in
            let cellVM = listViewModel.items[indexPath.row] Router.showTokenActionSheet(wallet: listViewModel.wallet, coin: cellVM.coin, account: cellVM.account)
        }
    }

    private func bindAccount() {
        wk.view.addAddressButton.action { [weak self] in
            self?.wk.view.addAddressButton.inactiveAWhile()
            guard let this = self else { return }
            if this.viewModel.coin.isCloud {
                Router.showAnyHrpSelectAddressAlert(wallet: this.viewModel.wallet, hrp: this.viewModel.coin.hrp ?? "fx", addedAddresses: this.viewModel.accounts.addresses) { vc, account in
                    Router.dismiss(vc) {
                        _ = this.viewModel.add(account)
                    }
                }
            } else {
                Router.showSelectAddressAlert(wallet: this.viewModel.wallet, coin: this.viewModel.coin, addedAddresses: this.viewModel.accounts.addresses) { vc, account in
                    Router.dismiss(vc) {
                        _ = this.viewModel.add(account)
                    }
                }
            }
        }
        viewModel.wallet.event.didRemoveAccount.subscribe(onNext: { [weak self] _, account in
            guard let this = self else { return }
            let success = this.viewModel.remove(account)
            if success { this.refresh() }
        }).disposed(by: defaultBag)
    }
}

extension TokenInfoAddressListBinder: UITableViewDragDelegate, UITableViewDropDelegate {
    private func bindMoveCell() {
        let listView = wk.view.listView
        listView.dragInteractionEnabled = true
        listView.moveRow = { [weak self] from, to in
            Haptic.impactMedium.generate()
            self?.viewModel.exchangeItem(from: from.row, to: to.row)
            listView.reloadData()
            listView.inactiveAWhile(1)
        }
        viewModel.refreshItems.elements.subscribe(onNext: { items in
            let enabled = items.count > 1
            listView.dropDelegate = enabled ? self : nil
            listView.dragDelegate = enabled ? self : nil
        }).disposed(by: defaultBag)
    }

    func tableView(_: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_: UITableView, dropSessionDidUpdate _: UIDropSession, withDestinationIndexPath _: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(at: indexPath)
    }

    func tableView(_: UITableView, itemsForBeginning _: UIDragSession, at _: IndexPath) -> [UIDragItem] {
        Haptic.impactMedium.generate()
        return [UIDragItem(itemProvider: NSItemProvider(object: NSString()))]
    }

    func tableView(_: UITableView, performDropWith _: UITableViewDropCoordinator) {}

    func tableView(_: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(at: indexPath)
    }

    private func previewParameters(at _: IndexPath) -> UIDragPreviewParameters {
        let param = UIDragPreviewParameters()
        param.visiblePath = UIBezierPath(roundedRect: CGRect(x: 16, y: 0, width: ScreenWidth - 16 * 2, height: Cell.height(model: nil)), cornerRadius: 16)
        return param
    }
}
