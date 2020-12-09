import UIKit
import WKKit

func separatedFloatStrWith(_ string: String, afterPoint: Int) -> String {

    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en")

    if WKLocale.Shared.language.converIdentifier == "de_DE" {
        formatter.locale = Locale(identifier: "de")
    }

    formatter.roundingMode = .floor
    let value = NSDecimalNumber(string: string)
    var format = NSMutableString(string: "###,##0")
    if afterPoint == 0 {
        formatter.positiveFormat = format as String
        return formatter.string(from: value)!

    } else {
        format = NSMutableString(string: "###,##0.")
        for _ in 1...afterPoint {
            format.appendFormat("0")
        }
        formatter.positiveFormat = format as String
        return formatter.string(from: value)!
    }
}

func separatedNoFloatStrWith(_ string: String, afterPoint: Int) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en")

    if WKLocale.Shared.language.converIdentifier == "de_DE" {
        formatter.locale = Locale(identifier: "de")
    }

    formatter.roundingMode = .floor

    let value = NSDecimalNumber(string: string)

    var format = NSMutableString(string: "#####0")
    if afterPoint == 0 {
        formatter.positiveFormat = format as String
        return formatter.string(from: value)!
    } else {
        format = NSMutableString(string: "#####0.")
        for _ in 1...afterPoint {
            format.appendFormat("0")
        }
        formatter.positiveFormat = format as String
        return formatter.string(from: value)!
    }
}

func separatedNo3FloatStrWith(_ string: String, afterPoint: Int) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en")

    formatter.roundingMode = .floor

    let value = NSDecimalNumber(string: string)

    var format = NSMutableString(string: "#####0")
    if afterPoint == 0 {
        formatter.positiveFormat = format as String
        return formatter.string(from: value)!
    } else {
        format = NSMutableString(string: "#####0.")
        for _ in 1...afterPoint {
            format.appendFormat("0")
        }
        formatter.positiveFormat = format as String
        return formatter.string(from: value)!
    }
}

extension String { 
    func addMicrometerLevel() -> String { 
        if self.count != 0 { 
            var integerPart: String?
            var decimalPart = String.init()
 
            integerPart =  self 
            if self.contains(".") {
                let segmentationArray = self.components(separatedBy: ".")
                integerPart = segmentationArray.first
                decimalPart = segmentationArray.last!
            } 
            let remainderMutableArray = NSMutableArray.init(capacity: 0) 
            var discussValue: Int32 = 0 
            repeat {
                let tempValue = integerPart! as NSString 
                discussValue = tempValue.intValue / 1000 
                let remainderValue = tempValue.intValue % 1000 
                let remainderStr = String.init(format: "%d", remainderValue)
                remainderMutableArray.insert(remainderStr, at: 0) 
                integerPart = String.init(format: "%d", discussValue)
            } while discussValue>0
 
            var tempString = String.init()
 
            let lastKey = (decimalPart.count == 0 ? "":".") 
            for i in 0..<remainderMutableArray.count { 
                let  param = (i != remainderMutableArray.count-1 ?",":lastKey)
                tempString = tempString + String.init(format: "%@%@", remainderMutableArray[i] as! String, param)
            } 
            integerPart = nil
            remainderMutableArray.removeAllObjects() 
            return tempString as String + decimalPart
        }
        return self
    }
 
    func length() -> Int { 
        return self.count
    }
}
 
extension String {
    func timeString() -> String {
        if self.length == 0 {
            return self
        }
        if let time = Double(self) {
            if time == 0 {
                return ""
            }
            let timeStamp = TimeInterval(Int(time/1000))
            let date = Date(timeIntervalSince1970: timeStamp)
            let formatter = DateFormatter() 
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            return formatter.string(from: date)
        }
        return self
    }

    func simpleTimeString() -> String {
        if let time = Double(self) {
            let timeStamp = TimeInterval(Int(time/1000))
            let date = Date(timeIntervalSince1970: timeStamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            return formatter.string(from: date)
        }
        return self
    }
}

extension Double {
    func timeString() -> String {
        let timeStamp = TimeInterval(Int(self/1000))
        let date = Date(timeIntervalSince1970: timeStamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        if WKLocale.Shared.localeIdentifier == "de" {
            formatter.dateFormat = "dd.mm HH:mm"
        }
        return formatter.string(from: date)
    }

    func timeAllString() -> String {
        let timeStamp = TimeInterval(Int(self/1000))
        let date = Date(timeIntervalSince1970: timeStamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        if WKLocale.Shared.localeIdentifier == "de" {
            formatter.dateFormat = "dd.mm.yyyy HH:mm:ss"
        }
        return formatter.string(from: date)
    }
 
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    } 
    func truncate(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Double(Int(self * divisor)) / divisor
    }
}

func isDeLanguage() -> Bool {
    return WKLocale.Shared.localeIdentifier == "de"
}

extension String { 
    func separatedEightString() -> String {
        if let value = self.firstIndex(of: "."), let deRange = self.range(of: ".") {
            let backNumber = self.suffix(from: deRange.upperBound)
            if  String(backNumber).length > 8 {
                let index2 = self.index(value, offsetBy: 8)
                return String(self[self.startIndex...index2])
            } 
        }
        return self
    }
}

extension String {
    func decimal(_ scale: Int = 8, _ hasSeparator: Bool = true) -> String {
        if hasSeparator {
            return separatedFloatStrWith(self, afterPoint: scale)
        } else {
            return separatedNoFloatStrWith(self, afterPoint: scale)
        }
    }
}

extension Date {
    var ymd: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        return dateFormatter.string(from: self)
    }

    var y_m_d: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    var timestamp: Double {
        return self.timeIntervalSince1970 * 1000
    }
 
    public var milliStamp: Int64 {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let time = CLongLong(round(timeInterval*1000))
        return Int64(time)
    }
}

extension String {

    var timeToTimeStamp: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:MM:SS"
        if let date = dateFormatter.date(from: self) {
            return String(date.timeIntervalSince1970)
        }
        return nil
    }

    var timeToTimeData: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }

    func hasEmoji() -> Bool {
        let pattern = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: self)
    }

}
