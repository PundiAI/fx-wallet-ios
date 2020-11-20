import WKKit
extension ChatViewController {
    class TextInputPanel: UIView {
        lazy var sendGiftButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Chat.Gift")
            v.titleFont = XWallet.Font(ofSize: 12)
            v.titleColor = .white
            v.backgroundColor = .clear
            return v
        }()

        lazy var sendTextButton: UIButton = {
            let v = UIButton()
            v.image = IMG("Chat.Send")
            v.disabledImage = IMG("Chat.Send_disable")
            v.titleFont = XWallet.Font(ofSize: 12)
            v.titleColor = .white
            v.backgroundColor = .clear
            return v
        }()

        lazy var textInputTV: FxTextView = {
            let v = FxTextView(limit: 500)
            v.width = ScreenWidth - 105
            v.backgroundColor = .clear
            v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
            v.layer.borderWidth = 1
            v.layer.cornerRadius = 20
            v.layer.masksToBounds = true
            v.limitLabel.isHidden = true
            v.interactor.font = XWallet.Font(ofSize: 16)
            v.interactor.isScrollEnabled = true
            v.interactor.backgroundColor = .clear
            v.interactor.showsHorizontalScrollIndicator = true
            v.placeHolderLabel.font = XWallet.Font(ofSize: 16)
            v.placeHolderLabel.text = TR("Chat.Placeholder")
            v.interactor.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 15, bottom: 4, right: 15))
            }
            v.placeHolderLabel.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 18, bottom: 4, right: 10))
            }
            return v
        }()

        var inputWidth: CGFloat {
            if textInputTV.width < 10 { return ScreenWidth - 135 }
            return textInputTV.width - 15 * 2
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = COLOR.backgroud
            sendTextButton.isEnabled = false
        }

        private func layoutUI() {
            addSubview(sendGiftButton)
            addSubview(sendTextButton)
            addSubview(textInputTV)
            sendGiftButton.snp.makeConstraints { make in
                make.left.equalTo(12)
                make.size.equalTo(CGSize(width: 30, height: 40))
                make.bottom.equalTo(-8)
            }
            sendTextButton.snp.makeConstraints { make in
                make.right.equalTo(-12)
                make.size.equalTo(CGSize(width: 40, height: 40))
                make.bottom.equalTo(-8)
            }
            textInputTV.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.left.equalTo(sendGiftButton.snp.right).offset(6)
                make.right.equalTo(sendTextButton.snp.left).offset(-6)
            }
        }
    }
}
