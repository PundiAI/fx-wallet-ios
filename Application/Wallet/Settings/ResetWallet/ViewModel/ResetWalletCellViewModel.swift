import RxCocoa
import RxSwift
import WKKit
extension ResetWalletViewController {
    class CellViewModel {
        init(_ title: String, _ subTitle: String, _ subMarkTitle: String) {
            self.title = title
            self.subTitle = subTitle
            self.subMarkTitle = subMarkTitle
        }

        let title: String
        let subTitle: String
        let subMarkTitle: String
    }
}
