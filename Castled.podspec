Pod::Spec.new do |spec|

  spec.name         = "Castled"
  spec.version      =  ENV['LIB_VERSION'] || '1.0.2' #fallback to major version
  spec.summary      = "IOS sdk for Castled Notifications"

  spec.description  = <<-DESC
  IOS sdk for Castled Notifications
                   DESC

  spec.homepage     = "https://github.com/castledio/castled-notifications-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "antonyjoemathew" => "antonyjoemathew@gmail.com" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"

  spec.source        = { :git => "https://github.com/castledio/castled-notifications-ios.git", :tag => "#{spec.version}" }
  # spec.source_files  = "Castled/**/*.{h,m,swift}"
  spec.source_files = 'Sources/Castled/**/*.{h,m,swift}'
  spec.resource_bundles = {
    spec.name => ['Sources/Castled/**/*.{xcassets,storyboard,xib}']
  }

end
