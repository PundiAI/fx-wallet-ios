//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit

extension SetLanguageViewController {
    
    class ItemCell: FxTableViewCell {
        
        override class func height(model: Any?) -> CGFloat { return 60.auto() }
        
        lazy var selectIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var titleLabel: UILabel = {
            let v = UILabel(XWallet.Font(ofSize: 16, weight: .bold), .white, .left)
            return v
        }()
        
        override func configuration() {
             super.configuration()
            selectIcon.image = IMG("selectedW")
            selectIcon.tintColor = .white
        }
        
        override func layoutUI() {
            
            addSubview(selectIcon)
            addSubview(titleLabel)
            
            selectIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalTo(14.auto())
                make.centerY.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.top.bottom.equalToSuperview()
                make.left.equalTo(selectIcon.snp.right).offset(12.auto())
            }
        }
        
        override func update(model: Any?) {
            if let vm = model as? CellViewModel {
                titleLabel.text = vm.item.title
                
                vm.selected.asDriver()
                .distinctUntilChanged()
                .drive(onNext: {[weak self] state in
                   self?.selectIcon.isHidden = !state
//                    vm.item.selected = state
                })
                .disposed(by: reuseBag)
            }
        }
    }
}

