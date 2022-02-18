//
//  RampViewController.swift
//  RampExample
//
//  Created by Mateusz Jabłoński on 15/01/2021.
//

import Foundation

struct Ramp {
    
    static let notification: Notification.Name = .init("ramp.callback.notification")
    
    static func sendNotificationIfUrlValid(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let scheme = components.scheme, scheme == RampConfig.finaUrlScheme
        {
            let notification = Notification(name: Ramp.notification, object: url, userInfo: nil)
            NotificationCenter.default.post(notification)
        }
    }
    
    struct Configuration {
        var swapAsset: String? = nil
        var swapAmount: String? = nil
        var fiatCurrency: String? = nil
        var fiatValue: String? = nil
        var userAddress: String? = nil
        var hostLogoUrl: String? = nil
        var hostAppName: String? = nil
        var userEmailAddress: String? = nil
        var url: String
        var finalUrl: String? = nil
        var variant: String? = nil
        var hostApiKey: String? = nil
        
        func composeUrl() -> URL {
            var urlComponents = URLComponents(string: url)!
            urlComponents.appendQueryItem(name: "swapAsset", value: swapAsset)
            urlComponents.appendQueryItem(name: "swapAmount", value: swapAmount)
            urlComponents.appendQueryItem(name: "fiatCurrency", value: fiatCurrency)
            urlComponents.appendQueryItem(name: "fiatValue", value: fiatValue)
            urlComponents.appendQueryItem(name: "userAddress", value: userAddress)
            urlComponents.appendQueryItem(name: "hostLogoUrl", value: hostLogoUrl)
            urlComponents.appendQueryItem(name: "hostAppName", value: hostAppName)
            urlComponents.appendQueryItem(name: "userEmailAddress", value: userEmailAddress)
            urlComponents.appendQueryItem(name: "finalUrl", value: finalUrl)
            urlComponents.appendQueryItem(name: "variant", value: variant)
            urlComponents.appendQueryItem(name: "hostApiKey", value: hostApiKey) 
            return urlComponents.url!
        }
    }
}

extension URLComponents {
    /// Appends query item to components. If no query items present, creates new list. If value is nil, does nothing.
    mutating func appendQueryItem(name: String, value: String?) {
        guard let value = value else { return }
        if queryItems == nil { queryItems = [.init(name: name, value: value)] }
        else { queryItems!.append(.init(name: name, value: value)) }
    }
}

class RampApi {
    let host: String = RampConfig.host
    let userAddress:String
    let swapAsset:String
    let swapAmount:String
    init(userAddress:String, swapAsset:String, swapAmount:String) {
        self.userAddress = userAddress
        self.swapAsset = swapAsset
        self.swapAmount = swapAmount
    }
    
    func url() -> URL {
        var configuration = Ramp.Configuration(url: host) 
        configuration.swapAsset = swapAsset
        configuration.userAddress = userAddress
        configuration.finalUrl = RampConfig.finalUrl
        configuration.hostApiKey = RampConfig.apiKey
        configuration.hostLogoUrl = RampConfig.logoUrl
        configuration.hostAppName = RampConfig.appName
        configuration.variant = "mobile"
        let rampWidgetUrl = configuration.composeUrl()
        return rampWidgetUrl
    }
}
