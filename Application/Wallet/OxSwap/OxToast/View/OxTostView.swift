//
//
//  XWallet
//
//  Created by May on 2020/8/11.
//  Copyright © 2020 May All rights reserved.
//

import WKKit


extension OxToastViewController {
    
        class ContentCell: FxTableViewCell {
    
            var closeButton: UIButton { _closeButton }
            private lazy var _closeButton: UIButton = {
                let v = UIButton()
                v.image = IMG("Menu.Close")
                v.backgroundColor = .clear
                return v
            }()

            lazy var titleLabel: UILabel = {
                let v = UILabel(text: TR("Ox.Tip.Title"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
                v.autoFont = true
                v.textAlignment = .center
                v.numberOfLines = 0
                return v
            }()
            
            lazy var expectedTitleLabel: UILabel = {
                let v = UILabel(text: TR("Ox.Tip.Expected"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
                v.autoFont = true
                v.textAlignment = .left
                return v
            }()
            
            lazy var expectedValueLabel: UILabel = {
                let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
                v.autoFont = true
                v.textAlignment = .right
                return v
            }()
            
            lazy var minimumTitleLabel: UILabel = {
                let v = UILabel(text: TR("Ox.Tip.Minimum"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
                v.autoFont = true
                v.textAlignment = .left
                return v
            }()
            
            lazy var minimumValueLabel: UILabel = {
                let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
                v.autoFont = true
                v.textAlignment = .right
                return v
            }()
            
            lazy var slippageTitleLabel: UILabel = {
                let v = UILabel(text: TR("Ox.Tip.Slippage"), font: XWallet.Font(ofSize: 14), textColor: COLOR.subtitle)
                v.autoFont = true
                v.textAlignment = .left
                return v
            }()
            
            lazy var slippageValueLabel: UILabel = {
                let v = UILabel(text: TR("-"), font: XWallet.Font(ofSize: 14), textColor: COLOR.title)
                v.autoFont = true
                v.textAlignment = .right
                return v
            }()
            
            override class func height(model: Any?) -> CGFloat {
                if let title = model as? String {
                    let width = ScreenWidth - (24 + 16).auto() * 2
                    let font:UIFont = UILabel().then {
                        $0.font = XWallet.Font(ofSize: 14)
                        $0.text = title
                        $0.autoFont = true }.font
                    let noticeHeight1 = title.height(ofWidth: width, attributes: [.font:font])
                    return 198.auto() - 17.auto() + noticeHeight1
                }
                return 198.auto()
            }
    
            override func layoutUI() {
                
                contentView.addSubviews([closeButton, titleLabel,
                                         expectedTitleLabel, expectedValueLabel,
                                         minimumTitleLabel, minimumValueLabel,
                                         slippageTitleLabel, slippageValueLabel])
    
                
                closeButton.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.right.equalToSuperview()
                    make.size.equalTo(CGSize(width: 48, height: 48).auto())
                }
                
                titleLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(50.auto())
                    make.left.right.equalToSuperview().inset(16.auto())
//                    make.height.equalTo(17.auto())
                }
    
                expectedTitleLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(24.auto())
                    make.left.equalTo(16.auto())
                    make.height.equalTo(17.auto())
                }
    
                expectedValueLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(expectedTitleLabel.snp.centerY)
                    make.right.equalToSuperview().offset(-16.auto())
                    make.height.equalTo(17.auto())
                }
    
                minimumTitleLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(expectedValueLabel.snp.bottom).offset(16.auto())
                    make.left.equalTo(16.auto())
                    make.height.equalTo(17.auto())
                }
    
                minimumValueLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(minimumTitleLabel.snp.centerY)
                    make.right.equalToSuperview().offset(-16.auto())
                    make.height.equalTo(17.auto())
                }
                
                slippageTitleLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(minimumValueLabel.snp.bottom).offset(16.auto())
                    make.left.equalTo(16.auto())
                    make.height.equalTo(17.auto())
                }
    
                slippageValueLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(slippageTitleLabel.snp.centerY)
                    make.right.equalToSuperview().offset(-16.auto())
                    make.height.equalTo(17.auto())
                }
            }
        }
}
