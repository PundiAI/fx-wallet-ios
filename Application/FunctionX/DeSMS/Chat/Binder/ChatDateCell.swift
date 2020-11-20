//
//  ChatDateCell.swift
//  XWallet
//
//  Created by HeiHua BaiHua on 2020/4/7.
//  Copyright © 2020 Andy.Chan 6K. All rights reserved.
//

import WKKit

extension ChatViewController {
    class DateCell: Cell {
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? DateCellViewModel else { return }

            dateLabel.text = vm.dateText
        }

        override public func initSubView() {
            layoutUI()
            configuration()

            logWhenDeinit()
        }

        override func layoutUI() {
            contentView.addSubview(dateLabel)
            dateLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        lazy var dateLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 12)
            v.textColor = .white
            v.textAlignment = .center
            v.backgroundColor = .clear
            return v
        }()
    }
}
