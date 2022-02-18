 
import WKKit

extension TokenInfoHistoryListBinder {
    class View: UIView {
        
        private var listTop: CGFloat { topEdge + 12 }
        
        lazy var listContainer: UIView = {
            
            let v = UIView(.white)
            let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - listTop)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight] , cornerRadii: CGSize(width: 40, height: 40)).cgPath
            v.frame = bounds
            v.layer.mask = maskLayer
            return v
        }()
        
        lazy var listView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: UITableView.Style.plain)
            v.separatorStyle = .none
            v.backgroundColor = .white
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            
            v.cornerRadius = 40
            v.estimatedRowHeight = 87
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionFooterHeight = 0
            return v
        }()
        
        private lazy var listHeader = UIView(.white)
        lazy var listFooter = UIView(.white)
        lazy var addAddressButton: UIButton = {
            
            let v = UIButton()
            v.title = TR("Token.History.Earlier")
            v.titleFont = XWallet.Font(ofSize: 16)
            v.titleColor = HDA(0x080A32)
            v.cornerRadius = 28
            v.backgroundColor = HDA(0xF0F3F5)
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
        }
        
        private func layoutUI() {
            
            addSubview(listContainer)
            listContainer.addSubview(listView)
            
            listHeader.size = CGSize(width: ScreenWidth, height: 20)
            listView.tableHeaderView = listHeader
            
            listFooter.size = CGSize(width: ScreenWidth, height: 16 + 56 + 45)
            listFooter.addSubview(addAddressButton)
            listView.tableFooterView = listFooter
            
            listContainer.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: listTop, left: 0, bottom: 0, right: 0))
            }
            
            listView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            addAddressButton.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.right.equalToSuperview().inset(24)
                make.height.equalTo(56)
            }
            
        }
        
    }
}
 
extension TokenInfoHistoryListBinder {
    
    class UpdateStateView: UIView {
        
        enum State: Int {
            case updating = 0
            case updated
        }
        
        lazy var upLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Token.History.Header.Updating")
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var roteImage: FxTxLoadingView = {
            return FxTxLoadingView.loading24().then { $0.loading() }
        }()
        
        lazy var refershBtn: UIButton = {
            let v = UIButton()
            let value = NSAttributedString(string: TR("Token.History.Header.Refresh"),
                                           attributes: [.font : XWallet.Font(ofSize: 14, weight: .bold),
                                                        .foregroundColor: HDA(0x080A32),
                                                        .underlineStyle: NSUnderlineStyle.single.rawValue])
            v.setAttributedTitle(value, for: .normal)
            return v
        }()
        
        var dataType = State.updating {
            didSet {
                switch dataType {
                case .updating:
                    roteImage.isHidden = false
                    refershBtn.isHidden = true
                    break
                case .updated:
                    roteImage.isHidden = true
                    refershBtn.isHidden = false
                    break
                }
                relayout()
            }
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            self.backgroundColor = .white
            refershBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8).auto()
        }
        
        private func layoutUI() {
            self.addSubviews([upLabel, roteImage, refershBtn])
            
            upLabel.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.left.equalTo(self.snp.left).offset(24.auto())
                make.top.equalTo(self.snp.top).offset(11.auto())
            }
            
            roteImage.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalTo(upLabel.snp.right).offset(16)
                make.centerY.equalTo(upLabel.snp.centerY)
            }
            
            refershBtn.snp.makeConstraints { (make) in
                make.height.equalTo(20)
                make.left.equalTo(upLabel.snp.right).offset(8)
                make.centerY.equalTo(upLabel.snp.centerY)
            }
        }
        
        private func relayout() {
            switch dataType {
            case .updated:
                
                break
            default:
                break
            }
        }
    }
}



extension TokenInfoHistoryListBinder {
    
    class MoreValueView: UIStackView {
        
    }
}


extension TokenInfoHistoryListBinder {
    
    
    class TagLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            font = XWallet.Font(ofSize: 14)
            textColor = .white
            backgroundColor = HDA(0x0552DC)
            autoCornerRadius = 11
            textAlignment = .center
        }
        
        init(_ title: String) {
            super.init(frame: CGRect.zero)
            self.text = title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            superview?.layoutSubviews()
            width = width + 22.auto()
        }
    }
    
    class AddressView: UIView {

        lazy var amountLabel = UILabel(text: TR("~"), font: XWallet.Font(ofSize: 14)).then { $0.textColor = COLOR.title }
        lazy var addressLabel = UILabel(text: TR("~"), font: XWallet.Font(ofSize: 14)).then { $0.textColor = HDA(0x0552DC) }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            self.backgroundColor = .white
            amountLabel.textAlignment = .left
            addressLabel.textAlignment = . right
        }
        
        private func layoutUI() {
            addSubviews([amountLabel, addressLabel])
            amountLabel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(38.auto())
            }
            addressLabel.snp.makeConstraints { (make) in
                make.right.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(38.auto())
            }
        }
    }
    
    
    class TxHistoryView: UIView {
        
        lazy var txTypeIcon: UIImageView = {
            let v = UIImageView()
            v.backgroundColor = HDA(0xF4F4F4)
            v.autoCornerRadius = 24

            return v
        }()
        
        lazy var moneyContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var infoContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 2.auto()
            v.alignment = .center
            v.distribution = .fill
            return v
        }()
        
        lazy var addressContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .vertical
            v.spacing = 0.auto()
            v.alignment = .fill
            v.distribution = .fillProportionally
            return v
        }()
        
        lazy var feeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.textAlignment = .left
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var stateContainer: UIStackView = {
            let v = UIStackView(frame: .zero)
            v.axis = .horizontal
            v.spacing = 5.auto()
            v.alignment = .center
            v.distribution = .equalCentering
            return v
        }()
        
        lazy var timeLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.textColor = COLOR.subtitle
            v.textAlignment = .right
            v.backgroundColor = .clear
            return v
        }()
        
        
        
        lazy var sepLine = UIView(HDA(0xEBEEF0))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            self.backgroundColor = .white
        }
        
        private func layoutUI() {
            addSubviews([txTypeIcon, moneyContainer, infoContainer, feeLabel, stateContainer, timeLabel])
            
            txTypeIcon.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
                make.left.equalTo(self.snp.left).offset(24.auto())
                make.top.equalTo(self.snp.top).offset(16.auto())
            }
            
            moneyContainer.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(19.auto())
                make.height.equalTo(22.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
            }
            
            infoContainer.snp.makeConstraints { (make) in
                make.height.equalTo(22.auto())
                make.left.equalTo(moneyContainer.snp.left)
                make.top.equalTo(moneyContainer.snp.bottom).offset(2.auto())
            }
            
            feeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(22.auto())
                make.left.right.equalTo(moneyContainer)
                make.top.equalTo(infoContainer.snp.bottom).offset(2.auto())
            }
            
            stateContainer.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.left.equalTo(moneyContainer.snp.left)
                make.bottom.equalTo(self.snp.bottom).offset(-16.auto())
            }
            
            timeLabel.snp.makeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.right.equalTo(self.snp.right).offset(-16.auto())
                make.bottom.equalTo(self.snp.bottom).offset(-16.auto())
            }
        }
        
        func relayoutForTx(_ txType: TxType = .invalid) {
            switch txType {
            case .transIn:
                feeLabel.isHidden = true
            case .transOut:
                feeLabel.isHidden = false
            default:
                break
            }
        }
        
        
        func relayoutUIForBTCTx() {
            feeLabel.isHidden = true
            infoContainer.removeAll()
            infoContainer.isHidden = true
            moneyContainer.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(19.auto())
                make.height.equalTo(22.auto())
                make.left.equalTo(txTypeIcon.snp.right).offset(16.auto())
            }
            
            stateContainer.snp.remakeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.left.equalTo(moneyContainer.snp.left)
                make.top.equalTo(moneyContainer.snp.bottom).offset(4.auto())
            }
            
            timeLabel.snp.remakeConstraints { (make) in
                make.height.equalTo(16.auto())
                make.right.equalTo(self.snp.right).offset(-24.auto())
                make.bottom.equalTo(stateContainer.snp.bottom)
            }
            
            addSubview(sepLine)
            sepLine.snp.makeConstraints { (make) in
                make.left.equalTo(moneyContainer.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
                make.height.equalTo(0.5)
                make.top.equalToSuperview().offset(79.auto())
            }
            addSubview(addressContainer)
            addressContainer.snp.makeConstraints { (make) in
                make.left.equalTo(moneyContainer.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
                make.top.equalTo(sepLine.snp.bottom)
                make.bottom.equalToSuperview()
                make.height.greaterThanOrEqualTo(38.auto())
            }
        }
        
        func defaultLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.subtitle
            v.text = text
            return v
        }
        
        func titleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func subTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.text = text
            return v
        }
        
        func addressTitleLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x0552DC)
            v.text = text
            v.textAlignment = .right
            return v
        }
        
        func stateLabel(text: String, state: TokenInfoTxInfo.TxState = .cancel) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14, weight: .medium)
            var textcolor = COLOR.title
            switch state {
            case .success, .pending:
                textcolor = COLOR.title
            case .failed:
                textcolor = HDA(0xFA6237)
            case .cancel:
                textcolor = COLOR.title.withAlphaComponent(0.2)
            }
            v.textColor = textcolor
            v.text = text
            return v
        }
        
        func tagButton(text: String) -> UIButton {
            let v = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 22.auto()))
            v.titleFont = XWallet.Font(ofSize: 14)
            v.titleColor = .white
            v.backgroundColor = HDA(0x0552DC)
            v.autoCornerRadius = 11
            v.title = text
            v.contentEdgeInsets = UIEdgeInsets(top: 2, left: 11, bottom: 2, right: 11).auto()
            return v
        }
        
        func contractLabel(text: String) -> UILabel {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = COLOR.title
            v.backgroundColor = HDA(0xF0F3F5)
            v.autoCornerRadius = 11
            v.textAlignment = .center
            v.text = text
            return v
        }
        
        func waittingView() -> FxTxLoadingView  {
            return FxTxLoadingView.loading16().then { $0.loading() }
        }
        
        func alertView() -> UIImageView  {
            let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 24.auto(), height: 24.auto()))
            v.image = IMG("Tx.Info")
            return v
        }
    }
}

