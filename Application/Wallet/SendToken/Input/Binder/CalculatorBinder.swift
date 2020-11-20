import AudioToolbox
import RxCocoa
import WKKit
enum CalculatorOperation: Int {
    case OP_0 = 0
    case OP_1
    case OP_2
    case OP_3
    case OP_4
    case OP_5
    case OP_6
    case OP_7
    case OP_8
    case OP_9
    case OP_00
    case OP_Point
    case OP_AC
    case OP_Add
    case OP_Delete
    case OP_OK
    var isNumber: Bool { return rawValue <= 9 }
    var isAction: Bool { return self == .OP_Add || self == .OP_AC || self == .OP_Delete || self == .OP_OK }
    var value: String {
        switch self {
        case .OP_00: return "00"
        case .OP_Point: return "."
        case .OP_AC: return "AC"
        case .OP_OK: return "OK"
        default:
            return isNumber ? String(rawValue) : ""
        }
    }
}

private class CalculatorExpression {
    let operation: CalculatorOperation
    init(_ operation: CalculatorOperation) {
        self.operation = operation
    }

    var left = "0"
    var right = "0"
    func execute() -> String {
        if operation == .OP_Add { return left.add(right) }
        return ""
    }
}

class CalculatorBinder: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let size: CGSize
    private let itemSize: CGSize
    init(size: CGSize = CGSize(width: ScreenWidth, height: ScreenWidth)) {
        self.size = size
        itemSize = CGSize(width: (size.width - 0.1) / 4, height: (size.height - 0.1) / 4)
        super.init()
        configuration()
        exe(.OP_0)
    }

    let result = BehaviorRelay<String>(value: "")
    var confirmHandler: ((String) -> Void)?
    private var okCell: Cell?
    private var needClear = false
    private var expression: CalculatorExpression? {
        didSet {
            okCell?.textLabel.text = expression == nil ? "OK" : "="
        }
    }

    private let operations: [CalculatorOperation] = [.OP_1, .OP_4, .OP_7, .OP_00,
                                                     .OP_2, .OP_5, .OP_8, .OP_0,
                                                     .OP_3, .OP_6, .OP_9, .OP_Point,
                                                     .OP_Delete, .OP_AC, .OP_OK]
    var okIsEnabled: Bool {
        set { okCell?.isEnabled = newValue }
        get { okCell?.isEnabled ?? false }
    }

    func set(number: String) {
        clear()
        if number.isNotEmpty {
            result.accept(number)
        }
    }

    func back() {
        exe(.OP_Delete)
    }

    func clear() {
        exe(.OP_AC)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1519)
        let operation = operations[indexPath.row]
        if operation == .OP_OK, expression == nil {
            if okIsEnabled { confirmHandler?(result.value) }
            return
        }
        if operation == .OP_Add {
            if let _ = expression { exe(.OP_OK) }
            exe(.OP_Add)
        } else {
            if !needClear {
                exe(operation)
            } else {
                exe(.OP_AC)
                exe(operation)
            }
        }
        if !operation.isAction {
            (collectionView.cellForItem(at: indexPath) as? Cell)?.textLabel.layer.add(animation(), forKey: nil)
        }
    }

    private func exe(_ operation: CalculatorOperation) {
        needClear = false
        if operation == .OP_OK {
            if let e = expression {
                result.accept(e.execute())
                expression = nil
                needClear = true
            }
        } else if operation == .OP_Add {
            expression = CalculatorExpression(.OP_Add)
            expression?.left = result.value
        } else if operation == .OP_AC {
            expression = nil
            result.accept("")
            exe(.OP_0)
        } else {
            if let e = expression, e.operation == .OP_Add {
                e.right = handle(operation, forNumber: e.right)
                result.accept(e.right)
            } else {
                let current = handle(operation, forNumber: result.value)
                result.accept(current)
            }
        }
    }

    private func handle(_ operation: CalculatorOperation, forNumber num: String) -> String {
        var input = operation.value
        if operation == .OP_Delete { return num.count <= 1 ? "0" : num.substring(to: num.count - 2) }
        if operation == .OP_Point, num.isEmpty || num.contains(".") { return num }
        if operation == .OP_0, num == "0" { return num }
        if operation == .OP_00 {
            if num == "0" { return num }
            if num.isEmpty { input = "0" }
        }
        if num == "0", operation != .OP_Point {
            return input
        } else {
            return num + input
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch operations[indexPath.row] {
        case .OP_OK:
            return CGSize(width: itemSize.width, height: itemSize.height * 2)
        default:
            return itemSize
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0.0001
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0.0001
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return operations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.description(), for: indexPath) as! Cell
        cell.bind(operations[indexPath.row], width: itemSize.width, height: itemSize.height)
        if operations[indexPath.row] == .OP_OK {
            okCell = cell
        }
        return cell
    }

    private func configuration() {
        view.delegate = self
        view.dataSource = self
        view.register(Cell.self, forCellWithReuseIdentifier: Cell.description())
        view.reloadData()
    }

    private func animation() -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 2
        animation.fromValue = 1
        animation.duration = 0.1
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }

    lazy var view: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let v = UICollectionView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), collectionViewLayout: layout)
        v.backgroundColor = .clear
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.contentInsetAdjustmentBehavior = .never
        v.backgroundColor = .clear
        return v
    }()
}

extension CalculatorBinder {
    class Cell: UICollectionViewCell {
        var operation: CalculatorOperation = .OP_0
        fileprivate func bind(_ operation: CalculatorOperation, width: CGFloat, height: CGFloat) {
            self.operation = operation
            let bgWidth = (width - edge * 2)
            textLabel.text = operation.value
            actionBackground.isHidden = !operation.isAction
            actionBackground.cornerRadius = bgWidth * 0.5
            actionBackground.snp.updateConstraints { make in
                make.size.equalTo(CGSize(width: bgWidth, height: bgWidth))
            }
            switch operation {
            case .OP_Add:
                imageView.image = IMG("SendToken.Add")
            case .OP_Delete:
                imageView.image = IMG("SendToken.Delete")
            case .OP_OK:
                let bgHeight = max(bgWidth, height - edge * 2)
                actionBackground.backgroundColor = HDA(0x0552DC)
                actionBackground.snp.updateConstraints { make in
                    make.size.equalTo(CGSize(width: bgWidth, height: bgHeight * 2))
                }
                textLabel.font = XWallet.Font(ofSize: 24, weight: .bold)
                textLabel.autoFont = true
            default:
                break
            }
        }

        fileprivate var isEnabled: Bool = true {
            didSet {
                guard operation == .OP_OK else { return }
                actionBackground.backgroundColor = HDA(isEnabled ? 0x0552DC : 0x31324A)
                textLabel.alpha = isEnabled ? 1 : 0.1
            }
        }

        lazy var textLabel: UILabel = {
            let v = UILabel(font: XWallet.Font(ofSize: 24, weight: .medium))
            v.textAlignment = .center
            v.autoFont = true
            return v
        }()

        lazy var actionBackground = UIView(HDA(0x31324A))
        lazy var imageView = UIImageView(.clear)
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
            contentView.backgroundColor = .clear
        }

        var edge: CGFloat { 15 }
        private func layoutUI() {
            contentView.addSubviews([actionBackground, imageView, textLabel])
            actionBackground.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 40, height: 40).auto())
            }
            imageView.snp.makeConstraints { make in
                make.center.equalTo(actionBackground)
                make.size.equalTo(CGSize(width: 24, height: 24).auto())
            }
            textLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
}
