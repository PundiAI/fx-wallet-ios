import WKKit
extension CheckBackUpViewController {
    static  let subMessage = TR("CheckBackUp.SubTitle$", "0")
    class View: UIView {
        class TagButton: UIButton {
            override init(frame: CGRect) {
                super.init(frame: frame)
                self.image = nil
                self.disabledImage = nil
                self.isExclusiveTouch = true
                if title != nil { self.title = title }
                self.titleFont = XWallet.Font(ofSize: 18)
                self.titleLabel?.autoFont = true
                self.titleColor = .black
                setBackgroundImage(UIImage.createImageWithColor(color: .white), for: .normal)
                self.autoCornerRadius = 8
                self.borderColor = COLOR.title.withAlphaComponent(0.2)
                self.borderWidth = 1
                self.isNSelected = false
            }
            var isNSelected = false {
                didSet {
                    if isNSelected {
                        self.titleColor = .white
                        setBackgroundImage(UIImage.createImageWithColor(color: COLOR.title), for: .normal)
                        self.layer.borderWidth = 0
                    } else {
                        self.titleColor = .black
                        setBackgroundImage(UIImage.createImageWithColor(color: .white), for: .normal)
                        self.layer.borderWidth = 1
                    }
                }
            }
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        lazy var titleLabel: UILabel = {
            let v = UILabel.title()
            return v
        }()
        lazy var stepLabel: UILabel = {
            let v = UILabel.title()
            v.textAlignment = .right
            return v
        }()
        lazy var bordView: UIView = {
            let v = UIView(.white)
            v.autoCornerRadius = 8
            v.borderColor = COLOR.title.withAlphaComponent(0.2)
            v.borderWidth = 1
            return v
        }()
        lazy var idxLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 24)
            v.autoFont = true
            return v
        }()
        lazy var selectdLabel: UILabel = {
            let v = UILabel.title()
            return v
        }()
        lazy var subtitleLabel: UILabel = {
            let v = UILabel.subtitle()
            return v
        }()
        var tagButtons: [TagButton] = []
        var copyClosure: ((Int, String)->Void)?
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override init(frame: CGRect) {
            super.init(frame: frame)
            logWhenDeinit()
            configuration()
            layoutUI()
        }
        private func configuration() {
            backgroundColor = .white
            titleLabel.text = TR("CheckBackUp.MainTitle")
            let subTitle = subMessage
            subTitle.lineSpacingLabel(subtitleLabel)
            subtitleLabel.autoFont = true
        }
        private func layoutUI() {
            addSubview(titleLabel)
            addSubview(stepLabel)
            addSubview(bordView)
            bordView.addSubview(idxLabel)
            bordView.addSubview(selectdLabel)
            addSubview(subtitleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(24.auto())
                make.top.equalTo(FullNavBarHeight + 8.auto())
                make.height.equalTo(29.auto())
            }
            stepLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-24.auto())
                make.centerY.equalTo(titleLabel)
            }
            bordView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(60.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(39.auto())
            }
            idxLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(24.auto())
                make.centerY.equalToSuperview()
            }
            selectdLabel.snp.makeConstraints { (make) in
                make.left.equalTo(idxLabel.snp.right).offset(12.auto())
                make.centerY.equalToSuperview()
            }
            subtitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(bordView.snp.bottom).offset(40.auto())
            }
        }
        func bindButton(tags: [String]) {
            var startX: CGFloat = 24.0.auto()
            let buttonHeihgt: CGFloat = 38.auto()
            let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto()}
            let font2: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 16)
                subMessage.lineSpacingLabel($0)
                $0.autoFont = true }.font
            let height = (subMessage).height(ofWidth: ScreenWidth - 2 * 24.auto(), attributes: [.font: font2, .paragraphStyle: style])
            let top = (FullNavBarHeight + 8.auto()) + 29.auto() + (30 + 60).auto() + (40.auto() + height ) + CGFloat(startX).auto()
            var startY: CGFloat = 0
            for (idx, value) in tags.enumerated() {
                var tagSize = CGSize.zero
                tagSize.width = value.size(with: CGSize(width: ScreenWidth, height: buttonHeihgt), font: XWallet.Font(ofSize: 18)).width + 34.auto()
                tagSize.height = buttonHeihgt
                if idx / 3 == 0 {
                    startY = top
                } else {
                    startY = top + buttonHeihgt + 24.auto()
                }
                if idx % 3 == 0 {
                    startX = 24.auto()
                } else if idx % 3 == 1 {
                    startX = (ScreenWidth - tagSize.width) / 2
                } else if idx % 3 == 2 {
                    startX = ScreenWidth - tagSize.width - 24.auto()
                }
                let buttonFrame = CGRect(x: startX, y: startY, width: tagSize.width, height: tagSize.height)
                let btn = TagButton(frame: buttonFrame)
                btn.title = value
                btn.titleLabel?.autoFont = true
                btn.tag = idx
                self.addSubview(btn)
                self.tagButtons.append(btn)
                btn.addTarget(self, action: #selector(View.btnAction(btn:)), for: .touchUpInside)
            }
        }
        var idxTag = 0 {
            didSet {
                if idxTag != 0 {
                    idxLabel.text = "\(idxTag)."
                }
            }
        }
        @objc func btnAction(btn: TagButton) {
            for item in self.tagButtons {
                if item.tag == btn.tag {
                    if !btn.isNSelected {
                        btn.isNSelected  = true
                        self.selectdLabel.text = btn.titleLabel?.text
                        self.copyClosure?(idxTag, (btn.titleLabel?.text ?? ""))
                    }
                } else {
                    item.isNSelected = false
                }
            }
        }
    }
}
