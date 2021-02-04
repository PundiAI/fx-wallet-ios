//
//
//  XWallet
//
//  Created by May on 2020/8/21.
//  Copyright © 2020 May All rights reserved.
//
import WKKit
import RxSwift
import RxCocoa
import TrustWalletCore
import Hero

typealias CompletionHandler = ((SetLanguageViewController.Language?) -> Void)

extension SetLanguageViewController {
    
    override class func instance(with context: [String : Any] = [:]) -> UIViewController? {
        let vc = SetLanguageViewController()
        vc.completionHandler = context["handler"] as? CompletionHandler
        return vc
    }
}

class SetLanguageViewController: FxRegularPopViewController {
    
    var viewModel: ViewModel = ViewModel()
    var completionHandler: CompletionHandler?
    
    var selectedModel: LanguageItem?
    override var dismissWhenTouch: Bool { false }
    override func bindListView() {
        listBinder.push(ContentCell.self) { self.bindContentCell(cell: $0)}
        listBinder.push(ActionCell.self) { self.bindActionCell(cell: $0)}
    }
    
    private func bindContentCell(cell: ContentCell) {
        cell.closeButton.rx.tap.subscribe(onNext: { [weak self](_) in
            Router.dismiss(self)
        }).disposed(by: cell.defaultBag)
        
        cell.tableView.viewModels = { [weak self] section in
            self?.viewModel.items.each { (vm) in
                section.push(ItemCell.self, m: vm)
            }
            return section
        }
        
        cell.tableView.nextEventResponder = self
        
        cell.tableView.didSeletedBlock = { (table, idx) in
            if let _cell = table.cellForRow(at: idx as IndexPath) as? ItemCell {
                _cell.router(event: "selected")
            }
        }
    }
    
    private func bindActionCell(cell: ActionCell) {
        cell.confirmButton.rx.tap.subscribe(onNext: { [weak self](_) in
            self?.confirmAction()
        }).disposed(by: cell.defaultBag)
    }
    
    override var next: UIResponder? { nil }
     
    override func router(event: String, context: [String : Any]) {
        if event == "selected" , let cell = context[eventSender] as? ItemCell ,
           let vm = cell.model as? CellViewModel {
            for item in viewModel.items {
                if item.item.title == vm.item.title {
                    self.selectedModel = vm.item
                    item.selected.accept(true)
                } else {
                    item.selected.accept(false)
                }
            }
        }
    }
    
    private func confirmAction() { 
        guard let selectmodel = self.selectedModel else {
            Router.dismiss(self)
            return
        } 
        
        hud?.waiting(m: TR("Setting.Language.Updateing"), .fullScreen)
        Observable.just(()).delay(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.hud?.hide(animated: false)
            WKLocale.Shared.language = selectmodel
            WKEvent.Language.Send(event: .LanguageDidChange)
        }).disposed(by: defaultBag)
    }
    
    override func layoutUI() {
        hideNavBar()
    }
}

