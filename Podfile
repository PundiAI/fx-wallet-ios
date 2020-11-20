source 'https://github.com/CocoaPods/Specs.git'
xcodeproj 'Pundix.xcodeproj'

platform :ios, '11.0'
 
inhibit_all_warnings!
use_frameworks!


target 'XWallet' do
    pod 'HapticGenerator'
    pod 'Presentr'
    pod 'WKKit', :path => './FXCore/Core/WKKit'
    pod 'WKKit/Push', :path => './FXCore/Core/WKKit'
    pod 'WKKit/Contacts', :path => './FXCore/Core/WKKit' 
    pod 'WKKit/Firebase', :path => './FXCore/Core/WKKit'
    pod 'WKKit/Localization', :path => './FXCore/Core/WKKit'

    pod 'XChains', :path => './FXCore/Core/XChains'
    pod 'XWebKit', :path => './FXCore/Core/XWebKit'
    pod 'FunctionX', :path => './FXCore/Core/FunctionX'

    pod 'Kanna', '~> 5.0.0'
    pod 'DateToolsSwift', '= 5.0.0'
    pod 'SwipeCellKit'
    pod 'Hero', '= 1.5.0'
    pod 'XLPagerTabStrip' 
    pod 'RxViewController'
    pod 'UINavigationControllerWithCompletionBlock'
    
    ## 滚动截屏工具
    pod "SwViewCapture"
    
    pod 'KeychainAccess'
    pod 'AloeStackView', '~> 1.2.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
