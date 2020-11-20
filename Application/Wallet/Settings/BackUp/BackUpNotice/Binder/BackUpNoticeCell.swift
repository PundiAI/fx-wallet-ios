import WKKit
import RxSwift
import RxCocoa
extension BackUpNoticeViewController {
    class Cell: FxTableViewCell {
        private var viewModel: CellViewModel?
        lazy var view = ItemView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ viewModel: Any?) {
            guard let vm = viewModel as? CellViewModel else { return }
            self.viewModel = vm
            view.titleLabel.text = vm.title
            vm.subTitle.lineSpacingLabel(view.subtitleLabel)
            view.subtitleLabel.autoFont = true
        }
        override class func height(model: Any?) -> CGFloat {
            let width = ScreenWidth - 24.auto() * 2
            if let vm =  model as? CellViewModel {
                if vm.subTitle.length > 0 {
                    let font2: UIFont = UILabel().then {
                        $0.font = XWallet.Font(ofSize: 16)

                        vm.subTitle.lineSpacingLabel($0)
                        $0.autoFont = true }.font
                    let style = NSMutableParagraphStyle().then { $0.lineSpacing = 4.auto() }
                    let height = vm.subTitle.height(ofWidth: width, attributes: [.font: font2,
                                                                                 .paragraphStyle: style])
                    return (29 + 8).auto() + height + 24.auto()
                } else {
                    return 29.auto() + 26.auto()
                }
            }
            return 29.auto()
        }
    }
}
