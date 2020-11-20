import RxCocoa
import RxSwift
import WKKit
extension WKWrapper where Base == SetCurrencyViewController {
    var view: SetCurrencyViewController.View { return base.view as! SetCurrencyViewController.View }
}

extension SetCurrencyViewController {
    override class func instance(with context: [String: Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        let vc = SetCurrencyViewController(wallet: wallet)
        return vc
    }
}

class SetCurrencyViewController: WKViewController {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    let viewModel = ViewModel()
    let wallet: WKWallet
    init(wallet: WKWallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
        bindHero()
    }

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindList()
        logWhenDeinit()
    }

    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Settings.Currency"))
    }

    private func bindList() {
        wk.view.listView.viewModelsBolck = { [weak self] in
            var sections = [NSMutableArray]()
            guard let indexs = self?.viewModel.currencys?.indexs, let items = self?.viewModel.currencys?.items else {
                return sections
            }
            for idx in indexs {
                let section = NSMutableArray()
                if let items = items[idx] {
                    for item in items {
                        section.push(Cell.self, m: item)
                    }
                }
                sections.append(section)
            }
            return sections
        }
        wk.view.listView.sectionViewsBolck = { [weak self] in
            var section = [AnyObject]()
            guard let indexs = self?.viewModel.currencys?.indexs else {
                return section
            }
            for idx in indexs {
                let view = SectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 32.auto()))
                view.titleLabel.text = idx
                section.append(view)
            }
            return section
        }
        guard let indexs = viewModel.currencys?.indexs else {
            return
        }
        wk.view.indexBar?.delegate = self
        wk.view.indexBar?.setIndexes(indexs)
        wk.view.listView.nextEventResponder = self
        wk.view.listView.didSeletedBlock = { table, idx in
            if let _cell = table.cellForRow(at: idx as IndexPath) as? Cell {
                _cell.router(event: "selected")
            }
        }
        wk.view.listView.scrollViewDidScroll = { [weak self] table in
            if let index = table.indexPathForRow(at: table.contentOffset) {
                self?.wk.view.indexBar?.setSelectedLabel(index.section)
            }
        }
    }

    override var next: UIResponder? { nil }
    override func router(event: String, context: [String: Any]) {
        if event == "selected", let cell = context[eventSender] as? Cell,
            let vm = cell.model as? CellViewModel
        {
            guard let indexs = viewModel.currencys?.indexs, let items = viewModel.currencys?.items else {
                return
            }
            for idx in indexs {
                if let items = items[idx] {
                    for item in items {
                        if item.item.currency == vm.item.currency {
                            vm.selected.accept(!vm.selected.value)
                        } else {
                            item.selected.accept(false)
                        }
                    }
                }
            }
        }
    }
}

extension SetCurrencyViewController: TTIndexBarDelegate {
    func indexDidChanged(_: TTIndexBar!, index: Int, title _: String!) {
        wk.view.listView.scrollToRow(at: NSIndexPath(item: 0, section: index) as IndexPath, at: .top, animated: true)
    }
}

extension SetCurrencyViewController {
    override func heroAnimator(from: String, to: String) -> WKHeroAnimator? {
        switch (from, to) {
        case ("SettingsViewController", "SetCurrencyViewController"): return animators["0"]
        default: return nil
        }
    }

    private func bindHero() { animators["0"] = WKHeroAnimator.Share.push()
    }
}
