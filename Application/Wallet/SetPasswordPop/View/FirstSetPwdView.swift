import WKKit
class FirstSetPwdView: UIView {
    lazy var backgroundBlur = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    let containerView: UIScrollView = {
        let v = UIScrollView(.clear)
        v.contentSize = CGSize(width: ScreenWidth * 3, height: 0)
        v.isScrollEnabled = false
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.contentInsetAdjustmentBehavior = .never
        return v
    }()

    let pwdInputView = PwdVerifyView(frame: ScreenBounds.offsetBy(dx: 0, dy: 0))
    let pwdConfirmView = PwdVerifyView(frame: ScreenBounds.offsetBy(dx: 0, dy: ScreenHeight))
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        logWhenDeinit()
        configuration()
        layoutUI()
    }

    private func configuration() {
        backgroundColor = .clear
        pwdInputView.relayoutForPwd()
        pwdInputView.hiddenBio()
        pwdConfirmView.relayoutForPwd()
        pwdConfirmView.hiddenBio()
        pwdConfirmView.subtitleLabel.text = TR("SetPwd.Confirm.Title")
        pwdConfirmView.confirmButton.title = TR("SetPwd.Confirm.BtnTitle")
    }

    private func layoutUI() {
        addSubviews([backgroundBlur, containerView])
        backgroundBlur.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.addSubview(pwdInputView)
        containerView.addSubview(pwdConfirmView)
    }
}
