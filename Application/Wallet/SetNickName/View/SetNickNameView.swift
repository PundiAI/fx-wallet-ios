//
//  Python3
//  MakeSwiftFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

import WKKit

extension SetNickNameViewController {
    class View: UIView { 
        class NTipView: TipView {
            required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                textLabel.font = XWallet.Font(ofSize: 14)
                textLabel.autoFont = true
                textLabel.textColor = COLOR.tip
                dotView.backgroundColor = COLOR.tip
                dotView.autoCornerRadius = 3
                
                dotView.snp.remakeConstraints { (make) in
                    make.centerY.equalTo(textLabel.snp.centerY)
                    make.left.equalToSuperview()
                    make.size.equalTo(CGSize(width: 6, height: 6).auto())
                }
                
                textLabel.snp.remakeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.left.equalTo(dotView.snp.right).offset(8)
                    make.right.equalToSuperview()
                }
            }
            
            var isNSelected = false {
                didSet {
                    textLabel.textColor =    isNSelected ? COLOR.tipselected : COLOR.tip
                    dotView.backgroundColor = isNSelected ? COLOR.tipselected : COLOR.tip
                }
            }
            
            func resetLayout() {
                let offset = textLabel.font.lineHeight / 2
                dotView.snp.remakeConstraints { (make) in
                    make.top.equalTo(textLabel.snp.top).offset(offset)
                    make.left.equalToSuperview()
                    make.size.equalTo(CGSize(width: 6, height: 6).auto())
                }
            }
        }
        
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        
        var contentSize: CGSize { CGSize(width: ScreenWidth, height: (max(667, ScreenHeight) - FullNavBarHeight))}
        
        lazy var titleLabel: UILabel = {
   
            let v = UILabel(frame: CGRect(x: 24.auto(), y: FullNavBarHeight, width: 200, height: 58))
            v.text = TR("NickName.Title")
            v.font = XWallet.Font(ofSize: 48, weight: .bold)
            v.autoFont = true
            v.sizeToFit()
            v.adjustsFontSizeToFitWidth = true
            v.textColor = COLOR.title
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var subtitleLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var inputTFContainer = FxRoundTextField.standard
        var inputTF: UITextField { return inputTFContainer.interactor }
        
        
        fileprivate lazy var preLabel: UILabel = {
            let v = UILabel()
            v.text = TR("@")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            v.sizeToFit()
            v.backgroundColor = .clear
            return v
        }()
        
        lazy var doneButton = UIButton().doNormal(title: TR("Button.Next"))
        
        
        lazy var tipView1: NTipView = {
            let v = NTipView(frame: ScreenBounds)
            v.textLabel.text = TR("NickName.Tip.Title1")
            v.textLabel.autoFont = true
            return v
        }()
        
        lazy var tipView2: NTipView = {
            let v = NTipView(frame: ScreenBounds)
            v.textLabel.text = TR("NickName.Tip.Title2")
            v.textLabel.autoFont = true
            return v
        }()
        
        lazy var tipView3: NTipView = {
            let v = NTipView(frame: ScreenBounds)
            v.textLabel.text = TR("NickName.Tip.Title3")
            v.textLabel.autoFont = true
            return v
        }()
        
        lazy var tipView4: NTipView = {
            let v = NTipView(frame: ScreenBounds)
            v.textLabel.text = TR("NickName.Tip.Title4")
            v.textLabel.autoFont = true
            return v
        }()
        
        lazy var scrollview: UIScrollView = {
            let v = UIScrollView(.clear)
            v.contentSize = CGSize(width: 0, height: 820.auto())
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
            v.contentInsetAdjustmentBehavior = .never
            return v
        }()
        
        fileprivate lazy var contentView = UIView(.clear)
        
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            
            configuration()
            layoutUI()
        }
        
        private func configuration() {
            backgroundColor = .white
            inputTFContainer.backgroundColor = .white
            inputTFContainer.borderColor = COLOR.inputborder
            inputTFContainer.borderWidth = 2
            inputTFContainer.autoCornerRadius = 28
            
            inputTF.textColor = UIColor.black
            inputTF.font = XWallet.Font(ofSize: 16, weight: .bold)
            inputTF.autoFont = true
            inputTF.tintColor = COLOR.inputborder
            
            inputTF.attributedPlaceholder = NSAttributedString(string: TR("NickName.Input.Placeholder"), attributes: [.font : XWallet.Font(ofSize: 16),
                                                                                                                   .foregroundColor: COLOR.tip])
            
            navBar.backButton.isHidden = false
            
            navBar.isHidden = false
            
            doneButton.titleFont = XWallet.Font(ofSize: 18, weight: .bold)
            doneButton.titleLabel?.autoFont = true
            doneButton.autoCornerRadius = 28
             
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleSwipeFrom(recognizer:)))
            self.addGestureRecognizer(tap)
            
            let subTitle = TR("NickName.SubTitle")
            subTitle.lineSpacingLabel(subtitleLabel)
            subtitleLabel.autoFont = true
            
            stackView.axis = .vertical
            stackView.spacing = 4.auto()
            stackView.alignment = .leading
            stackView.distribution = .fillProportionally
            

            titleLabel.width = ScreenWidth - 24.auto() * 2
            titleLabel.adjustsFontSizeToFitWidth = true 
        }
        
        lazy var stackView = UIStackView(frame: CGRect.zero)
        
        private func layoutUI() {
            
            addSubview(scrollview)
            
            scrollview.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            addSubview(navBar)
            
            
            scrollview.addSubview(contentView)
            
            contentView.snp.makeConstraints { (make) in
                make.edges.equalTo(scrollview)
                make.size.equalTo(contentSize)
            }
            
            
            contentView.addSubview(titleLabel)
            contentView.addSubview(subtitleLabel)
            contentView.addSubview(inputTFContainer)
            inputTFContainer.addSubview(preLabel)
            contentView.addSubview(doneButton)
            
            contentView.addSubview(stackView)
            
            stackView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(doneButton.snp.bottom).offset(16.auto())
            }
             

            let font = tipView1.textLabel.font ??  XWallet.Font(ofSize: 14)
            let tWidth = ScreenWidth - 24.auto() * 2 - 14.auto()
            let value = tipView1.textLabel.text ?? ""
            let vheight =  value.height(ofWidth: tWidth,
                          attributes: [.font: font])
            tipView1.height(constant: vheight)
            tipView1.resetLayout()
            
            stackView.addArrangedSubview(tipView1)
            stackView.addArrangedSubview(tipView2)
            stackView.addArrangedSubview(tipView3)
            stackView.addArrangedSubview(tipView4)
            
            navBar.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            inputTFContainer.snp.makeConstraints { (make) in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            preLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(inputTF.snp.centerY)
                make.right.equalTo(inputTF.snp.left).offset(-6.auto())
            }
            
            doneButton.snp.makeConstraints { (make) in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            
            inputTF.snp.remakeConstraints { (make) in
                make.centerY.height.equalToSuperview()
                make.left.equalTo(24.auto() + preLabel.width)
                make.right.equalTo(-24.auto())
            }
        }
        
        @objc func handleSwipeFrom(recognizer: UISwipeGestureRecognizer) {
            self.inputTF.resignFirstResponder()
        }
        
        
    }
}

