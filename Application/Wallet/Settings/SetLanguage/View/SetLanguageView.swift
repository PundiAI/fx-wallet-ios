//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import RxCocoa
import RxSwift

extension SetLanguageViewController {
    static var messageString1 = TR("Setting.Language.Title")
    static var messageString0 = TR("Setting.Language.SubTitle")
    
    class ContentCell: FxTableViewCell {
        
        lazy var closeButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_close_white")
            v.backgroundColor = .clear
            return v
        }()
        
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: messageString1,
                            font: XWallet.Font(ofSize: 24,
                                               weight: .bold),
                            textColor: .white)
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: messageString0,
                            font: XWallet.Font(ofSize: 14),
                            textColor: UIColor.white.withAlphaComponent(0.5))
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        lazy var tableView: WKTableView = {
            let tableView = WKTableView(frame: CGRect.zero, style: UITableView.Style.plain)
            tableView.isScrollEnabled = false
            return tableView
        }()
        
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2 * 2
            
            let font0 = UILabel().then {
                $0.font = XWallet.Font(ofSize: 24, weight: .bold)
                $0.text = messageString1
                $0.autoFont = true }.font
            let noticeHeight0 = messageString1.height(ofWidth: width, attributes: [.font: font0 as Any])
            
            let font = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = messageString0
                $0.autoFont = true }.font
            let noticeHeight1 = messageString0.height(ofWidth: width, attributes: [.font: font as Any])
            
            return 8.auto() + (16 + 40).auto() + (16.auto() + noticeHeight0) + (8.auto() + noticeHeight1) + 24.auto() + (60 * WKLocale.Shared.languages.count).auto()
        }
        
        override func configuration() {
            super.configuration()
            noticeLabel1.text = TR("Setting.Language.Title")
            noticeLabel2.text = TR("Setting.Language.SubTitle")
        }
        
        override func layoutUI() {
            contentView.addSubviews([closeButton, noticeLabel1, noticeLabel2])
            
            closeButton.snp.makeConstraints { (make) in
                make.top.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(closeButton.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            contentView.addSubview(tableView)
            tableView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalTo(contentView.snp.bottom).offset(-8.auto())
                make.top.equalTo(noticeLabel2.snp.bottom).offset(24.auto())
            }
            
            tableView.autoCornerRadius = 16
            tableView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        }
    }
}


extension SetLanguageViewController {
    
    class ActionCell: WKTableViewCell.ActionCell {
        
        var confirmButton: UIButton { submitButton }
        
        override func configuration() {
            super.configuration()
            confirmButton.title = TR("Button.Confirm")
        }
    }
}


