 
import WKKit

extension SheetWebViewController {
    class ContentCell: FxTableViewCell {
        
        lazy var closeButton: UIButton = {
            let v = UIButton()
            v.image = IMG("ic_close_white")
            v.backgroundColor = .clear
            return v
        }()
        
        private lazy var tipBackground = UIView(.white).then { $0.autoCornerRadius = 28 }
        private lazy var tipIV = UIImageView(image: IMG("Tx.CrossChain"))
        
        private lazy var noticeLabel1: UILabel = {
            let v = UILabel(text: TR("CrossChain.TxTitle"), font: XWallet.Font(ofSize: 24, weight: .medium))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        private lazy var noticeLabel2: UILabel = {
            let v = UILabel(text: TR("CrossChain.TxSubTitle"), font: XWallet.Font(ofSize: 14), textColor: UIColor.white.withAlphaComponent(0.5))
            v.textAlignment = .center
            v.autoFont = true
            v.numberOfLines = 0
            return v
        }()
        
        override class func height(model: Any?) -> CGFloat {
            
            let width = ScreenWidth - 24 * 2 - 24 * 2
            
            let font1:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 24, weight: .medium)
                $0.text = TR("CrossChain.TxTitle")
                $0.autoFont = true }.font
            
            let font2:UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = TR("CrossChain.TxSubTitle")
                $0.autoFont = true }.font
            
            let noticeHeight1 = TR("CrossChain.TxTitle").height(ofWidth: width, attributes: [.font: font1])
            let noticeHeight2 = TR("CrossChain.TxSubTitle").height(ofWidth: width, attributes: [.font: font2])
            return (72 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2)
        }
        
        override func layoutUI() {
            contentView.addSubviews([closeButton, tipBackground, tipIV, noticeLabel1, noticeLabel2])
            
            closeButton.snp.makeConstraints { (make) in
                make.top.left.equalTo(16.auto())
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            
            
            tipBackground.snp.makeConstraints { (make) in
                make.top.equalTo(72.auto())
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 56, height: 56).auto())
            }
            
            tipIV.snp.makeConstraints { (make) in
                make.center.equalTo(tipBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            noticeLabel1.snp.makeConstraints { (make) in
                make.top.equalTo(tipBackground.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            noticeLabel2.snp.makeConstraints { (make) in
                make.top.equalTo(noticeLabel1.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}


extension SheetWebViewController {
    
    class ActionCell: WKTableViewCell.DoubleActionVCell {
        
        var ethereum: UIButton { topActionButton }
        var functionX: UIButton { bottomActionButton }
        
        override func configuration() {
            super.configuration()
            
            ethereum.title = TR("Button.View.Ethereum")
            functionX.title = TR("Button.View.FunctionX")
            functionX.titleColor = .white
            functionX.backgroundColor = HDA(0x31324A)
            ethereum.isEnabled = false
            functionX.isEnabled = false
            functionX.disabledTitleColor = UIColor.white.withAlphaComponent(0.1)
            functionX.setBackgroundImage(UIImage.createImageWithColor(color: HDA(0x31324A).withAlphaComponent(0.1)), for: .disabled)
            ethereum.disabledTitleColor = COLOR.title.withAlphaComponent(0.1)
            ethereum.setBackgroundImage(UIImage.createImageWithColor(color: UIColor.white.withAlphaComponent(0.1)), for: .disabled)
        }
    }
}

