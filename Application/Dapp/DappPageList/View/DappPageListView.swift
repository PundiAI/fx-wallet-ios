//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import RxSwift
import XLPagerTabStrip

class DappPageButtonBarCell: UICollectionViewCell {
    
    enum Types {
        case popular
        case favorite
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
    }
    
    override var isSelected: Bool {
        didSet {
//                textLabel.textColor = isSelected ? HDA(0x080A32) : HDA(0x080A32).withAlphaComponent(0.2)
            //textLabel.font = isSelected ? XWallet.Font(ofSize: 32, weight: .bold) : XWallet.Font(ofSize: 24)
//                textLabel.autoFont = true
        }
    }

    var type: Types?
    func bind(_ vm: IndicatorInfo) {
        textLabel.text = vm.title
        self.type = vm.userInfo as? Types
    }

    private func layoutUI() {
        let textHeight = 38.auto()
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(13.auto())
            make.left.right.equalToSuperview()
            make.height.lessThanOrEqualTo(textHeight)
        }
    }

    lazy var textLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 24)
        v.textColor = HDA(0x080A32).withAlphaComponent(0.2)
        v.textAlignment = .center
        v.backgroundColor = .clear
        v.autoFont = true
        v.baselineAdjustment = .alignBaselines
        return v
    }()
}



extension DappPageListViewController {
    class View: UIView {
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
        }
        
        private func layoutUI() {
            
        }
        
    }
}


extension DappPageListViewController {
    
    class PagerTabStriButtonBarViewDecorator {
        
        private let colorView = UIView(HDA(0x080A32))
        private let view: ButtonBarView
        var defaultBag = DisposeBag()
        
        init(view: ButtonBarView) {
            self.view = view
            
            view.selectedBar.backgroundColor = .clear
            view.selectedBar.addSubview(colorView)
            colorView.cornerRadius = 2
            colorView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(4)
            }
        }
        
        var color: UIColor? {
            get { return colorView.backgroundColor }
            set {
                colorView.backgroundColor = newValue
                view.selectedBar.backgroundColor = .clear
            }
        }
        
        var width: CGFloat = 80 {
            didSet {
                if view.selectedBar.width > 0
                    && colorView.width != width {
                    colorView.snp.updateConstraints { (make) in
                        make.width.equalTo(width)
                    }
                    UIView.animate(withDuration: 0.2) {
                        self.view.selectedBar.setNeedsLayout()
                    }
                }
            }
        }
    }
}
