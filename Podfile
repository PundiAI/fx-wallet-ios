source 'https://github.com/CocoaPods/Specs.git'
xcodeproj 'Pundix.xcodeproj'

platform :ios, '11.0'
 
inhibit_all_warnings!
use_frameworks!


target 'fxWallet' do
    pod 'HapticGenerator'
    pod 'WKKit', :path => './FXCore/Core/WKKit'
    pod 'WKKit/Push', :path => './FXCore/Core/WKKit'

    pod 'XChains', :path => './FXCore/Core/XChains'
    pod 'XWebKit', :path => './FXCore/Core/XWebKit'
    pod 'FunctionX', :path => './FXCore/Core/FunctionX'

    pod 'Kanna', '~> 5.0.0'
    pod 'DateToolsSwift', '= 5.0.0'
    pod 'SwipeCellKit' 
    pod 'XLPagerTabStrip' 
    pod 'RxViewController' 
    pod 'AloeStackView', '~> 1.2.0'
    pod 'ReachabilitySwift' 
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = "arm64"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
