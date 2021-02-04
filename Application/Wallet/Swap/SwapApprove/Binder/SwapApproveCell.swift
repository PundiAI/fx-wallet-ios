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

extension SwapApproveViewController {
    class InfoCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = InfoView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? String else { return }
            self.viewModel = vm
            weak var welf = self
            view.iconIV.image = IMG("Swap.Logo")
            view.titleLabel.text = TR("Swap.Approve.Title", vm)
            view.subTitleLabel.text = TR("Swap.Approve.Tip", vm)
            
            view.editButton.rx.tap.subscribe(onNext: { (_) in
                welf?.router(event: "Edit")
            }).disposed(by: reuseBag)
        }
        
        override class func height(model: Any?) -> CGFloat {
            
            guard let vm = model as? String else { return 0 }
            
            let temp0 = TR("Swap.Approve.Title", vm)
            let temp1 = TR("Swap.Approve.Tip", vm)
            
            let width =  ScreenWidth - (24 * 2).auto()
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 16)
                $0.text = temp0
                $0.autoFont = true }.font
            
            let font2:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = temp1
                $0.autoFont = true }.font
            
            let height = temp0.height(ofWidth: width, attributes:  [.font: font1])
            let height2 = temp1.height(ofWidth: width, attributes:  [.font: font2])
            return (13 + 45 + 12 + 16).auto() + height + height2 + 75.auto()
        }
    }
}


extension SwapApproveViewController {
    class FeeCell: FxTableViewCell {
        
        static var temp0 = TR("Swap.Approve.Fee.SubTitle")
        
        private var viewModel: Any?
        lazy var view = FeePanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            view.titleLabel.text = TR("Swap.Approve.Fee.Title")
            view.subTitleLabel.text = SwapApproveViewController.FeeCell.temp0
            guard let vm = viewModel as? ApproveViewModel else { return }
            self.viewModel = vm
            view.currencyLalel.text = vm.legalAmountTitle.value
            view.amountLabel.text = vm.feeTitle.value
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let _ = model as? ApproveViewModel else { return 42.0 + (24 + 19 + 8 + 24).auto() }
            let width =  ScreenWidth / 2 - 24.auto()
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = SwapApproveViewController.FeeCell.temp0
                $0.autoFont = true
            }.font
            let height = SwapApproveViewController.FeeCell.temp0.height(ofWidth: width, attributes:  [.font: font1])
            return (24 + 19 + 8).auto() + height + 24.auto()
        }
    }
}


extension SwapApproveViewController {
    class ApproveSwitchCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = ApproveDetailsSwitch(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override class func height(model: Any?) -> CGFloat {
            return 56.auto()
        }
    }
}

extension SwapApproveViewController {
    class PermissionCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = PermissionPanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? ApproveViewModel else { return }
            self.viewModel = vm
            view.titleLabel.text = TR("Swap.Approve.Permission")
            view.subTitleLabel.text = TR("Swap.Approve.Permission.SubTitle", vm.approveCoin.value)
            view.amountTitleLabel.text = TR("Swap.Approve.Permission.Amount")
            view.amountLabel.text = vm.amountTitle.value
            view.toTitleLabel.text = TR("Swap.Approve.Permission.To")
            view.toLabel.text = vm.to.value
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? ApproveViewModel else { return 0}
            let temp0 = TR("Swap.Approve.Permission.SubTitle", vm.approveCoin.value)
            let width =  ScreenWidth - (40 * 2).auto()
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = temp0
                $0.autoFont = true }.font
            let height = temp0.height(ofWidth: width, attributes:  [.font: font1])
            return  (24 + 19 + 8 + 42 + 17 + 42 + 17 + 25).auto() + height
        }
    }
}

extension SwapApproveViewController {
    class DataCell: FxTableViewCell {
        
        private var viewModel: Any?
        lazy var view = DataPanel(frame: ScreenBounds)
        override func getView() -> UIView { view }
        
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? ApproveViewModel else { return }
            self.viewModel = vm
            view.titleLabel.text = TR("Swap.Approve.Data")
            view.typeTitleLabel.text = TR("Swap.Approve.Function")
            view.typeLabel.text = TR("Button.Approve")
            view.hashLabel.text = vm.abi.value
        }
        
        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? ApproveViewModel else { return 0}
            let width =  ScreenWidth - (40 * 2).auto()
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = vm.abi.value
                $0.autoFont = true }.font
            let height = vm.abi.value.height(ofWidth: width, attributes:  [.font: font1])
            return  (24 + 19 + 40 + 17 + 40).auto() + height + 24.auto()
        }
    }
}
