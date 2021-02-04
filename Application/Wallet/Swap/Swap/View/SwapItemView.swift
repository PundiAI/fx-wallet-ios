//
//
//  XWallet
//
//  Created by May on 2020/10/13.
//  Copyright © 2020 May All rights reserved.
//

import WKKit
import AloeStackView
import RxCocoa
import RxSwift
import TrustWalletCore
import Web3

extension SwapViewController {
    
    class RateItemView: UIView {
        
        lazy var tokenIV = CoinImageView(size: CGSize(width: 16, height: 16).auto())
        lazy var exchangeLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            //            v.autoFont = true
            v.textColor = .white
            v.textAlignment = .left
            return v
        }()
        
        lazy var coinPairLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            //            v.autoFont = true
            v.textColor = .white
            v.textAlignment = .center
            return v
        }()
        
        
        lazy var rateLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            //            v.autoFont = true
            v.textColor = .white
            v.textAlignment = .right
            return v
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .clear
            tokenIV.backgroundColor = HDA(0x080A32)
            tokenIV.autoCornerRadius = 8
            tokenIV.borderWidth = 1
            tokenIV.borderColor = HDA(0x2D2D40)
        }
        
        private func layoutUI() {
            
            addSubviews([tokenIV, exchangeLabel, coinPairLabel, rateLabel])
            
            tokenIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16, height: 16).auto())
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            exchangeLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.height.equalTo(17.auto())
                make.left.equalTo(tokenIV.snp.right).offset(8.auto())
            }
            
            coinPairLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(17.auto())
            }
            
            rateLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.height.equalTo(17.auto())
                make.right.equalToSuperview()
                make.left.greaterThanOrEqualTo(coinPairLabel.snp.right).offset(8.auto()).priority(.high)
            }
        }
        
        func update(model: (String, String, String, String)) {
            exchangeLabel.text = model.1
            coinPairLabel.text = model.2
            rateLabel.text = model.3
        }
        
        func update(model: Rate) {
            exchangeLabel.text = model.title
            coinPairLabel.text = model.subTitle
            rateLabel.text = model.rate.thousandth(8, mb: true)
            tokenIV.setImage(urlString: model.exchangeImageUrl, placeHolderImage: IMG("Dapp.Placeholder"))
        }
    }
}



extension SwapViewController {
    class RateView: UIView {
        lazy var contentView = UIView(COLOR.title)
        lazy var leftline = UIView(HDA(0xFFFFFF).withAlphaComponent(0.1))
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.Top.Price")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            return v
        }()
        lazy var rightLine = UIView(HDA(0xFFFFFF).withAlphaComponent(0.1))
        
        public lazy var stackView: AloeStackView = {
            let view = AloeStackView()
            view.automaticallyHidesLastSeparator = false
            view.rowInset = UIEdgeInsets.zero
            view.separatorHeight = 5
            view.separatorColor = UIColor.clear
            view.backgroundColor = .clear
            return view
        }()
         
        lazy var arrowIV =  UIButton()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            contentView.autoCornerRadius = 16
            arrowIV.setImage(IMG("Swap.Up.Gray"), for: .normal)
        }
        
        private func layoutUI() {
            addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.bottom.equalToSuperview()
            }
            
            contentView.addSubviews([leftline, titleLabel, rightLine, stackView, arrowIV])
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(16.auto())
            }
            
            leftline.snp.makeConstraints { (make) in
                make.height.equalTo(1)
                make.left.equalToSuperview().offset(16.auto())
                make.right.equalTo(titleLabel.snp.left).offset(-11.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            
            rightLine.snp.makeConstraints { (make) in
                make.height.equalTo(1)
                make.right.equalToSuperview().offset(-16.auto())
                make.left.equalTo(titleLabel.snp.right).offset(11.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            
            stackView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16.auto())
                make.right.equalToSuperview().offset(-40.auto())
                make.bottom.equalToSuperview().inset(16.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(16)
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16, height: 15).auto())
                make.right.equalToSuperview().offset(-16.auto())
                make.top.equalTo(stackView.snp.top).offset((21 - 15).auto())
            }
        }
    }
}




extension SwapViewController {
    class FoldRateView: UIView {
        
        lazy var contentView = UIView(COLOR.title)
        
        lazy var leftline = UIView(HDA(0x373737).withAlphaComponent(0.6))
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.Top.Price")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = UIColor.white.withAlphaComponent(0.5)
            return v
        }()
        
        lazy var rightLine = UIView(HDA(0x373737).withAlphaComponent(0.6))
        
        lazy var rate0: RateItemView = {
            let v = RateItemView(size: CGSize(width: ScreenWidth, height: 21.auto()))
            v.exchangeLabel.text = "CMC"
            return v
        }()
        
        private lazy var priceContainer = UIView(.clear)
        
        lazy var arrowIV =  UIImageView()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            contentView.autoCornerRadius = 16
            arrowIV.image = IMG("Swap.Down.Gray")
            priceItemViews = [rate0]
        }
        
        private func layoutUI() {
            addSubview(contentView)
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(8.auto())
                make.height.equalTo(86.auto())
            }
            
            contentView.addSubviews([leftline, titleLabel, rightLine, priceContainer, arrowIV])
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(16.auto())
            }
            
            leftline.snp.makeConstraints { (make) in
                make.height.equalTo(1)
                make.left.equalToSuperview().offset(16.auto())
                make.right.equalTo(titleLabel.snp.left).offset(-11.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            
            rightLine.snp.makeConstraints { (make) in
                make.height.equalTo(1)
                make.right.equalToSuperview().offset(-16.auto())
                make.left.equalTo(titleLabel.snp.right).offset(11.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            
            priceContainer.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview().offset(-40.auto())
                make.height.equalTo(21.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(16)
            }
            
            arrowIV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16, height: 15).auto())
                make.right.equalToSuperview().offset(-16.auto())
                make.centerY.equalTo(priceContainer.snp.centerY)
            }
            
            priceContainer.addSubview(rate0)
            rate0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        private var priceItemViews: [RateItemView] = []
        private var currentPriceView: RateItemView?
        private var timer: Timer?
        
        func updatePriceItem(rate : Rate) {
            let itemView = priceItemViews.first{ $0.exchangeLabel.text == rate.exchange.uppercased() }
            if itemView != nil {
                itemView?.update(model: rate)
            } else {
                let itemView = RateItemView(size: CGSize(width: ScreenWidth-40.auto(), height: 21.auto()))
                itemView.update(model: rate)
                itemView.alpha = 0
                priceItemViews.append(itemView)
                priceContainer.insertSubview(itemView, at: 0)
                
                itemView.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
        }
        
        func reset() {
            priceItemViews = [rate0]
            for view in priceContainer.subviews {
                view.removeFromSuperview()
            }
            currentPriceView = nil
            timer?.invalidate()
            priceContainer.addSubview(rate0)
            rate0.alpha = 1
            rate0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        func startPriceLoopIfNeed() {
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
        
        private func switchPriceView(_ view: RateItemView) {
            if currentPriceView == nil { currentPriceView = rate0 }
            if currentPriceView == view { return }
            
            let old = currentPriceView!
            currentPriceView = view
            
            currentPriceView?.alpha = 1
            currentPriceView?.frame = CGRect(x: 0, y: priceContainer.height, width: priceContainer.width, height: priceContainer.height)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                old.origin.y = -old.height
                self.currentPriceView?.origin.y = 0
            })
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                old.alpha = 0
            })
        }
        
        deinit {
            timer?.invalidate()
        }
    }
}


extension SwapViewController {
    class ApprovePanel: UIView {
        class ItemView: UIView {
            lazy var buttonView = UIButton().doNormal(title: TR("-"))
            lazy var indexView = UIButton().doNormal(title: "-").then { $0.isUserInteractionEnabled = false }
            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            override init(frame: CGRect) {
                super.init(frame: frame)
                logWhenDeinit()
                addSubviews([buttonView, indexView])
                buttonView.autoCornerRadius = 28
                indexView.autoCornerRadius = 10
                
                buttonView.snp.makeConstraints { (make) in
                    make.top.right.left.equalToSuperview()
                    make.height.equalTo(56.auto())
                }
                
                indexView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 20, height: 20).auto())
                    make.centerX.equalToSuperview()
                    make.top.equalTo(buttonView.snp.bottom).offset(8.auto())
                }
            }
            
            func set(title:String, enable:Bool,  waiting:Bool = false) {
                buttonView.title = title
                buttonView.isEnabled = enable
                indexView.isEnabled = enable
            }
        }
        
        class ApproveItemView: ItemView {
            lazy var indicatorView: UIActivityIndicatorView = {
                let view = UIActivityIndicatorView(style:.gray)
                view.hidesWhenStopped = true
                return view
            }()
            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            override init(frame: CGRect) {
                super.init(frame: frame)
                logWhenDeinit()
                addSubview(indicatorView)
                indicatorView.snp.makeConstraints { (make) in
                    make.size.equalTo(CGSize(width: 25, height: 25))
                    make.centerY.equalTo(buttonView)
                    make.right.equalToSuperview().offset(-10)
                }
            }
            
            override func set(title:String, enable:Bool, waiting:Bool = false) {
                super.set(title: title, enable: enable, waiting:waiting)
                
                waiting ? indicatorView.startAnimating() : indicatorView.stopAnimating()
                buttonView.alpha = waiting ? 0.6 : 1.0
            }
        }
        
        lazy var messageButton = ApproveItemView(frame:CGRect.zero).then {
            $0.set(title: TR("----"), enable: false, waiting: false)
            $0.indexView.title = TR("-")
            $0.indexView.alpha = 0
        }
        
        lazy var approveButton = ApproveItemView(frame:CGRect.zero).then {
            $0.set(title: TR("Button.Approve"), enable: true, waiting: false)
            $0.indexView.title = TR("1")
        }
        
        lazy var swapButton = ItemView(frame:CGRect.zero).then {
            $0.buttonView.title = TR("Button.Swap")
            $0.indexView.title = TR("2")
        }
        
        lazy var line = UIView(.clear)
        var isComplated:Bool = false
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
        }
        
        private func layoutUI() {
            self.addSubviews([line, approveButton, swapButton, messageButton])
            
            approveButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(24.auto())
                make.right.equalTo(self.snp.centerX).offset(-8.auto())
                make.centerY.equalToSuperview()
            }
            
            swapButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.left.equalTo(self.snp.centerX).offset(8.auto())
                make.centerY.equalToSuperview()
            }
             
            messageButton.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo((28 + 56).auto())
                make.centerY.equalToSuperview()
            }
        }
        
        private func gradient(_ line: UIView) {
            line.layer.sublayers?.each { (layer) in
                layer.removeFromSuperlayer()
            }
            
            let fpoint = approveButton.convert(approveButton.indexView.center, to: self)
            let tpoint = swapButton.convert(swapButton.indexView.center, to: self)
            line.frame = CGRect(x: fpoint.x, y: fpoint.y, width: tpoint.x - fpoint.x, height: 1)
            let gradientLine = CAGradientLayer()
            
            let fromColor = isComplated ? COLOR.title : approveButton.indexView.backgroundImageColor
            let toColor = swapButton.indexView.backgroundImageColor
            
            gradientLine.frame = CGRect(x: 0, y: 0, width: line.width, height: 1)
            gradientLine.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLine.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLine.colors = [fromColor.cgColor, toColor.cgColor]
            line.layer.addSublayer(gradientLine)
            line.isHidden = approveButton.indexView.isHidden
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradient(line)
        }
    }
}


extension SwapViewController {
    class RounterView: UIView, UICollectionViewDelegateFlowLayout {
        class PathItemCell: UICollectionViewCell {
            lazy var tokenIV = CoinImageView(size: CGSize(width: 24, height: 24).auto())
            lazy var stackView = UIStackView(frame: CGRect.zero)
            
            lazy var titleLabel: UILabel = {
                let v = UILabel()
                v.text = TR("Uniswap.Route")
                v.font = XWallet.Font(ofSize: 14)
                v.textColor = COLOR.title
                return v
            }()
            
            lazy var icon: UIImageView = {
                let v = UIImageView()
                v.image = IMG("setting.nextB")
                return v
            }()
            
            required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            override init(frame: CGRect) {
                super.init(frame: frame)
                logWhenDeinit()
                
                configuration()
                layoutUI()
            }
            
            private func configuration() {
                backgroundColor = .clear
                stackView.axis = .vertical
                stackView.spacing = 6.auto()
                stackView.alignment = .center
                stackView.distribution = .fillProportionally
            }
            
            private func layoutUI() {
                addSubview(stackView)
                stackView.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                stackView.addArrangedSubview(tokenIV)
                stackView.addArrangedSubview(titleLabel)
                stackView.addArrangedSubview(icon)
                tokenIV.width(constant: 24.auto())
                tokenIV.height(constant: 24.auto())
                icon.width(constant: 24.auto())
                icon.height(constant: 24.auto())
            }
        }
        
        
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Uniswap.Route")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()
        
        lazy var helpBtn: UIButton = {
            let button = UIButton()
            button.setImage(IMG("Swap.Help"), for: .normal)
            return button
        }()
        
        lazy var contentView = UIView(COLOR.settingbc)
        
        private let itemsObserver = BehaviorRelay<[RouterModel]>(value: [])
        lazy var collectionView: UICollectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.sectionInset = UIEdgeInsets.zero
            flowLayout.minimumInteritemSpacing = 4.auto()
            flowLayout.minimumLineSpacing = 14.auto()
            let view = UICollectionView(frame: CGRect.zero,
                                        collectionViewLayout: flowLayout)
            view.backgroundColor = UIColor.clear
            view.register(PathItemCell.self, forCellWithReuseIdentifier: "Cell")
            return view
        }()
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            contentView.autoCornerRadius = 16
        }
        
        private func layoutUI() {
            addSubviews([titleLabel, helpBtn, contentView, collectionView])
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(40.auto())
                make.height.equalTo(17.auto())
            }
            
            helpBtn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 16, height: 16).auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
                make.right.equalToSuperview().offset(-40.auto())
            }
            
            contentView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.bottom.equalToSuperview()
            }
            
            collectionView.snp.makeConstraints { (make) in
                make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 10.auto(), left: 16.auto(), bottom: 10.auto(), right: 16.auto()))
            }
            
            itemsObserver.map {[weak self] (items) -> [(RouterModel, Bool)] in
                return self?.mapRouterData(items: items) ?? []
            }.bind(to: collectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PathItemCell
                cell.titleLabel.text = element.0.token
                cell.tokenIV.setImage(urlString: element.0.path, placeHolderImage: IMG("Dapp.Placeholder"))
                cell.icon.isHidden = element.1 == false
                return cell
            }.disposed(by: defaultBag)
            
            collectionView.rx.setDelegate(self).disposed(by: defaultBag)
        }
        
        private func mapRouterData(items: [RouterModel]) ->[(RouterModel, Bool)] {
            let count = items.count
            var _items = [(RouterModel, Bool)]()
            items.each { (index, it) in
                _items.append( (it, index < (count - 1)))
            }
            return _items
        }
        
        func bindRouter(tags: [RouterModel]) {
            itemsObserver.accept(tags)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let items = mapRouterData(items: itemsObserver.value)
            if  let item = items.get(indexPath.row) {
                let router = item.0
                let hasNext = item.1
                let buttonHeihgt: CGFloat = 28.auto()
                let cellWidth = router.token.size(with: CGSize(width: ScreenWidth, height: buttonHeihgt),
                                                font: XWallet.Font(ofSize: 14)).width + (24 + (hasNext ? 24 : 0) + 4).auto()
                return CGSize(width: cellWidth, height: buttonHeihgt)
            }
            return CGSize.zero
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            var totalWidth:CGFloat = 0
            
            let lineSpacing: CGFloat = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
            let InteritemSpacing: CGFloat = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
            let count:Int = itemsObserver.value.count
            let totalSpacingWidth = InteritemSpacing * CGFloat(((count - 1) < 0 ? 0 : count - 1))
            
            totalWidth += totalSpacingWidth
            let mu:CGFloat = CGFloat(SwapViewController.RounterView.lineCount(itemsObserver.value))
            let totalHeight:CGFloat =  (mu * 28 +  (mu - 1) * lineSpacing).auto()
            itemsObserver.value.each { (index, _) in
                let size:CGSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(item: index, section: 0))
                totalWidth += size.width  
            }
      
            let xInset:CGFloat = max(floor((collectionView.width - totalWidth) / 2.0),0)
            let yInset:CGFloat = max(floor((collectionView.height - totalHeight) / 2.0),0)
            return UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: yInset)
        }
        
        static func lineCount(_ model:[RouterModel]) ->Int {
            var mu = 1
            if model.count != 0 {
                let row = model.count % 3
                mu = model.count / 3
                if row != 0 {
                    mu = mu + 1
                }
            }
            return mu
        }
        
        static func height(model: [RouterModel]) -> CGFloat {
            let mu = lineCount(model)
            let contentHeight =  mu * 28 +  (mu - 1) * 14
            return (17 + 8 + 10 + 28 + contentHeight).auto()
        }
        
    }
}
