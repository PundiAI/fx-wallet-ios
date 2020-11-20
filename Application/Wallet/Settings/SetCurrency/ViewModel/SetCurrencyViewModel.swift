import RxCocoa
import RxSwift
import SwiftyJSON
import WKKit
extension String {
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }

    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = removingDuplicates()
    }
}

extension SetCurrencyViewController {
    struct Currency {
        var countryname: String
        var name: String
        var currency: String
        var selected: Bool = false
    }

    struct Currencys {
        var indexs: [String] = []
        var items = [String: [CellViewModel]]()
    }

    class ViewModel {
        init() {
            do {
                if let fileURL = Bundle.main.url(forResource: "Currency", withExtension: "json") {
                    let datas = try Data(contentsOf: fileURL)
                    let json = try JSON(data: datas)
                    if let itemsJson = json.array {
                        let temp = itemsJson.map { CellViewModel(item: Currency(countryname: $0["countryname"].stringValue,
                                                                                name: $0["name"].stringValue,
                                                                                currency: $0["currency"].stringValue)) }
                        let result = temp.filter { $0.item.currency.length != 0 }.sorted(by: { $0.item.currency < $1.item.currency })
                        items = result
                        currencys = ViewModel.groupItmes(items: result)
                    }
                }
            } catch let error as NSError {
                WKLog.Error(error.domain)
            }
        }

        var items: [CellViewModel]?
        var currencys: Currencys?
        typealias GroupModels = [String: [CellViewModel]]
        class func isContains(items: [CellViewModel], tager: CellViewModel) -> Bool {
            for item in items {
                if item.item.currency == tager.item.currency {
                    return true
                }
            }
            return false
        }

        class func groupItmes(items: [CellViewModel]) -> Currencys {
            var datas = Currencys()
            let indexs = ViewModel.getIndexs(items: items)
            datas.indexs = indexs
            for item in items {
                if let idx = ViewModel.getCharactor(string: item.item.currency) {
                    if let arr = datas.items[idx], arr.count > 0 {
                        if !ViewModel.isContains(items: arr, tager: item) {
                            datas.items[idx]?.append(item)
                        }
                    } else {
                        datas.items[idx] = [CellViewModel]()
                        datas.items[idx]?.append(item)
                    }
                }
            }
            for item in datas.items {
                let params = item.value
                if params.count > 0 {
                    datas.items[item.key] = params.sorted(by: { (c1, c2) -> Bool in
                        c1.item.currency < c2.item.currency
                    })
                }
            }
            return datas
        }

        class func getIndexs(items: [CellViewModel]) -> [String] {
            var _indexs = [String]()
            for item in items {
                if let idx = ViewModel.getCharactor(string: item.item.currency) {
                    _indexs.push(newElement: idx)
                }
            }
            return _indexs.removingDuplicates().sorted { $0 < $1 }
        }

        class func getCharactor(string: String) -> String? {
            let mString = NSMutableString(string: string) as CFMutableString
            if CFStringTransform(mString, nil, kCFStringTransformToLatin, false) {
                if CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false) {
                    if let string = String(mString).replacingOccurrences(of: " ", with: "").character(at: 0) {
                        return String(string).uppercased()
                    }
                }
            }
            return nil
        }
    }
}
