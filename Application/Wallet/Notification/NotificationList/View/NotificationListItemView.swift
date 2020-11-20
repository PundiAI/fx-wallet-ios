import pop
import RxCocoa
import RxSwift
import SwipeCellKit
import WKKit
extension NotificationListViewController {
    class Cell: SwipeCollectionViewCell {
        lazy var contentBGView: UIView = {
            let v = UIView(.white)
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()

        lazy var textLabel = UILabel(font: XWallet.Font(ofSize: 14), textColor: COLOR.title, lines: 0)
        lazy var dateLabel = UILabel(font: XWallet.Font(ofSize: 12, weight: .medium), textColor: COLOR.subtitle)
        lazy var imageView = CoinImageView(size: CGSize(width: 48, height: 48).auto())
        lazy var addTokenBGView: UIView = {
            let v = UIView(HDA(0xF4F4F4))
            v.wk.displayShadow()
            v.layer.cornerRadius = 36.auto()
            v.layer.masksToBounds = false
            return v
        }()

        lazy var addTokenLabel = UILabel(text: TR("Notif.AddTokenNotice$", "NPXS"), font: XWallet.Font(ofSize: 14, weight: .medium), textColor: COLOR.title, lines: 0, alignment: .center)
        lazy var addTokenButton: UIButton = {
            let v = UIButton(COLOR.title, cornerRadius: 28)
            v.titleFont = XWallet.Font(ofSize: 18, weight: .medium)
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

        var reuseBag = DisposeBag()
        override func prepareForReuse() {
            super.prepareForReuse()
            reuseBag = DisposeBag()
        }

        func configuration() {
            backgroundColor = .clear
            imageView.isHidden = true
            addTokenBGView.isHidden = true
        }

        func layoutUI() {
            contentView.addSubviews([contentBGView, textLabel, dateLabel, imageView])
            contentBGView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            textLabel.snp.makeConstraints { make in
                make.top.equalTo(contentBGView).offset(32.auto())
                make.left.equalTo(contentBGView).offset(24.auto())
                make.right.equalTo(contentBGView).offset(-24.auto())
            }
            dateLabel.snp.makeConstraints { make in
                make.top.equalTo(textLabel.snp.bottom).offset(8.auto())
                make.left.right.equalTo(contentBGView).inset(24.auto())
                make.height.equalTo(20.auto())
            }
        }

        func layoutForTx() {
            contentView.insertSubview(addTokenBGView, at: 0)
            addTokenBGView.addSubviews([addTokenLabel, addTokenButton])
            contentBGView.snp.remakeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(130)
            }
            imageView.snp.makeConstraints { make in
                make.top.equalTo(contentBGView).offset(32.auto())
                make.right.equalTo(contentBGView).offset(-24.auto())
                make.size.equalTo(CGSize(width: 48, height: 48).auto())
            }
            addTokenBGView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            addTokenLabel.snp.makeConstraints { make in
                make.top.equalTo(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
            }
            addTokenButton.snp.makeConstraints { make in
                make.top.equalTo(addTokenLabel.snp.bottom).offset(16.auto())
                make.left.right.equalToSuperview().inset(24.auto())
                make.height.equalTo(56.auto())
            }
        }

        func relayoutForTx(contentHeight: CGFloat, _ showAdd: Bool = false) {
            imageView.isHidden = !showAdd
            addTokenBGView.isHidden = !showAdd
            contentBGView.snp.updateConstraints { make in
                make.height.equalTo(contentHeight)
            }
            if !showAdd {
                textLabel.snp.updateConstraints { make in
                    make.right.equalTo(contentBGView).offset(-24.auto())
                }
            } else {
                textLabel.snp.updateConstraints { make in
                    make.right.equalTo(contentBGView).offset(-96.auto())
                }
                addTokenLabel.snp.updateConstraints { make in
                    make.top.equalTo(contentHeight + 16.auto())
                }
            }
        }
    }
}
