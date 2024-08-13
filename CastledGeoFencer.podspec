Pod::Spec.new do |spec|

  spec.name         = "CastledGeoFencer"
  spec.version      = '4.3.5'
  spec.summary      = "iOS SDK for Castled Geofencing support"
  spec.description  = <<-DESC
  Castled SDK library providing support for push and in app notifications and event handling.
                   DESC

  
  spec.homepage     = "https://github.com/castledio/castled-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Castled Data" => "https://castled.io" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"
  spec.ios.dependency 'Castled', '~> 4.3.5'

 
  spec.source        = { :git => "https://github.com/castledio/castled-ios-sdk.git", :tag => "#{spec.version}" }
  spec.source_files = 'Sources/CastledGeoFencer/**/*.{h,m,swift}', 'Sources/CastledGeoFencerObjC/**/*.{h,m,swift}'
  spec.resource_bundles = {
    "CastledGeoFencer" => ['Sources/CastledGeoFencer/**/*.{xcassets,storyboard,xib}']
  }
 spec.readme = 'README.md'
 spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }


end
