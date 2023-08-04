Pod::Spec.new do |spec|

  spec.name         = "Castled"
  spec.version      =  ENV['LIB_VERSION'] || '2.2.6' #fallback to major version
  spec.summary      = "iOS SDK for Castled Push and InApp support"

  spec.description  = <<-DESC
  Castled SDK library providing support for push and in app notifications and event handling.
                   DESC

  
  spec.homepage     = "https://github.com/castledio/castled-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Castled Data" => "https://castled.io" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"
  spec.ios.dependency 'SDWebImage', '~> 5.11'

  spec.source        = { :git => "https://github.com/castledio/castled-ios-sdk.git", :tag => "#{spec.version}" }
  # spec.source_files  = "Castled/**/*.{h,m,swift}"
  spec.source_files = 'Sources/Castled/**/*.{h,m,swift}'
  spec.resource_bundles = {
    "Castled" => ['Sources/Castled/**/*.{xcassets,storyboard,xib,js}']
  }

end
