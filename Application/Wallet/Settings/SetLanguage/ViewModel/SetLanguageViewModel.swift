import RxCocoa
import RxSwift
import WKKit
extension SetLanguageViewController {
    struct Language {
        var name: String
        var selected: Bool = false
    }

    class ViewModel {
        init() {
            items = [Language(name: "Engish", selected: true),
                     Language(name: "French"),
                     Language(name: "Spanish"),
                     Language(name: "Chinese")].map { CellViewModel(item: $0) }
        }

        var items: [CellViewModel]
        func selecdItem() -> Language? {
            return items.filter { $0.item.selected }.firstObject()?.item
        }
    }
}

public struct LanguageItem {
    public var identifier: String
    public var key: String
    public var title: String
}

open class WKLanguage: NSObject {
    let locale: Locale!
    public init(locale: Locale) {
        self.locale = locale
        super.init()
    }
}

open class WKLocale: NSObject {
    public static var boundle: (() -> Bundle?)? = {
        {
            var language = WKLocale.Shared.localeIdentifier
            if language.length == 0 {
                language = "en"
            }
            if language == "en_US" {
                language = "en"
            }
            var path: String? = Bundle.main.path(forResource: language, ofType: "lproj")!
            if let _path = path {
                return Bundle(path: _path)
            }
            return nil
        }
    }()

    public lazy var languages: [LanguageItem] = {
        var items = [LanguageItem]()
        items.append(LanguageItem(identifier: "en", key: "eng", title: "English"))
        items.append(LanguageItem(identifier: "es", key: "Spanish", title: "Español"))
        items.append(LanguageItem(identifier: "zh-Hant-TW", key: "TW", title: "繁体中文"))
        items.append(LanguageItem(identifier: "ko", key: "KO", title: "한국어"))
        items.append(LanguageItem(identifier: "de", key: "de", title: "Deutsch"))
        items.append(LanguageItem(identifier: "pt-PT", key: "pt", title: "Português (Brasil)"))
        return items
    }()

    static let Key_Locale_Identifier: String = "Key_Locale_Identifier"
    public var localeIdentifier: String {
        get {
            if let identifier = UserDefaults.standard.value(forKey: WKLocale.Key_Locale_Identifier) as? String {
                return identifier
            } else {
                var _identifier = "en"
                if NSLocale.preferredLanguages[0].hasPrefix("es") {
                    _identifier = "es"
                }
                if NSLocale.preferredLanguages[0].hasPrefix("zh-Hant-TW") ||
                    NSLocale.preferredLanguages[0].hasPrefix("zh-Hant-HK")
                {
                    _identifier = "zh-Hant-TW"
                }
                if NSLocale.preferredLanguages[0].hasPrefix("ko") {
                    _identifier = "ko"
                }
                if NSLocale.preferredLanguages[0].hasPrefix("de") {
                    _identifier = "de"
                }
                if NSLocale.preferredLanguages[0].hasPrefix("pt-BR") ||
                    NSLocale.preferredLanguages[0].hasPrefix("pt-PT")
                {
                    _identifier = "pt-PT"
                }
                UserDefaults.standard.setValue(_identifier, forKey: WKLocale.Key_Locale_Identifier)
                UserDefaults.standard.synchronize()
                return _identifier
            }
            return "en"
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: WKLocale.Key_Locale_Identifier)
            UserDefaults.standard.synchronize()
        }
    }

    public var language: LanguageItem {
        get {
            if let identifier = UserDefaults.standard.value(forKey: WKLocale.Key_Locale_Identifier) as? String {
                if let index = languages.indexOf(condition: { (item) -> Bool in
                    item.identifier == identifier
                }) {
                    if let item = languages.get(index) {
                        return item
                    }
                }
            }
            return LanguageItem(identifier: "en_US", key: "eng", title: "English")
        }
        set {
            let value = newValue.identifier
            UserDefaults.standard.setValue(value, forKey: WKLocale.Key_Locale_Identifier)
            UserDefaults.standard.synchronize()
        }
    }

    public static var Shared: WKLocale = {
        WKLocale()
    }()

    private var locale: Locale {
        return Locale(identifier: localeIdentifier)
    }

    public static var Language: WKLanguage {
        return WKLanguage(locale: WKLocale.Shared.locale)
    }
}
