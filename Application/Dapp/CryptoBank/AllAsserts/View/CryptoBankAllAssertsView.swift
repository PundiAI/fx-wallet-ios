

import WKKit

extension CryptoBankAllAssertsViewController {
    class View: UIView {
        
        var searchTF: UITextField { searchView.interactor }
        lazy var searchView: FxRoundTextField = {
            let v = FxRoundTextField(size: CGSize(width: ScreenWidth, height: 56.auto()))
            v.interactor.font = XWallet.Font(ofSize:16, weight: .medium)
            v.interactor.textColor = HDA(0x080A32)
            v.interactor.tintColor = HDA(0x0552DC)
            v.editBorderColors = (HDA(0x0552DC), .clear)
            v.borderWidth = 2
            v.interactor.keyboardType = .asciiCapable
            v.interactor.attributedPlaceholder = NSAttributedString(string: TR("SelectOrAddAccount.Placeholder"), attributes: [.font: XWallet.Font(ofSize:16), .foregroundColor: COLOR.subtitle])
            v.backgroundColor = HDA(0xF7F7FA)
            return v
        }()
        
        lazy var recommendSection = SectionView(text: TR("CryptoBank.Recommanded"))
        lazy var resultSection = SectionView(text: TR("Select.Token.Result", "0"))
        
        lazy var mainListView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.estimatedRowHeight = 88.auto()
            v.estimatedSectionFooterHeight = 0.auto()
            v.estimatedSectionFooterHeight = 0.auto()
            return v
        }()
        
        lazy var searchListView: WKTableView = {
            
            let v = WKTableView(frame: ScreenBounds, style: .plain)
            v.backgroundColor = .white
            v.estimatedRowHeight = 80.auto()
            v.estimatedSectionFooterHeight = 0
            v.estimatedSectionFooterHeight = 0
            return v
        }()
        
        lazy var noDataView = NoDataView(frame: ScreenBounds)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            noDataView.isHidden = true
            searchListView.isHidden = true
        }
        
        private func layoutUI() {
            
            addSubviews([searchView, mainListView, searchListView, noDataView])
            
            searchView.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + 16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
//            mainListView.sectionView = recommendSection
            mainListView.tableHeaderView = recommendSection
            mainListView.tableFooterView = buildFooterView()
            mainListView.snp.makeConstraints { (make) in
                make.top.equalTo(searchView.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalToSuperview()
            }
            
//            searchListView.sectionView = resultSection
            searchListView.tableHeaderView = resultSection
            searchListView.tableFooterView = buildFooterView()
            searchListView.snp.makeConstraints { (make) in
                make.edges.equalTo(mainListView)
            }
            
            noDataView.snp.makeConstraints { (make) in
                make.edges.equalTo(mainListView)
            }
        }
    
        private func buildFooterView() -> UIView {
            
            let v = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 24.auto() * 2, height: 44.auto()), .white)
            let mask = UIView(frame: CGRect(x: 0, y: 0, width: v.width, height: 32.auto()) ,HDA(0xF0F3F5))
            mask.addCorner([.bottomLeft, .bottomRight], radius: 16.auto())
            v.addSubview(mask)
            return v
        }
    }
}

extension CryptoBankAllAssertsViewController {
    class SectionView: UIView {
        
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 16, weight: .bold))
        private lazy var titleBGView = UIView(COLOR.title)
        
        private lazy var assertsLabel = UILabel(text: TR("CryptoBank.Assets"), font: XWallet.Font(ofSize: 16), textColor: COLOR.subtitle)
        private lazy var apyLabel = UILabel(text: TR("APY"), font: XWallet.Font(ofSize: 16), textColor: COLOR.subtitle)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        init(text: String) {
            super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth - 24.auto() * 2, height: 103.auto()))
            
            backgroundColor = HDA(0xF0F3F5)
            addCorner([.topLeft, .topRight], radius: 16.auto())
            
            addSubviews([titleBGView, titleLabel, assertsLabel, apyLabel])
            titleLabel.text = text
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.centerY.equalTo(titleBGView)
            }
            
            titleBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(43.auto())
            }
            
            assertsLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleBGView.snp.bottom).offset(23.auto())
                make.left.equalTo(24.auto())
                make.height.equalTo(20.auto())
            }
            
            apyLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(assertsLabel)
                make.right.equalTo(-24.auto())
                make.height.equalTo(20.auto())
            }
        }
    }
}

extension CryptoBankAllAssertsViewController {
    class NoDataView: UIView {
        
        private lazy var contentView = UIView(HDA(0xF0F3F5))
        private lazy var resultLabel = UILabel(text: TR("Select.Token.Result", "0"), font: XWallet.Font(ofSize: 16, weight: .bold))
        private lazy var resultBGView = UIView(COLOR.title)
        
        private lazy var titleLabel = UILabel(text: TR("NoData"), font: XWallet.Font(ofSize: 16, weight: .bold), textColor: HDA(0x080A32))
        private lazy var subtitleLabel = UILabel(text: TR("TokenList.NoResultNotice"), font: XWallet.Font(ofSize: 14), textColor: HDA(0x080A32).withAlphaComponent(0.5), lines: 0, alignment: .center)
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            contentView.cornerRadius = 16.auto()
        }
        
        private func layoutUI() {
            
            self.addSubview(contentView)
            contentView.addSubviews([resultBGView, resultLabel, titleLabel, subtitleLabel])
            
            let subtitleHeight = TR("TokenList.NoResultNotice").height(ofWidth: ScreenWidth - 24.auto() * 4, attributes: [.font: XWallet.Font(ofSize: 14)])
            let height = (50 + 20 * 2).auto() + subtitleHeight + 30.auto()
            contentView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(height)
            }
            
            resultLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.centerY.equalTo(resultBGView)
            }
            
            resultBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(43.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(resultBGView.snp.bottom).offset(20.auto())
                make.centerX.equalToSuperview()
                make.height.equalTo(20.auto())
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
    }
}
