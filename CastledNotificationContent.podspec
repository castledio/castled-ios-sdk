Pod::Spec.new do |spec|

  spec.name         = "CastledNotificationContent"
  spec.version      =  ENV['LIB_VERSION'] || '2.2.0' #fallback to major version
  spec.summary      = "A Notification Content Extension for displaying custom content in iOS push notifications."

  spec.description  = <<-DESC
The CastledNotificationContent framework provides a Notification Content Extension that allows you to create custom interfaces for displaying rich content in push notifications on iOS.
                   DESC

  spec.homepage     = "https://github.com/castledio/castled-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Castled Data" => "https://castled.io" }
  
  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"
  spec.weak_frameworks = 'UserNotifications', 'UIKit'
  spec.dependency "SDWebImage", "~> 5.11"

  spec.source        = { :git => "https://github.com/castledio/castled-ios-sdk.git", :tag => "#{spec.version}" }
  # spec.source_files  = "Castled/**/*.{h,m,swift}"
  spec.source_files = 'Sources/CastledNotificationContent/**/*.{h,m,swift}'
 spec.resource_bundles = {
    "Castled" => ['Sources/CastledNotificationContent/**/*.{xcassets,storyboard,xib}']
  }

end


