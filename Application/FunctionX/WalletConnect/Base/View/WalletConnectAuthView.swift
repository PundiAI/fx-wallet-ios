import UIKit
import WKKit
class WalletConnectAuthView: UIView {
    fileprivate lazy var topContainerView = UIView(COLOR.backgroud)
    lazy var logoIV: UIImageView = {
        let v = UIImageView()
        v.image = IMG("WC.FxLogo")
        v.cornerRadius = 22
        return v
    }()

    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = TR("FunctionX.io")
        v.font = XWallet.Font(ofSize: 28, weight: .bold)
        v.textColor = .white
        v.backgroundColor = .clear
        return v
    }()

    lazy var subtitleLabel: UILabel = {
        let v = UILabel()
        v.text = TR("Request to Connect")
        v.font = XWallet.Font(ofSize: 20, weight: .bold)
        v.textColor = HDA(0x999999)
        v.backgroundColor = .clear
        return v
    }()

    fileprivate lazy var bottomContainerView = UIView(COLOR.backgroud)
    fileprivate lazy var allowButton = UIButton().doGradient(title: TR("WalletConnect.Allow"))
    fileprivate lazy var denyButton: UIButton = {
        let v = UIButton()
        v.title = TR("WalletConnect.Deny")
        v.titleFont = XWallet.Font(ofSize: 14)
        v.titleColor = HDA(0xFA6237)
        v.backgroundColor = .clear
        return v
    }()

    fileprivate lazy var addressLabel: UILabel = {
        let v = UILabel()
        v.text = TR("--")
        v.font = XWallet.Font(ofSize: 14)
        v.textColor = HDA(0x999999)
        v.backgroundColor = .clear
        return v
    }()

    var eventHandler: ((Bool) -> Void)?
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame _: CGRect) {
        super.init(frame: ScreenBounds)
        logWhenDeinit()
        configuration()
        layoutUI()
        bind()
    }

    private func bind() {
        weak var welf = self
        allowButton.action {
            welf?.eventHandler?(true)
            welf?.hide()
        }
        denyButton.action {
            welf?.eventHandler?(false)
            welf?.hide()
        }
    }

    func show(inView superView: UIView) {
        superView.addSubview(self)
        frame = ScreenBounds
        isHidden = false
        topContainerView.mj_y = -height * 0.5
        bottomContainerView.mj_y = height
        UIView.animate(withDuration: 0.15, animations: {
            self.topContainerView.mj_y = 0
            self.bottomContainerView.mj_y = self.height * 0.5
        }, completion: nil)
    }

    func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15, animations: {
                self.topContainerView.mj_y = -self.topContainerView.height
                self.bottomContainerView.mj_y = self.height
            }) { flag in
                if flag { self.removeFromSuperview() }
            }
        }
    }

    private func configuration() {
        isHidden = true
        backgroundColor = .clear
    }

    private func layoutUI() {
        addSubview(topContainerView)
        topContainerView.addSubview(logoIV)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(subtitleLabel)
        addSubview(bottomContainerView)
        bottomContainerView.addSubview(allowButton)
        bottomContainerView.addSubview(denyButton)
        bottomContainerView.addSubview(addressLabel)
        topContainerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        logoIV.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(-16)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-8)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-30)
            make.centerX.equalToSuperview()
        }
        bottomContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        allowButton.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(UIButton.gradientSize())
        }
        denyButton.snp.makeConstraints { make in
            make.top.equalTo(allowButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(UIButton.standardSize)
        }
        addressLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.left.right.equalToSuperview().inset(20)
        }
    }
}
