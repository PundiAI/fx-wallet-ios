

import WKKit
import RxSwift
import RxCocoa

extension WKWrapper where Base == CryptoBankTxHistoryViewController {
    var view: Base.View { return base.view as! Base.View }
}

extension CryptoBankTxHistoryViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet else { return nil }
        
        return CryptoBankTxHistoryViewController(wallet: wallet)
    }
}

class CryptoBankTxHistoryViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet) {
        self.viewModel = ViewModel(wallet: wallet)
        super.init(nibName: nil, bundle: nil)
    }
    
    let viewModel: ViewModel
    lazy var listBinder = WKTableViewBinder<CellViewModel>(view: wk.view.listView)
    
    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logWhenDeinit()
        
        bindListView()
        
        listBinder.refreshIfNoData()
    }
    
    override func bindNavBar() {
        super.bindNavBar()
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("MyDeposits.TxHistory"))
    }
    
    private func bindListView() {
        
        let vm = self.viewModel
        listBinder.viewModels = { [weak self] _ in
            
            let items = NSMutableArray.viewModels(from: vm.items, Cell.self)
            if items.count == 0 {
                items.push(NoDataCell.self)
                self?.listBinder.footer?.setTitle("", for: .noMoreData)
            }
            return items
        }
        listBinder.bind(viewModel)
    }
}
        
