

import WKKit
import RxSwift
import RxCocoa
import WebKit

extension AgreementViewController {
    class ContentView: UIView {
        lazy var webview: WKWebView = {
            let config = WKWebViewConfiguration()
            let webview = WKWebView(frame: .zero, configuration: config)
            webview.translatesAutoresizingMaskIntoConstraints = false
            webview.autoCornerRadius = 12
            webview.clipsToBounds = true 
            webview.isUserInteractionEnabled = true
            webview.isOpaque = false
            webview.backgroundColor = RGB(26, 28, 62)
            webview.scrollView.backgroundColor = .clear
            return webview
        }()
        
        lazy var agreeView = AgreeView(frame: CGRect.zero)
        
        lazy var submitButton: UIButton = {
            let v = UIButton()
            v.title = TR("Button.Confirm")
            v.bgImage = UIImage.createImageWithColor(color: .white)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
            v.titleLabel?.autoFont = true
            v.titleColor = HDA(0x080A32)
            v.disabledBGImage = UIImage.createImageWithColor(color: HDA(0x31324A))
            v.disabledTitleColor = UIColor.white.withAlphaComponent(0.2)
            v.autoCornerRadius = 25
            return v
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layoutUI()
            bindAction()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func layoutUI() {
            addView(webview, agreeView, submitButton)
            webview.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview().inset(5.auto())
                make.bottom.equalTo(agreeView.snp.top).offset(-24.auto())
            }
            
            agreeView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(35.auto())
                make.bottom.equalTo(submitButton.snp.top).offset(-24.auto())
            }
            
            submitButton.snp.makeConstraints { (make) in
                make.height.equalTo(50.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.bottom.equalToSuperview().offset(-24.auto())
            }
        }
        
        func bindAction() {
            let checkBoxView = agreeView.checkBox
            let checkBoxState = agreeView.checkBoxState
            submitButton.isEnabled = checkBoxState.value
            checkBoxState.bind(to: submitButton.rx.isEnabled)
                .disposed(by: defaultBag)
            checkBoxState.bind(to: checkBoxView.rx.isSelected).disposed(by: defaultBag)
            checkBoxView.action {
                checkBoxState.accept(!checkBoxView.isSelected)
            } 
            agreeView.tipButton.action {
                checkBoxState.accept(!checkBoxView.isSelected)
            }
        }
    }
    
    class AgreeView: UIView {
        lazy var checkBoxState = BehaviorRelay<Bool>(value: false)
        lazy var checkBox: UIButton = {
            let v = UIButton()
            v.image = nil
            v.bgImage = UIImage.createImageWithColor(color: .clear)
            v.selectedImage = IMG("ic_check_white")
            v.selectedBGImage = UIImage.createImageWithColor(color: HDA(0x0552DC))
            v.cornerRadius = 4
            v.borderWidth = 2
            v.borderColor = HDA(0x0552DC)
            return v
        }()
        
        lazy var tipButton = UIButton(.clear)
        lazy var tipLabel: UILabel = {
            let v = UILabel()
            v.numberOfLines = 0
            let text = TR("AgreeToTerms")
            let attText = NSMutableAttributedString(string: text, attributes: [.font: XWallet.Font(ofSize: 14),
                                                                               .foregroundColor: UIColor.white])
            attText.addAttributes([.foregroundColor: UIColor.gray], range: text.nsRange(of: TR("Terms"))!)
            v.attributedText = attText
            v.sizeToFit()
            return v
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layoutUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
         
        let checkBoxValid = BehaviorRelay(value: false)
        func layoutUI() {
            addSubviews([checkBox, tipLabel, tipButton])
            if tipLabel.width <= ScreenWidth - 80.auto() {
                checkBox.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.right.equalTo(tipLabel.snp.left).offset(-15.auto())
                    make.size.equalTo(CGSize(width: 22, height: 22).auto())
                }
                
                tipLabel.snp.makeConstraints { (make) in
                    make.centerY.equalTo(checkBox)
                    make.centerX.equalToSuperview().offset(18.auto())
                }
            } else {
                checkBox.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(24.auto())
                    make.size.equalTo(CGSize(width: 22, height: 22).auto())
                }
                tipLabel.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(checkBox.snp.right).offset(8.auto())
                    make.right.equalTo(24.auto())
                }
            }
             
            tipButton.snp.makeConstraints { (make) in
                make.left.equalTo(checkBox.snp.right).offset(24)
                make.top.right.height.equalTo(tipLabel)
            }
          
            checkBoxState.asObservable().observeOn(MainScheduler.instance)
                .map { $0 ? 0 : 2 }
                .subscribe(onNext: { [weak self] in
                    self?.checkBox.borderWidth = $0
                }).disposed(by: defaultBag)
        }
    }
}

 
