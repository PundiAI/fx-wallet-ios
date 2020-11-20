import RxCocoa
import RxSwift
import WKKit
extension String {
    func lineSpacingLabel(_ label: UILabel, lineSpace: CGFloat = 4) {
        guard let _font = label.font, let _color = label.textColor else {
            return
        }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpace.auto()
        label.attributedText = NSMutableAttributedString(string: self,
                                                         attributes: [NSAttributedString.Key.foregroundColor: _color,
                                                                      NSAttributedString.Key.font: _font,
                                                                      NSAttributedString.Key.paragraphStyle: style])
    }
}

extension ResetWalletViewController {
    class Cell: FxTableViewCell {
        private var viewModel: CellViewModel?
        lazy var view = Content(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            view.titleLabel.text = vm.title
            vm.subTitle.lineSpacingLabel(view.subtitleLabel)
            view.subtitleLabel.autoFont = true
            vm.subMarkTitle.lineSpacingLabel(view.subMarkTitleLabel)
            view.subMarkTitleLabel.autoFont = true
        }

        override class func height(model: Any?) -> CGFloat {
            if let vm = model as? CellViewModel {
                let width = ScreenWidth - 24.auto() * 2
                let style = NSMutableParagraphStyle().then { $0.lineSpacing = 8.auto() }
                let font1 = UILabel().then {
                    $0.font = XWallet.Font(ofSize: 16)
                    vm.subTitle.lineSpacingLabel($0)
                    $0.autoFont = true
                }.font!
                let font2 = UILabel().then {
                    $0.font = XWallet.Font(ofSize: 16, weight: .bold)
                    vm.subMarkTitle.lineSpacingLabel($0)
                    $0.autoFont = true
                }.font!
                let subHeight = vm.subTitle.height(ofWidth: width, attributes: [.font: font1,
                                                                                .paragraphStyle: style])
                let subMarkHeight = vm.subMarkTitle.height(ofWidth: width, attributes: [.font: font2,
                                                                                        .paragraphStyle: style])
                return (8 + 29 + 16).auto() + subHeight + 4.auto() + subMarkHeight + 30.auto()
            }
            return 0
        }
    }
}

extension ResetWalletViewController {
    class InputCell: FxTableViewCell {
        private var viewModel: String?
        lazy var view = InputView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? String else { return }
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8.auto()
            let attr = NSMutableAttributedString(string: vm, attributes: [.font: XWallet.Font(ofSize: 16),
                                                                          .foregroundColor: COLOR.title,
                                                                          .paragraphStyle: style])
            let rangBlock: ((String, String) -> NSRange?) = { text, subText in
                if let range: Range<String.Index> = text.range(of: subText) {
                    return text.convert(range: range)
                }
                return nil
            }
            if let rang = rangBlock(vm, TR("\(resetWalletMessage)")) {
                attr.addAttributes([.font: XWallet.Font(ofSize: 16, weight: .bold),
                                    .foregroundColor: COLOR.title], range: rang)
            }
            view.titleLabel.attributedText = attr
            view.titleLabel.autoFont = true
        }

        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? String else { return 0 }
            let width = ScreenWidth - 24.auto() * 2
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8.auto()
            let height = vm.height(ofWidth: width, attributes: [.font: XWallet.Font(ofSize: 16),
                                                                .paragraphStyle: style])
            return (8.auto() + height + 16.auto()) + 68.auto() + (24 + 56 + 24).auto()
        }
    }
}
