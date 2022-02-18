

import WKKit
import RxSwift
import RxCocoa

extension FxValidatorOverviewViewController {
    class ListBinder: WKStaticTableViewBinder {
        
        private var expand = false
        func expand(_ v: Bool) {
            guard expand != v else { return }
            self.expand = v
            refresh()
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return expand ? itemCount : 0
        }
    }
}

extension FxValidatorOverviewViewController {
    class Cell: FxTableViewCell {
        
        override class func height(model: Any?) -> CGFloat { 71.auto() }
        
        override func layoutUI() {
            contentView.addSubviews([titleLabel, contentLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(16.auto())
                make.left.equalTo(40.auto())
                make.height.equalTo(14.auto())
            }
            
            contentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(40.auto())
                make.height.equalTo(17.auto())
            }
        }
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        lazy var contentLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
    }
}
                
