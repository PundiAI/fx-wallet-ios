import RxCocoa
import RxSwift
import WKKit
extension SetLanguageViewController {
    class CellViewModel {
        var item: Language
        fileprivate(set) var selected = BehaviorRelay<Bool>(value: false)
        init(item: Language) {
            self.item = item
            set(item: item)
        }

        func set(item: Language) {
            self.item = item
            selected.accept(item.selected)
        }
    }
}
