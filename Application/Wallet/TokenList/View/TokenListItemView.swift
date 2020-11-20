
import WKKit
extension TokenListViewController {
    class ItemView: UIView {
        lazy var tokenIV = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var tokenLabel: UILabel = {
            let v = UILabel()
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.textColor = HDA(0x080A32)
            v.autoFont = true return v
        }()

        lazy var priceLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = HDA(0x080A32)
            return v
        }()

        lazy var rateLabel: UILabel = {
            let v = UILabel()
            v.text = TR("")
            v.font = XWallet.Font(ofSize: 12, weight: .medium)
            v.autoFont = true
            v.textColor = HDA(0xFA6237)
            return v
        }()

        lazy var balanceLabel: UILabel = {
            let v = UILabel()
            v.text = TR("--")
            v.font = XWallet.Font(ofSize: 14)
            v.autoFont = true
            v.textColor = HDA(0x080A32)
            return v
        }()

        lazy var legalBalanceLabel: UILabel = {
            let v = UILabel()
            v.text = TR("$-")
            v.font = XWallet.Font(ofSize: 18, weight: .medium)
            v.autoFont = true
            v.textColor = HDA(0x080A32)
            v.setContentCompressionResistancePriority(.required, for: .horizontal)
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
            addSubviews([tokenIV, tokenLabel, priceLabel, rateLabel, balanceLabel, legalBalanceLabel])
            tokenIV.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            tokenLabel.snp.makeConstraints { make in
                make.top.equalTo(tokenIV)
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
                make.right.lessThanOrEqualTo(legalBalanceLabel.snp.left)
                    .offset(-12.auto())
            }
            priceLabel.snp.makeConstraints { make in
                make.bottom.equalTo(tokenIV)
                make.left.equalTo(tokenIV.snp.right).offset(16.auto())
            }
            rateLabel.snp.makeConstraints { make in
                make.bottom.equalTo(tokenIV)
                make.left.equalTo(priceLabel.snp.right).offset(6.auto())
            }
            legalBalanceLabel.snp.makeConstraints { make in
                make.centerY.equalTo(tokenLabel)
                make.right.equalTo(-24.auto())
                make.left.greaterThanOrEqualTo(tokenLabel.snp.right)
                    .offset(12.auto())
                    .priority(.high)
            }
            balanceLabel.snp.makeConstraints { make in
                make.centerY.equalTo(priceLabel)
                make.right.equalTo(-24.auto())
            }
        }
    }
}
