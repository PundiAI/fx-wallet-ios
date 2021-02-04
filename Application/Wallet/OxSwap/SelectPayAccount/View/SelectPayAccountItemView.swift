//
//
//  XWallet
//
//  Created by May on 2020/12/23.
//  Copyright © 2020 May All rights reserved.
//

import WKKit


extension SelectPayAccountViewController {
    
    
    class OxAccountListItemView: UIView {
        
        lazy var balanceLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = HDA(0x080A32)
            v.backgroundColor = .clear
            v.adjustsFontSizeToFitWidth = true
            return v
        }()
        
        lazy var addressLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        
        lazy var ethBalanceLabel: UILabel = {
            let v = UILabel()
            v.text = "--"
            v.font = XWallet.Font(ofSize: 14)
            v.textColor = HDA(0x080A32).withAlphaComponent(0.5)
            v.backgroundColor = .clear
            v.lineBreakMode = .byTruncatingMiddle
            return v
        }()
        
        lazy var selectedIV: UIImageView = {
            let v = UIImageView()
            v.image = IMG("ic_arrow_right")
            v.contentMode = .scaleAspectFit
            return v
        }()
        
        lazy var disableMask = UIView(HDA(0xF0F3F5).withAlphaComponent(0.8))
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        var isSelected: Bool {
            get { !selectedIV.isHidden }
            set { selectedIV.isHidden = !newValue }
        }
        
        
        private func configuration() {
            backgroundColor = HDA(0xF0F3F5)
            isSelected = false
            disableMask.isHidden = true
        }
        
        private func layoutUI() {
            addSubviews([selectedIV, balanceLabel, addressLabel, ethBalanceLabel, disableMask])
            
            selectedIV.snp.makeConstraints { (make) in
                make.left.equalTo(16.auto())
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
            
            relayout(hideEthRemark: true)
            
            ethBalanceLabel.snp.makeConstraints { (make) in
                make.top.equalTo(addressLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(addressLabel).offset(4.auto())
                make.height.equalTo(22.auto())
            }
            
            disableMask.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }

        func relayout(hideEthRemark: Bool) {
            
            ethBalanceLabel.isHidden = hideEthRemark
            if hideEthRemark {
                
                addressLabel.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(selectedIV).offset(12.auto())
                    make.left.equalTo(selectedIV.snp.right).offset(16.auto())
                    make.right.equalTo(-20.auto())
                    make.height.equalTo(20.auto())
                }
                
                balanceLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(selectedIV).offset(-12.auto())
                    make.left.equalTo(selectedIV.snp.right).offset(16.auto())
                    make.right.equalTo(-20.auto())
                    make.height.equalTo(20.auto())
                }
            } else {
                
                addressLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(selectedIV.snp.right).offset(16.auto())
                    make.right.equalTo(-20.auto())
                    make.height.equalTo(20.auto())
                }
                
                balanceLabel.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(addressLabel.snp.top).offset(-8.auto())
                    make.left.equalTo(selectedIV.snp.right).offset(16.auto())
                    make.right.equalTo(-20.auto())
                    make.height.equalTo(20.auto())
                }
            }
        }
        
        func layoutCorner(_ c: (Bool, Bool)?, size: CGSize) {
            guard let (top, bottom) = c, top || bottom else {
                layer.mask = nil
                return
            }
            
            var corners: UIRectCorner = []
            if top, bottom {
                corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            } else if top {
                corners = [.topLeft, .topRight]
            } else if bottom {
                corners = [.bottomLeft, .bottomRight]
            }
            addCorner(corners, size: size)
        }
    }
}
        


extension SelectPayAccountViewController {
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
            let height = (40 + 20 * 2).auto() + subtitleHeight + 30.auto()
            contentView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(height)
            }
            
            resultLabel.snp.makeConstraints { (make) in
                make.left.equalTo(24.auto())
                make.centerY.equalTo(resultBGView)
            }
            
            resultBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40.auto())
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
