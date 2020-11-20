import UIKit
extension BiometricsAlertViewController {
    class ContentCell: FxTableViewCell {
        private var viewModel: ViewModel?
        lazy var view = ContentView(frame: ScreenBounds)
        override func getView() -> UIView { view }
        override func bind(_ model: Any?) {
            guard let vm = model as? ViewModel else { return }
            viewModel = vm
            view.noticeLabel1.text = vm.title
            view.noticeLabel2.text = vm.subTitle
        }

        override class func height(model: Any?) -> CGFloat {
            guard let vm = model as? ViewModel else { return 0 }
            let width = ScreenWidth - 24.auto() * 2 * 2
            let font1: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 20, weight: .medium)
                $0.text = vm.title
                $0.autoFont = true
            }.font
            let font2: UIFont = UILabel().then {
                $0.font = XWallet.Font(ofSize: 14)
                $0.text = vm.subTitle
                $0.autoFont = true
            }.font
            let noticeHeight1 = vm.title.height(ofWidth: width, attributes: [.font: font1])
            let noticeHeight2 = vm.subTitle.height(ofWidth: width, attributes: [.font: font2])
            return (32 + 56).auto() + (16.auto() + noticeHeight1) + (16.auto() + noticeHeight2)
        }
    }
}
