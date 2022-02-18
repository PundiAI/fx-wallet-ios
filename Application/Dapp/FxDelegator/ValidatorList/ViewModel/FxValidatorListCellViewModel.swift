//
//
//  XWallet
//
//  Created by May on 2021/1/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxSwift
import RxCocoa
import SwiftyJSON

extension FxValidatorListViewController {
    class ValidatorsCellViewModel {
        
        init(_ rawValue: Validator) {
            self.rawValue = rawValue
        }

        let rawValue: Validator
        
        var height: CGFloat { size.height }
        var corners: (Bool, Bool) = (false, false)
        lazy var size = CGSize(width: ScreenWidth - 24.auto() * 2, height: 74.auto())
        
        var rewardsFormatter: NSMutableAttributedString {
            
            let vm = String(format: "%.2f%@", self.rawValue.rewards.f, "% APY")
            let attr = NSMutableAttributedString(string: vm, attributes: [.font: XWallet.Font(ofSize: 16),
                                                                          .foregroundColor: HDA(0x71A800)])
            
            let rangBlock: ((String, String) -> NSRange?) = {(text, subText) in
                if let range: Range<String.Index> = text.range(of: subText) {
                    return text.convert(range: range)
                }
                return nil
            }
            if let rang = rangBlock(vm, "APY") {
                attr.addAttributes([.font: XWallet.Font(ofSize: 16),
                                    .foregroundColor: HDA(0x999999)], range: rang)
            }
            return attr
        }
    }
}
        
