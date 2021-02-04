//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit
import UIKit

class CoinTitleView: UIButton {
    lazy var nameLabel = UILabel(font: XWallet.Font(ofSize: 18), textColor: COLOR.title, alignment: .center)
    lazy var tokenButton = CoinTypeView()
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([nameLabel, tokenButton])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let left:CGFloat = superview?.left ?? 87
        let center:CGFloat = ScreenWidth * 0.5 - left
        nameLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(8)
            make.centerX.equalTo(center)
            make.height.equalTo(20)
        }
         
        tokenButton.snp.remakeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalTo(center)
        }
//        if self.superview != nil {
//            self.snp.remakeConstraints {
//                $0.centerX.centerY.equalToSuperview()
//                $0.bottom.lessThanOrEqualToSuperview()
//                $0.top.greaterThanOrEqualToSuperview()
//            }
//        }
    }
}


extension TokenInfoViewController {
    class View: UIView {
        let tabBarView = UIImageView()
        lazy var topContentView: UIView = {
            let v = UIView(UIColor.white)
            v.autoCornerRadius = 40
            return v
        }()
        
        lazy var listView: WKTableView = {
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.gestureFilter = { _, _ in true }
            v.clipsToBounds = false
            v.contentInsetAdjustmentBehavior = .never
            v.bounces = false
            return v
        }()
        
        var headerCell:HeaderCell!
        lazy var titleView = CoinTitleView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 160, height: NavBarHeight))
        var titleLabel: UILabel { titleView.nameLabel }
        var tokenButton : CoinTypeView { titleView.tokenButton }
         
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        init(frame: CGRect, buyBlock:@escaping ()->Bool, assetBlock:@escaping ()->Bool) {
            super.init(frame: frame)
            logWhenDeinit()
            headerCell = HeaderCell(style: .default, reuseIdentifier: nil,
                                    buyBlock: buyBlock, assetBlock: assetBlock)
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = HDA(0x080A32)
        }
        
        private func layoutUI() {
            addSubview(listView)
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            addSubview(tabBarView)
        }
    }
}
        
extension TokenInfoViewController {
    
    class HeaderCell: FxTableViewCell {
        
        var displayHeight: CGFloat { estimatedHeight + FullNavBarHeight } //additional height for display
        lazy var estimatedHeight: CGFloat = (balanceInfoHeight + tokenInfoHeight + (showBuyButtonBlock() ? buyButtonHeight : 0))
        private var balanceInfoHeight: CGFloat { (20 + 58 + 5 + 19 + 40).auto() }
        private var tokenInfoHeight: CGFloat {
            var height = (24.0 * 2.0) + (18.0 * 3.0) + (8.0 * 2.0)
            height += (showAssetIdBlock() ? (18 + 8) : 0)
            return height.auto()
        }
        private lazy var buyButtonHeight:CGFloat = (36 + 6).auto()
        var showBuyButtonBlock:() ->Bool = {
            return false
        }
        
        var showAssetIdBlock:() ->Bool = {
            return false
        }
        
        lazy var balanceInfoView = UIView(.clear)
        
        lazy var aBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            view.autoCornerRadius = 36
            return view
        }()
        
        lazy var balanceLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var legalBalanceLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 48)
            v.textColor = HDA(0x080A32)
            v.textAlignment = .center
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var buyButton: UIButton = {
            let b = UIButton()
            b.backgroundColor = HDA(0x080A32)
            b.titleFont = XWallet.Font(ofSize: 16)
            b.titleColor = UIColor.white
            b.autoCornerRadius = (36/2.0)
            b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return b
        }()
        
        lazy var tokenInfoBackView: UIView = {
            let v = UIView(HDA(0xF4F4F4))
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: tokenInfoHeight)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight] ,
                                          cornerRadii: CGSize(width: 36, height: 36).auto()).cgPath
            v.frame = bounds
            v.layer.mask = maskLayer
            v.layer.masksToBounds = true
            return v
        }()
        
        lazy var tokenInfoContentView = UIView()
        
        lazy var infoArrowIV = UIImageView(image: IMG("ic_arrow_right"))
        lazy var infoActionButton = UIButton(.clear)
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        
        private lazy var priceContainer = UIView(HDA(0xF4F4F4))
        var cmcPriceLabel: UILabel { cmcPriceItemView.textLabel }
        var cmcRateLabel: UILabel { cmcPriceItemView.rateLabel }
        lazy var cmcPriceItemView: ScrollInfoItemView = {
            let v = ScrollInfoItemView(size: CGSize(width: ScreenWidth, height: 18.auto()))
            v.textLabel.text = "$ --"
            v.set(name: "CMC")
            return v
        }()
        
        var marketLabel: UILabel { marketItemView.textLabel }
        private lazy var marketItemView: InfoItemView = {
            let v = InfoItemView(size: CGSize(width: ScreenWidth, height: 18.auto()))
            v.titleLabel.text = TR("Token.Cap")
            v.textLabel.text = "$ \(unknownAmount)"
            return v
        }()
        
        var rankLabel: UILabel { rankItemView.textLabel }
        private lazy var rankItemView: InfoItemView = {
            let v = InfoItemView(size: CGSize(width: ScreenWidth, height: 18.auto()))
            v.titleLabel.text = TR("Token.Rank")
            v.textLabel.text = fxTextPlaceholder
            return v
        }()
        
        var assetLabel: UILabel { assetItemView.textLabel }
        private lazy var assetItemView: InfoItemView = {
            let v = InfoItemView(size: CGSize(width: ScreenWidth, height: 18.auto()))
            v.titleLabel.text = "\(TR("AssetId")):"
            v.textLabel.text = fxTextPlaceholder
            return v
        }()
        
        init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, buyBlock:@escaping ()->Bool, assetBlock:@escaping ()->Bool) {
            self.showBuyButtonBlock = buyBlock
            self.showAssetIdBlock = assetBlock
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
         
        override func configuration() {
            super.configuration()
            backgroundColor = UIColor.clear
            tokenInfoContentView.layer.masksToBounds = true
            
            infoArrowIV.isHidden = true
            priceContainer.layer.masksToBounds = true
            priceItemViews = [cmcPriceItemView]
        }
        
        override func layoutUI() {
            insertSubview(aBackgroundView, at: 0)
            contentView.addSubviews([balanceInfoView, tokenInfoBackView, tokenInfoContentView])
            balanceInfoView.addSubviews([balanceLabel, legalBalanceLabel, buyButton])
            tokenInfoContentView.addSubviews([tokenIV, priceContainer, marketItemView, rankItemView, assetItemView, infoArrowIV, infoActionButton])
            priceContainer.addSubviews([cmcPriceItemView])
            
            aBackgroundView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            let showBuy = showBuyButtonBlock()
            balanceInfoView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(tokenInfoContentView.snp.top)
                make.height.equalTo(balanceInfoHeight + (showBuy ? buyButtonHeight : 0))
            }
            
            legalBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(20.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(58.auto())
            }
            
            balanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(legalBalanceLabel.snp.bottom).offset(6.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(19.auto())
            }
             
            buyButton.isHidden = !showBuy 
            buyButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.height.equalTo(36.auto())
                make.top.equalTo(balanceLabel.snp.bottom).offset(24.auto())
            }
            
            //tokenInfoView...b
            tokenInfoBackView.snp.makeConstraints { (make) in
                make.edges.equalTo(tokenInfoContentView)
            }
            
            tokenInfoContentView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(tokenInfoHeight)
            }
            
            infoArrowIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-23)
            }
            
            infoActionButton.snp.makeConstraints { (make) in
                make.edges.equalTo(tokenInfoContentView)
            }
            
            tokenIV.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            
            priceContainer.snp.makeConstraints { (make) in
                make.top.equalTo(24.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16)
                make.height.equalTo(18.auto())
                make.right.equalTo(-16)
            }
            
            cmcPriceItemView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            marketItemView.snp.makeConstraints { (make) in
                make.top.equalTo(priceContainer.snp.bottom).offset(8.auto())
                make.left.equalTo(tokenIV.snp.right).offset(16)
                make.height.equalTo(18.auto())
                make.right.equalTo(-56)
            }
            
            rankItemView.snp.makeConstraints { (make) in
                make.top.equalTo(marketItemView.snp.bottom).offset(8.auto())
                make.left.equalTo(marketItemView)
                make.height.equalTo(18.auto())
                make.right.equalTo(-56)
            }
            
            let showAsset = showAssetIdBlock()
            assetItemView.isHidden = !showAsset
            assetItemView.snp.makeConstraints { (make) in
                make.top.equalTo(rankItemView.snp.bottom).offset(8.auto())
                make.left.equalTo(marketItemView)
                make.height.equalTo(18.auto())
                make.right.equalTo(-56)
            }
            //tokenInfoView...e
        }
    
        private var priceItemViews: [ScrollInfoItemView] = []
        private var currentPriceView: ScrollInfoItemView?
        private var timer: Timer?
        
        func updatePriceItem(name: String, value: String) {
            if name.uppercased() == "CMC" { return }
            
            let itemView = priceItemViews.first{ $0.name == name.uppercased() }
            if itemView != nil {
                itemView?.textLabel.text = "$ \(value.thousandth(ThisAPP.CurrencyDecimal))"
            } else {
                
                let itemView = ScrollInfoItemView(size: CGSize(width: ScreenWidth, height: 18.auto()))
                itemView.alpha = 0
                itemView.textLabel.text = "$ \(value.thousandth(ThisAPP.CurrencyDecimal))"
                itemView.set(name: name)

                priceItemViews.append(itemView)
                priceContainer.insertSubview(itemView, at: 0)
            }
        }
        
        func startPriceLoopIfNeed() {
            
            cmcPriceItemView.scrollTitleLabel.scroll(true)
            guard priceItemViews.count > 1 else { return }
            
            var index = 0
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self](t) in
                guard let this = self else { t.invalidate(); return }
                guard this.priceItemViews.count > 1 else { return }
                
                index += 1
                if index >= this.priceItemViews.count { index = 0 }
                self?.switchPriceView(this.priceItemViews[index])
            })
        }
        
        private func switchPriceView(_ view: ScrollInfoItemView) {
            if currentPriceView == nil { currentPriceView = cmcPriceItemView }
            if currentPriceView == view { return }
            
            let old = currentPriceView!
            currentPriceView = view
            old.scrollTitleLabel.scroll(false)
            
            currentPriceView?.alpha = 1
            currentPriceView?.frame = CGRect(x: 0, y: priceContainer.height, width: priceContainer.width, height: priceContainer.height)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                old.origin.y = -old.height
                self.currentPriceView?.origin.y = 0
            }, completion: {[weak self] _ in
                self?.currentPriceView?.scrollTitleLabel.scroll(true)
            })
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                old.alpha = 0
            })
        }
        
        deinit {
            timer?.invalidate()
            currentPriceView?.scrollTitleLabel.scroll(false)
        }
    }
}

extension TokenInfoViewController {
    
    class InfoItemView: UIView {
        
        lazy var rateLabel = UILabel(font: XWallet.Font(ofSize: 12, weight: .medium))
        lazy var textLabel = UILabel(font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title)
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title)

        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        func configuration() {
            backgroundColor = .clear
        }
        
        func layoutUI() {
            addSubviews([titleLabel, textLabel, rateLabel])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.bottom.left.equalToSuperview()
                make.width.equalTo(80.auto())
            }
            
            textLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.left.equalTo(titleLabel.snp.right).offset(8.auto())
                make.height.equalTo(18.auto())
            }
            
            rateLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(textLabel).offset(-1)
                make.left.equalTo(textLabel.snp.right).offset(6.auto())
            }
        }
    }
    
    class ScrollInfoItemView: InfoItemView {
        
        var name = ""
        lazy var scrollTitleLabel = FxScrollLabel(size: CGSize(width: 80.auto(), height: 18.auto()))

        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        func set(name: String) {
            self.name = name.uppercased()
            self.scrollTitleLabel.text = TR("Token.Price", self.name)
        }
        
        override func configuration() {
            backgroundColor = .clear
            titleLabel.isHidden = true
            scrollTitleLabel.mode = .bounding
            scrollTitleLabel.offset = 0.1
            scrollTitleLabel.timeInterval = 0.04
        }
        
        override func layoutUI() {
            super.layoutUI()
            addSubview(scrollTitleLabel)
            
            scrollTitleLabel.snp.makeConstraints { (make) in
                make.top.bottom.left.equalToSuperview()
                make.width.equalTo(80.auto())
            }
        }
    }
}


extension TokenInfoViewController {
    
    class FooterCell: FxTableViewCell {
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(_ view: UIView) {
            self.view = view
            super.init(style: .default, reuseIdentifier: nil)
        }
        
        let view: UIView
        override func getView() -> UIView { view }
        
        var estimatedHeight: CGFloat { ScreenHeight - FullNavBarHeight }
    }
}
