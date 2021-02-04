//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa

extension String {
    
    func isPureNumandCharacters(string: String) -> Bool {
       let p = NSPredicate(format: "SELF MATCHES %@", "[0-9\\.]*")
       return p.evaluate(with: string)
    }
}


extension WKWrapper where Base == EditPermissionViewController {
    var view: EditPermissionViewController.View { return base.view as! EditPermissionViewController.View }
}

extension EditPermissionViewController {
    
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let wallet = context["wallet"] as? WKWallet, let vm = context["vm"] as? ApproveViewModel   else { return nil }
        let vc = EditPermissionViewController(wallet: wallet,vm: vm)
        vc.completionHandler = context["handler"] as? (String?) -> Void
        return vc
    }
}

class EditPermissionViewController: WKViewController {

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(wallet: WKWallet, vm: ApproveViewModel) {
        self.wallet = wallet
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
//        self.bindHero()
    }
    
    private let wallet: WKWallet
    private let vm: ApproveViewModel
    var completionHandler: ((String?) -> Void)?
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    
    var chooseCell = ChooseCell(style: .default, reuseIdentifier: "")
    
    
    var chooseAmount: BehaviorRelay<String> = BehaviorRelay<String>(value: "0")
    var select: BehaviorRelay<EditState> = BehaviorRelay<EditState>(value: .unlimited)

    override func loadView() { view = View(frame: ScreenBounds) }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        bindList()
        bindKeyboard()
        bindAction()
        logWhenDeinit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
        self.select.accept(vm.editState.value)
        if vm.editState.value == .custom {
            chooseCell.view.customView.inputTF.text = vm.amount.value
        }
    }
    
    override func bindNavBar() {
        navigationBar.hideLine()
        navigationBar.action(.title, title: TR("Swap.Edit.Permission"))
        navigationBar.action(.left, imageName: "ic_back_60") { [weak self] in
            Router.pop(self)
        }
    }
    
    private func bindList() {
        weak var weak = self
        listBinder.push(TopCell.self) {
            $0.view.currencyLalel.text = weak?.vm.balance.value
        }
        listBinder.push(SpendlimitCell.self)
        listBinder.push(chooseCell, vm: select)
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(108.auto(), 0, .clear))
        bindChooseCell(chooseCell)
        wk.view.listView.rx.contentOffset.observeOn(MainScheduler.asyncInstance)
            .asObservable().subscribe(onNext: { value in
                
                if value.y <= 100 || value.y >= 160 {
                    weak?.wk.view.endEditing(true)
                }
            }).disposed(by: defaultBag)
    }
    
    private func bindChooseCell(_ cell: ChooseCell) {
        weak var welf = self
        cell.view.customView.inputTF.placeholder =  pow(2, 256.d).s
        cell.view.customView.inputTF.rx.text
            .subscribe(onNext: { (text) in
            guard let _text = text else { return }
                if _text.isPureNumandCharacters(string: _text) {
                  welf?.chooseAmount.accept(_text)
                } else {
                    cell.view.customView.inputTF.text = ""
                    welf?.chooseAmount.accept("")
                }
        }).disposed(by: cell.reuseBag)
        
        cell.view.customView.inputTF.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { _ in
                guard let _select = welf?.select.value else { return }
                if _select == .unlimited {
                    welf?.select.accept(.custom)
                }
            })
            .disposed(by: cell.reuseBag)
        
        cell.view.unlimitedAmount.text = pow(2, 256.d).s + " " +  vm.approveCoin.value
        
        let enabled = cell.view.customView.inputTF.rx.text.map { ($0?.count ?? 0) > 0 }
        
        Observable.combineLatest(enabled, select)
            .flatMap { (enabled, select) -> Observable<Bool> in
            if  select == .unlimited {
                return .just(true)
            } else {
                return .just(enabled)
            }
            }.bind(to: wk.view.startButton.rx.isEnabled)
    }
    
    private func bindAction() {
        wk.view.startButton.rx.tap.subscribe { [weak self](_) in
            self?.backToLast()
        }.disposed(by: defaultBag)
    }
    
    private func backToLast() {
        if select.value == .custom {
            let value = self.chooseAmount.value
            self.completionHandler?(value)
        } else {
            self.completionHandler?(nil)
        }
        Router.pop(self)
    }
    
    private func bindKeyboard() {
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                let endFrame = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let margin = UIScreen.main.bounds.height - endFrame.origin.y
                
                this.wk.view.listView.snp.remakeConstraints( { (make) in
                    make.bottom.equalTo(this.view).offset(-margin)
                    make.top.equalToSuperview().offset(FullNavBarHeight)
                    make.left.right.equalToSuperview()
                })
                
                let offset = CGPoint(x:0, y:108.auto())
                UIView.animate(withDuration: duration) {
                    this.wk.view.listView.setContentOffset(offset, animated: false)
                    this.view.layoutIfNeeded()
                }
            }).disposed(by: defaultBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] notif in
                guard let this = self else { return }
                
                let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

                this.wk.view.listView.snp.remakeConstraints( { (make) in
                    make.bottom.equalTo(this.wk.view.startButton.snp.top).offset(-16.auto())
                    make.top.equalToSuperview().offset(FullNavBarHeight)
                    make.left.right.equalToSuperview()
                })
                
                UIView.animate(withDuration: duration) {
                    this.view.layoutIfNeeded()
                }
        }).disposed(by: defaultBag)
    }
    
}
        
