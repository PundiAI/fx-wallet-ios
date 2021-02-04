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

extension EditPermissionViewController {
    class TopCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = TopPanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 100.auto()
        }
    }
}
      
extension EditPermissionViewController {
    class SpendlimitCell: FxTableViewCell {
        
        static var temp = TR("Swap.EditPermission.SubTip")
        
        private var viewModel: Any?
        lazy var view = SpendlimitView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            view.subTitleLabel.text = EditPermissionViewController.SpendlimitCell.temp
        }
        
        override class func height(model: Any?) -> CGFloat {
            let width =  ScreenWidth - (24 * 2).auto()
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = EditPermissionViewController.SpendlimitCell.temp
                $0.autoFont = true }.font
            let height = EditPermissionViewController.SpendlimitCell.temp.height(ofWidth: width, attributes:  [.font: font1])
            return  (16 + 19 + 8).auto() + height + 24.auto()
        }
    }
}

extension EditPermissionViewController {
    class ChooseCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = ChoosePanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? BehaviorRelay<EditState> else { return }
            self.viewModel = vm
            weak var welf = self
            
            vm.observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: {(state) in
                    welf?.view.type = state
                    if state == .custom {
                        welf?.view.customInputTF.becomeFirstResponder()
                    } else {
                        welf?.view.customInputTF.resignFirstResponder()
                    }
                }).disposed(by: defaultBag)
            
            view.unlimitedSelect.rx.tap.subscribe(onNext: { (_) in
                vm.accept(.unlimited)
            }).disposed(by: reuseBag)
            
            view.customSelect.rx.tap.subscribe(onNext: { (_) in
                vm.accept(.custom)
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            return 285.auto()
        }
    }
}
    
