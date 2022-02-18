 

import WKKit

extension SetPasswordViewController {
    class NoticeView: UIView {
        private lazy var titleBGView = UIView(RGB(245, 212, 109))
        private lazy var noticetipButton = UIButton().then {
            $0.image = IMG("ic_warning_white")
        }
        
        private lazy var titleLabel = UILabel(text: TR("Security.Password.Note.Title"), font: XWallet.Font(ofSize: 16, weight: .medium), textColor: COLOR.title)
        private lazy var descLabel = UILabel(text: TR("Security.Password.Alert"), font: XWallet.Font(ofSize: 14),
                                             textColor: COLOR.title, lines: 0)

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = RGB(255, 246, 195)
            self.cornerRadius = 24
            addView(titleBGView, noticetipButton, titleLabel, descLabel)
            titleBGView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(40.auto())
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(titleBGView)
                make.left.equalTo(noticetipButton.snp.right).offset(8.auto())
                make.right.equalToSuperview().inset(24.auto())
            }
            
            noticetipButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16.auto())
                make.centerY.equalTo(titleLabel)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            
            descLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleBGView.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
        }
        
        var contentHeight:CGFloat {
            let width = ScreenWidth - 24.auto() * 4
            let noticeHeight = TR("Security.Password.Alert").height(ofWidth: width,
                                                                    attributes: [.font: XWallet.Font(ofSize: 14)])
            return (40 + 24 + 24).auto() + noticeHeight
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    class View: UIView {
        
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
         
        lazy var titleLabel = UILabel(font: XWallet.Font(ofSize: 40, weight: .medium),
                                      textColor: COLOR.title,
                                      bgColor: .clear).then {$0.autoFont = true}
        
        lazy var subtitleLabel = UILabel(font: XWallet.Font(ofSize: 16),
                                         textColor: COLOR.subtitle,
                                         lines: 0,
                                         bgColor: .clear).then {$0.autoFont = true}
        
        lazy var inputTFContainer = FxRoundTextField.standard
        var inputTF: UITextField { return inputTFContainer.interactor }
        
        lazy var doneButton = UIButton().doNormal(title: TR("Button.Next"))
        lazy var noteView = NoticeView(frame: CGRect.zero)
        
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
            inputTF.isSecureTextEntry = true
            inputTF.tintColor = COLOR.inputborder
            
            inputTF.attributedPlaceholder = NSAttributedString(string: TR("BroadcastTx.Security.Placeholder"), attributes: [.font : XWallet.Font(ofSize: 16),
                                                                                                                   .foregroundColor: COLOR.tip])
            doneButton.titleFont = XWallet.Font(ofSize: 18, weight: .bold)
            doneButton.titleLabel?.autoFont = true
            doneButton.autoCornerRadius = 28
            
            titleLabel.text = TR("Password") 
            subtitleLabel.text = TR("Security.Change.Setting.SubTitle")
        }
        
        private func layoutUI() {
            
            addSubview(navBar)
            
            addSubviews([titleLabel, subtitleLabel, inputTFContainer, doneButton, noteView])
            
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(FullNavBarHeight + 8.auto() )
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(48.auto())
            
            }
            
            subtitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(10.auto())
                make.height.equalTo(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            
            inputTFContainer.snp.makeConstraints { (make) in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(24.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            doneButton.snp.makeConstraints { (make) in
                make.top.equalTo(inputTFContainer.snp.bottom).offset(16.auto())
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
            
            let contentHeight = noteView.contentHeight
            noteView.snp.makeConstraints { (make) in
                make.top.equalTo(doneButton.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(contentHeight)
            }
        }
    }
}
        
