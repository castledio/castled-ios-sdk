Pod::Spec.new do |spec|

  spec.name         = "CastledInbox"
  spec.version      = '4.0.4'
  spec.summary      = "iOS SDK for Castled Inbox support"
  spec.description  = <<-DESC
  Castled SDK library providing support for push and in app notifications and event handling.
                   DESC

  
  spec.homepage     = "https://github.com/castledio/castled-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Castled Data" => "https://castled.io" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"
  spec.ios.dependency 'Castled', '>= 4.0.3'
  spec.ios.dependency 'SDWebImage', '~> 5.11'

  spec.ios.dependency 'RealmSwift', '~>10.49.1'

  spec.source        = { :git => "https://github.com/castledio/castled-ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files = 'Sources/CastledInbox/**/*.{h,m,swift}', 'Sources/CastledInboxObjC/**/*.{h,m,swift}'
  spec.resource_bundles = {
    "Castled" => ['Sources/CastledInbox/**/*.{xcassets,storyboard,xib,js}']
  }
 spec.readme = 'README.md'
 spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }


end
