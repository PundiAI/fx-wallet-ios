//
//  util.swift
//  XWallet
//
//  Created by 梅杰 on 2018/8/23.
//  Copyright © 2018年 Chen Andy. All rights reserved.
//

import UIKit
import WKKit

/**
 * 千分位 和 小数点后有效位
 * @parameter string  传入字符串
 * @parameter precision 保留几位小数
 */
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
    // MARK: 添加千分位的函数实现
    func addMicrometerLevel() -> String {
        // 判断传入参数是否有值
        if self.count != 0 {
            /**
             创建两个变量
             integerPart : 传入参数的整数部分
             decimalPart : 传入参数的小数部分
             */
            var integerPart: String?
            var decimalPart = String.init()

            // 先将传入的参数整体赋值给整数部分
            integerPart =  self
            // 然后再判断是否含有小数点(分割出整数和小数部分)
            if self.contains(".") {
                let segmentationArray = self.components(separatedBy: ".")
                integerPart = segmentationArray.first
                decimalPart = segmentationArray.last!
            }

            /**
             创建临时存放余数的可变数组
             */
            let remainderMutableArray = NSMutableArray.init(capacity: 0)
            // 创建一个临时存储商的变量
            var discussValue: Int32 = 0

            /**
             对传入参数的整数部分进行千分拆分
             */
            repeat {
                let tempValue = integerPart! as NSString
                // 获取商
                discussValue = tempValue.intValue / 1000
                // 获取余数
                let remainderValue = tempValue.intValue % 1000
                // 将余数一字符串的形式添加到可变数组里面
                let remainderStr = String.init(format: "%d", remainderValue)
                remainderMutableArray.insert(remainderStr, at: 0)
                // 将商重新复制
                integerPart = String.init(format: "%d", discussValue)
            } while discussValue>0

            // 创建一个临时存储余数数组里的对象拼接起来的对象
            var tempString = String.init()

            // 根据传入参数的小数部分是否存在，是拼接“.” 还是不拼接""
            let lastKey = (decimalPart.count == 0 ? "":".")
            /**
             获取余数组里的余数
             */
            for i in 0..<remainderMutableArray.count {
                // 判断余数数组是否遍历到最后一位
                let  param = (i != remainderMutableArray.count-1 ?",":lastKey)
                tempString = tempString + String.init(format: "%@%@", remainderMutableArray[i] as! String, param)
            }
            //  清楚一些数据
            integerPart = nil
            remainderMutableArray.removeAllObjects()
            // 最后返回整数和小数的合并
            return tempString as String + decimalPart
        }
        return self
    }

    // MARK: 获取字符串的长度
    func length() -> Int {
        /**
         另一种方法：
         let tempStr = self as NSString
         return tempStr.length
         */
        return self.count
    }
}

// 数字格式化............
//func separatedNoFloatStrWith(_ b: Double, afterPoint: Int) -> String {
//    return  separatedFloatStrWith( "\(b)" as NSString, precision: afterPoint)
//}
//
//
//func not_Rounding(_ b: Double, afterPoint: Int) -> String {
//    return separatedNoFloatStrWith(string: "\(b)" as NSString, precision: afterPoint)
//}

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
            //          formatter.dateFormat = "YYYY-MM-dd HH:mm:ss zzz"
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

    ///四舍五入 到小数点后某一位
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    ///截断  到小数点后某一位
    func truncate(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Double(Int(self * divisor)) / divisor
    }
}

func isDeLanguage() -> Bool {
    return WKLocale.Shared.localeIdentifier == "de"
}

extension String {
    //字符串截取
    func separatedEightString() -> String {
        if let value = self.firstIndex(of: "."), let deRange = self.range(of: ".") {
            let backNumber = self.suffix(from: deRange.upperBound)
            if  String(backNumber).length > 8 {
                let index2 = self.index(value, offsetBy: 8)
                return String(self[self.startIndex...index2])
            }
            //            //截取小数点前字符(不包含小数点)  123
            //            let wholeNumber = num.prefix(upTo: deRange!.lowerBound)
            //            //截取小数点后字符(不包含小数点) 45
            //            let backNumber = num.suffix(from: deRange!.upperBound)
            //            //截取小数点前字符(包含小数点) 123.
            //            let wholeNumbers = num.prefix(upTo: deRange!.upperBound)
            //            //截取小数点后字符(包含小数点) .45
            //            let backNumbers = num.suffix(from: deRange!.lowerBound)
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

    /// 获取当前 毫秒级 时间戳 - 13位
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
