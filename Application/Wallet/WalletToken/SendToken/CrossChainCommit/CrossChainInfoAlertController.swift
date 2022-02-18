//
//  CrossChainInfoAlertController.swift
//  fxWallet
//
//  Created by HeiHuaBaiHua on 2021/5/14.
//  Copyright © 2021 Andy.Chan 6K. All rights reserved.
//

import WKKit
import Macaw

extension CrossChainInfoAlertController {
    class override func instance(with context: [String : Any]) -> UIViewController? {
        guard let isE2F = context["isE2F"] as? Bool else { return nil }
        
        let vc = CrossChainInfoAlertController()
        vc.isE2F = isE2F
        return vc
    }
}

class CrossChainInfoAlertController: FxPopViewController {
    
    override func getView() -> FxPopViewController.BaseView {
        super.getView().then {
            _ = $0.mainView.backgroundColor(Color.white)
                .border(Color.clear, 0)
        }
    }
    
    var isE2F = true
    lazy var listBinder = WKStaticTableViewBinder(view: wk.view.listView)
    override func viewDidLoad() {
        super.viewDidLoad()
        let text = self.isE2F ? TR("CrossChain.E2F.Tip") : TR("CrossChain.F2E.Tip")
        let contentCell = listBinder.push(ContentCell.self, vm: text){
            $0.descLabel.text = text
            $0.addressLabel.text = ThisAPP.FxConfig.bridge()
        }
        listBinder.push(ActionCell.self).submitButton.action { [weak self] in
            self?.dismiss()
        }
        listBinder.push(WKSpacingCell.self, vm: WKSpacing(height: PopBottom))
        
        contentCell.helpButton.action {
            Router.showRevWebViewController(url: ThisAPP.WebURL.helpFxCrossChainURL)
        }
        
        let contentHeight = wk.view.navBarHeight + listBinder.estimatedHeight
        wk.view.mainView.snp.remakeConstraints { (make) in
            make.height.equalTo(contentHeight)
            make.bottom.left.right.equalToSuperview()
        }
        
        wk.view.listView.snp.remakeConstraints { (make) in
            make.top.equalTo(wk.view.navBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func dismiss(userCanceled: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil) {
        Router.pop(self)
    }
    
    override func layoutUI() {
        super.layoutUI()
        wk.view.navBar.backButton.image = IMG("Menu.Close")
        wk.view.navBar.backButton.tintColor = COLOR.title
    }
}

extension CrossChainInfoAlertController {
    class ContentCell: FxTableViewCell {
        
        private lazy var titleLabel = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 24, weight: .medium), textColor: COLOR.title)
        fileprivate lazy var descLabel = UILabel(text: TR("CrossChain.E2F.Tip"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        fileprivate lazy var helpButton: UIButton = {
            let v = UIButton()
            let attText = NSAttributedString(string: TR("LearnMore"), attributes: [.font: XWallet.Font(ofSize: 14, weight: .medium), .foregroundColor: COLOR.title, .underlineColor: COLOR.title, .underlineStyle: NSUnderlineStyle.single.rawValue])
            v.setAttributedTitle(attText, for: .normal)
            return v
        }()
        
        private lazy var addressBGView = UIView(HDA(0xF0F3F5), cornerRadius: 16)
        private lazy var addressTitleLabel = UILabel(text: TR("CrossChain.AddressTitle"), font: XWallet.Font(ofSize: 12), textColor: COLOR.subtitle)
        fileprivate lazy var addressLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title).then{ $0.lineBreakMode = .byTruncatingMiddle }
        private lazy var arrowIV = UIImageView(image: IMG("ic_arrow_right"))
        
        override class func height(model: Any?) -> CGFloat {
            let textString = model as? String ?? TR("CrossChain.E2F.Tip")
            let descHeight = textString.height(ofWidth: ScreenWidth - 24.auto() * 2, attributes: [.font: XWallet.Font(ofSize: 14)])
            let height = (157).auto() + descHeight
            return height
        }
        
        override func layoutUI() {
            contentView.backgroundColor = UIColor.yellow
            contentView.addSubviews([titleLabel, descLabel, helpButton, addressBGView, addressTitleLabel, addressLabel, arrowIV])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(24.auto())
                make.height.equalTo(29.auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            helpButton.snp.makeConstraints { (make) in
                make.top.equalTo(descLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(17.auto())
            }
            
            addressBGView.snp.makeConstraints { (make) in
                make.top.equalTo(helpButton.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(71.auto())
            }
            
            addressTitleLabel.snp.makeConstraints { (make) in
                make.top.left.equalTo(addressBGView).offset(16.auto())
                make.height.equalTo(14.auto())
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(addressBGView).offset(16.auto())
                make.right.equalTo(arrowIV.snp.left).offset(-16.auto())
                make.height.equalTo(17.auto())
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.centerY.equalTo(addressBGView)
                make.right.equalTo(addressBGView).offset(-22.auto())
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
        }
    }
}

extension CrossChainInfoAlertController {
    class ActionCell: WKTableViewCell.ActionCell {
        
        override func configuration() {
            super.configuration()
            submitButton.bgImage = UIImage.createImageWithColor(color: COLOR.title)
            submitButton.titleColor = .white
            submitButton.title = TR("OK")
        }
    }
}
