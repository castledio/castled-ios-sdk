Pod::Spec.new do |spec|

  spec.name         = "Castled-iOS-SDK"
  spec.version      =  ENV['LIB_VERSION'] || '1.0.0' #fallback to major version
  spec.summary      = "iOS SDK for Castled Push and InApp support"

  spec.description  = <<-DESC
  Castled SDK library providing support for push and in app notifications and event handling.
                   DESC

  
  spec.homepage     = "https://github.com/castledio/castled-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Castled Data" => "https://castled.io" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"

  spec.source        = { :git => "https://github.com/castledio/castled-notifications-ios.git", :tag => "#{spec.version}" }
  # spec.source_files  = "Castled/**/*.{h,m,swift}"
  spec.source_files = 'Sources/Castled/**/*.{h,m,swift}'
  spec.resource_bundles = {
    spec.name => ['Sources/Castled/**/*.{xcassets,storyboard,xib}']
  }

end
