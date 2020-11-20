import WKKit
extension BackUpNoticeViewController {
    class ItemView: UIView {
        lazy var titleLabel: UILabel = {
            let v = UILabel.title()
            v.text = TR("")
            return v
        }()
        lazy var subtitleLabel: UILabel = {
            let v = UILabel.subtitle()
            v.text = TR("")
            return v
        }()
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
            addSubviews([titleLabel, subtitleLabel])
            titleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalToSuperview()
                make.height.equalTo(29.auto())
            }
            subtitleLabel.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview().inset(24.auto())
                make.top.equalTo(titleLabel.snp.bottom).offset(8.auto())
            }
        }
    }
}
