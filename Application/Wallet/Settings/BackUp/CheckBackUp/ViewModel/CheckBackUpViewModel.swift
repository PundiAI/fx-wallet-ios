import WKKit
import RxSwift
import RxCocoa
extension CheckBackUpViewController {
    class ViewModel {
        var currentPage: Int = 1
        var selected: [(Int, String)] = []
        var checkIdxMnemonics: [(Int, String)] = []
        var checkMnemonics: [String] = []
        var errorMnemonics: [String] = []
        init(mnemonic: String) {
            self.mnemonic = mnemonic
            self.bind()
        }
        var mnemonic: String
        var mnemoniclist: [String] {
            let tags = mnemonic.split(separator: " ")
            var list: [String] = []
            for tag in tags {
                list.append(String(tag))
            }
            return list
        }
        private func bind() {
            checkMnemonics = setCheckData(list: mnemoniclist)
            setErrorMnemonics(list: mnemoniclist, checkData: checkMnemonics)
        }
        private func setCheckData(list: [String]) -> [String] {
            var temp: [String] = []
            while temp.count < 3 {
                if let random = list.randomElement() {
                    if !temp.contains(random) {
                        temp.append(random)
                    }
                }
            }
            return temp
        }
        private func setErrorMnemonics(list: [String], checkData: [String]) {
            errorMnemonics = list.filter { !checkData.contains($0)}
        }
        func getRandomTags() -> (Int, [String])? {
            var temp: [String] = []
            while temp.count < 5 {
                if let random = errorMnemonics.randomElement() {
                    if !temp.contains(random) {
                        temp.append(random)
                    }
                }
            }
            let current = checkMnemonics[currentPage-1]
            let newIndex = Int(arc4random_uniform(UInt32(6)))
            temp.insert(current, at: newIndex)
            if let idx = mnemoniclist.indexOf(condition: { $0 == current}) {
                return (idx + 1, temp)
            }
            return nil
        }
        func check() -> Bool {
            var bool = true
            for item in selected {
                if mnemoniclist[item.0-1] != item.1 {
                    bool = false
                    break
                }
            }
            return bool
        }
    }
}
