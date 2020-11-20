import RxCocoa
import RxSwift
import WKKit
extension SetCurrencyViewController {
    class CellViewModel {
        var item: Currency
        fileprivate(set) var selected = BehaviorRelay<Bool>(value: false)
        init(item: Currency) {
            self.item = item
            set(item: item)
        }

        func set(item: Currency) {
            self.item = item
            selected.accept(item.selected)
        }
    }
}
