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

extension PreMnemonicViewController {
    class Cell: FxTableViewCell {

        private var viewModel: BackUpNoticeViewController.CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }

        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? BackUpNoticeViewController.CellViewModel else { return }
            self.viewModel = vm
            view.titleLabel.text = vm.title
            vm.subTitle.lineSpacingLabel(view.subtitleLabel)
            view.subtitleLabel.autoFont = true
        }

        override class func height(model: Any?) -> CGFloat {
             let width = ScreenWidth - 24 * 2
               if let vm =  model as? BackUpNoticeViewController.CellViewModel {
                   if vm.subTitle.length > 0 {
                    
                    let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }
                    
                    let font2:UIFont = UILabel().then {
                                            $0.font = XWallet.Font(ofSize: 16)
                                            vm.subTitle.lineSpacingLabel($0)
                                            $0.autoFont = true }.font
                    
                      let height = vm.subTitle.height(ofWidth: width, attributes: [.font: font2,
                                                                                    .paragraphStyle: style])
                       return (29 + 8).auto() + height + 24.auto()
                   } else {
                      return 29.auto() + 26.auto()
                   }
               }
            return 29.auto()
        }
    }
}


extension PreMnemonicViewController {
    class TagsCell: FxTableViewCell {

        private var viewModel: [String]?
        lazy var view = MnemonicTagView(frame: ScreenBounds)
        override func getView() -> UIView { view }

        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? [String] else { return }
            self.viewModel = vm
            self.view.tagList.tagArray = NSMutableArray(array: vm)
            self.view.tagList._reloadPreData(true)
            self.view.tagList.resignFirstResponder()
        }

        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2
               if let vm =  model as? [String] {
                let height = VITagListView.staticHeight(CGPoint(x: 24, y: 24).auto(), width: width, tags: NSMutableArray(array: vm))
                return height
               }
            return 29
        }
    }
}
                
