Pod::Spec.new do |spec|

  spec.name         = "CastledNotificationService"
  spec.version      = '2.3.6'
  spec.summary      = "A Notification Service extension for customizing push notifications in your app."
  spec.description  = <<-DESC
    CastledNotificationService is a framework that provides the functionality to modify and customize
    push notifications before they are displayed to the user. With this extension, you can process incoming
    notifications, attach media content, or perform additional actions based on the received payload.
    
    This extension integrates seamlessly with your app's push notification flow, allowing you to enhance the
    visual and interactive experience of your notifications.
                   DESC

  spec.homepage     = "https://github.com/castledio/castled-ios-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Castled Data" => "https://castled.io" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"

  spec.weak_frameworks  = 'UserNotifications'

  spec.source        = { :git => "https://github.com/castledio/castled-ios-sdk.git", :tag => "#{spec.version}" }
  # spec.source_files  = "Castled/**/*.{h,m,swift}"
  spec.source_files = 'Sources/CastledNotificationService/**/*.{h,m,swift}'

end




