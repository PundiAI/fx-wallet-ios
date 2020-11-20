import RxSwift
import WKKit
import XLPagerTabStrip
class TokenInfoPageBarCell: UICollectionViewCell {
    enum Types {
        case address
        case dapp
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }

    override var isSelected: Bool {
        didSet {
            textLabel.textColor = isSelected ? .white : UIColor.white.withAlphaComponent(0.5)
        }
    }

    var type: Types?
    func bind(_ vm: IndicatorInfo) {
        textLabel.text = vm.title
        type = vm.userInfo as? Types
    }

    private func layoutUI() {
        let textHeight = 22
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-textHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(textHeight)
        }
    }

    lazy var textLabel: UILabel = {
        let v = UILabel()
        v.font = XWallet.Font(ofSize: 18)
        v.textColor = UIColor.white.withAlphaComponent(0.5)
        v.textAlignment = .center
        v.backgroundColor = .clear
        return v
    }()
}

class PagerTabStriButtonBarViewDecorator {
    private let colorView = UIView(.white)
    private let view: ButtonBarView
    var defaultBag = DisposeBag()
    init(view: ButtonBarView) {
        self.view = view
        view.selectedBar.backgroundColor = .clear
        view.selectedBar.addSubview(colorView)
        colorView.cornerRadius = 2
        colorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-9)
            make.width.equalTo(width)
            make.height.equalTo(4)
        }
    }

    var color: UIColor? {
        get { return colorView.backgroundColor }
        set {
            colorView.backgroundColor = newValue
            view.selectedBar.backgroundColor = .clear
        }
    }

    var width: CGFloat = 40 {
        didSet {
            if view.selectedBar.width > 0,
                colorView.width != width
            {
                colorView.snp.updateConstraints { make in
                    make.width.equalTo(width)
                }
                UIView.animate(withDuration: 0.2) {
                    self.view.selectedBar.setNeedsLayout()
                }
            }
        }
    }
}
