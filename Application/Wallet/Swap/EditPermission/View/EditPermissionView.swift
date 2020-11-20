
import WKKit
extension EditPermissionViewController {
    class View: UIView {
        lazy var listView = WKTableView(frame: ScreenBounds, style: .plain)
        lazy var startButton = UIButton().doNormal(title: TR("Button.Save"))
        @available(*, unavailable)
        required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }

        private func configuration() {
            backgroundColor = .white
            listView.backgroundColor = .clear
            startButton.autoCornerRadius = 28
        }

        private func layoutUI() {
            addSubview(listView)
            addSubview(startButton)
            listView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(FullNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(startButton.snp.top).offset(-16.auto())
            }
            startButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
                make.bottom.equalTo(self.safeAreaLayout.bottom).offset(-16.auto())
            }
        }
    }
}

extension EditPermissionViewController {
    class TopPanel: SwapApproveViewController.BasePanel {
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.EditPermission.Title")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            return v
        }()

        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.EditPermission.Balance")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            return v
        }()

        lazy var currencyLalel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.title
            v.textAlignment = .right
            return v
        }()

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
        }

        private func layoutUI() {
            contentView.addSubviews([titleLabel, subTitleLabel, currencyLalel])
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16.auto())
                make.top.equalToSuperview().offset(24.auto())
                make.height.equalTo(17)
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(16.auto())
                make.height.equalTo(17.auto())
            }
            currencyLalel.snp.makeConstraints { make in
                make.height.equalTo(19)
                make.right.equalToSuperview().offset(-16.auto())
                make.centerY.equalTo(subTitleLabel)
            }
        }
    }
}

extension EditPermissionViewController {
    class SpendlimitView: UIView {
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.EditPermission.Tip")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()

        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.EditPermission.SubTip")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            return v
        }()

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
        }

        private func layoutUI() {
            addSubviews([titleLabel, subTitleLabel])
            titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(16.auto())
                make.height.equalTo(19.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
            }
        }
    }
}

extension EditPermissionViewController {
    class DefaultlimitView: UIView {
        lazy var iconIV = UIImageView()
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.EditPermission.Unlimited")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()

        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Spend limit requested by https:")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            return v
        }()

        lazy var amountLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 16)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            v.numberOfLines = 0
            return v
        }()

        lazy var touch = UIButton()
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
            iconIV.image = IMG("setting.nextB")
            iconIV.isHidden = true
        }

        private func layoutUI() {
            addSubviews([iconIV, titleLabel, subTitleLabel, amountLabel, touch])
            iconIV.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalTo(16.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(16.auto())
                make.height.equalTo(19.auto())
                make.left.equalTo(iconIV.snp.right).offset(10.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.equalTo(titleLabel.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
            }
            amountLabel.snp.makeConstraints { make in
                make.top.equalTo(subTitleLabel.snp.bottom).offset(8.auto())
                make.left.equalTo(titleLabel.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
            }
            touch.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension EditPermissionViewController {
    class CustomlimitView: UIView, UITextFieldDelegate {
        lazy var iconIV = UIImageView()
        lazy var titleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.CustomLimit")
            v.font = XWallet.Font(ofSize: 16, weight: .bold)
            v.autoFont = true
            v.textColor = COLOR.title
            return v
        }()

        lazy var subTitleLabel: UILabel = {
            let v = UILabel()
            v.text = TR("Swap.CustomLimit.Tip")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = COLOR.subtitle
            return v
        }()

        lazy var touch = UIButton()
        lazy var inputTFContainer = FxRoundTextField.standard
        var inputTF: UITextField { return inputTFContainer.interactor }
        var startEdit: Bool = false {
            didSet {
                if startEdit {
                    inputTFContainer.borderColor = COLOR.inputborder
                    inputTFContainer.borderWidth = 2

                } else {
                    inputTFContainer.borderColor = UIColor.clear
                    inputTFContainer.borderWidth = 0
                }
            }
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
            backgroundColor = .clear
            iconIV.image = IMG("setting.nextB")
            iconIV.isHidden = true
            inputTFContainer.backgroundColor = .white
            inputTFContainer.autoCornerRadius = 25
            inputTF.textColor = UIColor.black
            inputTF.font = XWallet.Font(ofSize: 16, weight: .bold)
            inputTF.autoFont = true
            inputTF.delegate = self
            inputTF.tintColor = COLOR.inputborder
            inputTF.keyboardType = .decimalPad
        }

        private func layoutUI() {
            addSubviews([iconIV, titleLabel, subTitleLabel, touch, inputTFContainer])
            iconIV.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
                make.left.equalTo(16.auto())
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(16.auto())
                make.height.equalTo(19.auto())
                make.left.equalTo(iconIV.snp.right).offset(10.auto())
            }
            subTitleLabel.snp.makeConstraints { make in
                make.left.equalTo(titleLabel.snp.left)
                make.right.equalToSuperview().offset(-24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
                make.height.equalTo(17.auto())
            }
            touch.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            inputTFContainer.snp.makeConstraints { make in
                make.top.equalTo(subTitleLabel.snp.bottom).offset(16.auto())
                make.left.equalTo(titleLabel.snp.left)
                make.right.equalToSuperview().offset(-16.auto())
                make.height.equalTo(50.auto())
            }
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let inverseSet = CharacterSet(charactersIn: "0123456789").inverted
            let components = string.components(separatedBy: inverseSet)
            let filtered = components.joined(separator: "")
            if range.length == 1, string == "" {
                return true
            }
            if filtered == string {
                if var newTextString = textField.text {
                    newTextString = newTextString.appending(string)
                    let numberDecimal = NSDecimalNumber(string: newTextString)
                    if newTextString == numberDecimal.description {
                        return true
                    } else {
                        let dotsCount = newTextString.components(separatedBy: ".").count
                        return (range.length == 0 && string == "0") && dotsCount == 2
                    }
                }
                return true
            } else {
                if string == "." || string == "," {
                    let countDots = textField.text!.components(separatedBy: ".").count - 1
                    let countCommas = textField.text!.components(separatedBy: ",").count - 1
                    if countDots == 0, countCommas == 0 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    if string.d != 0 {
                        return true
                    }
                    print(string.d)
                    return false
                }
            }
        }
    }
}

typealias EditState = EditPermissionViewController.State
extension EditPermissionViewController {
    enum State: Int {
        case unlimited = 0
        case custom
    }

    class ChoosePanel: SwapApproveViewController.BasePanel {
        lazy var unlimitedView = DefaultlimitView()
        lazy var customView = CustomlimitView()
        var unlimitedAmount: UILabel { return unlimitedView.amountLabel }
        var customInputTF: UITextField { return customView.inputTF }
        var unlimitedSelect: UIButton { return unlimitedView.touch }
        var customSelect: UIButton { return customView.touch }
        var type: State = .unlimited {
            didSet {
                switch type {
                case .unlimited:
                    unlimitedView.iconIV.isHidden = false
                    customView.iconIV.isHidden = true
                    customView.startEdit = false
                default:
                    unlimitedView.iconIV.isHidden = true
                    customView.iconIV.isHidden = false
                    customView.startEdit = true
                }
            }
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
            backgroundColor = .clear
        }

        private func layoutUI() {
            contentView.addSubviews([unlimitedView, customView])
            unlimitedView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(8.auto())
                make.height.equalTo(120.auto())
            }
            customView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(unlimitedView.snp.bottom).offset(8.auto())
                make.height.equalTo(142.auto())
            }
        }
    }
}
