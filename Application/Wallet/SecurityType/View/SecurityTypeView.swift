
import WKKit
extension SecurityTypeViewController {
    class View: WelcomeCreateView {
        var closeButton: UIButton { navBar.backButton }
        lazy var navBar = FxBlurNavBar.standard()
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            titleLabel.text = TR("Security.Title")
            let subTitle = TR("Security.SubTitle")
            subTitle.lineSpacingLabel(subtitleLabel)
            let isTouchID = LocalAuthManager.shared.isAuthTouch
            createItemView.icon.image = isTouchID ? IMG("Bio.TouchId_White") : IMG("Bio.FaceId_White")
            createItemView.titleLabel.text = isTouchID ? TR("Security.Bio.TouchTitle") : TR("Security.Bio.FaceTitle") createItemView.subtitleLabel.text = TR("Security.Bio.SubTitle")
            importItemView.icon.image = IMG("Bio.Lock_White")
            importItemView.titleLabel.text = TR("Security.Pwd.Title")
            importItemView.subtitleLabel.text = TR("Security.Pwd.SubTitle")
        }

        private func layoutUI() {
            addSubview(navBar)
            navBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(FullNavBarHeight)
            }
        }

        func bioUse(b: Bool) {
            if b {
                pannel.snp.remakeConstraints { make in
                    make.height.equalTo((72 + 36).auto())
                    make.left.right.equalTo(self).inset(24.auto())
                    make.bottom.equalTo(self.snp.bottom).offset(-38.auto())
                }
                importItemView.snp.makeConstraints { make in
                    make.left.right.equalTo(pannel)
                    make.height.equalTo(72.auto())
                    make.centerY.equalToSuperview()
                }
                lineView.removeFromSuperview()
                createItemView.removeFromSuperview()
            }
        }
    }
}
