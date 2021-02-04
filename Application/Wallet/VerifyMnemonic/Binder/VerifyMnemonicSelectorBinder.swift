//
//  VerifyMnemonicSelectorBinder.swift
//  XWallet
//
//  Created by HeiHuaBaiHua on 2019/12/4.
//  Copyright © 2019 Andy.Chan 6K. All rights reserved.
//

import UIKit
import WKKit

extension VerifyMnemonicViewController {
    
    class SelectorBind {
        
        struct Context {
            let items: [String]
            let options: [String]
            let selectItem: String
            
            var selectItemIdx: Int { return (items.indexOf(condition: { $0 == selectItem }) ?? 0) + 1 }
        }
        
        let view: SelectorView
        private var context: Context!
        private var selectedButton: UIButton?
        var didSelectedHandler: ((Bool) -> Void)?
        
        var isPassed: Bool { return selectedButton?.title == context.selectItem }
        
        init(view: SelectorView) {
            self.view = view
        }
        
        //MARK: Bind
        func bind(_ context: Context) {
            self.context = context
            
            view.titleLabel.text = TR("Mnemonic.Verify.Selector$", (context.selectItemIdx + 1).s)
            for (idx, btn) in view.itemButtons.enumerated() {
                btn.title = context.options[idx]
                btn.bind(self, action: #selector(onClick(_:)), forControlEvents: .touchUpInside)
            }
        }
        
        @objc func onClick(_ sender: UIButton) { 
            self.selectedButton?.gradientBGLayer.isHidden = true
            self.selectedButton = sender
            self.selectedButton?.gradientBGLayer.isHidden = false
            didSelectedHandler?(isPassed)
        }
    }
}

