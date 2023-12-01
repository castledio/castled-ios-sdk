Pod::Spec.new do |spec|
  spec.name         = "Castled"
  spec.version      = '2.5.3'
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
  spec.ios.dependency 'RealmSwift', '~>10.43.0'

  spec.source = { :git => "https://github.com/castledio/castled-ios-sdk.git", :tag => "#{spec.version}" }
  # spec.source_files  = "Castled/**/*.{h,m,swift}"

  spec.readme = 'README.md'

  # Source files
  spec.source_files = 'Sources/Castled/**/*.{h,m,swift}'

  # Resource bundles
  spec.resource_bundles = {
    "Castled" => ['Sources/Castled/**/*.{xcassets,storyboard,xib,js}']
  }

  # Preserve folder structure
  spec.preserve_paths = 'Sources/Castled/**/*'

  # Subspecs for different components
  spec.subspec 'BackgroundProcessing' do |background_processing|
    background_processing.source_files = 'Sources/Castled/BackgroundProcessing/**/*.swift'
  end

  spec.subspec 'Constants' do |constants|
    constants.source_files = 'Sources/Castled/Constants/**/*.swift'
  end

  spec.subspec 'Helpers' do |helpers|
    helpers.source_files = 'Sources/Castled/Helpers/**/*.swift'
  end

  spec.subspec 'Networking' do |networking|
    networking.source_files = 'Sources/Castled/Networking/**/*.swift'
  end

  spec.subspec 'Store' do |store|
    store.source_files = 'Sources/Castled/Store/**/*.swift'
  end

  spec.subspec 'Swizzling' do |swizzling|
    swizzling.source_files = 'Sources/Castled/Swizzling/**/*.swift'
  end

  spec.subspec 'Tracking' do |swizzling|
    swizzling.source_files = 'Sources/Castled/Tracking/**/*.swift'
  end

  spec.subspec 'InApps' do |in_apps|
    in_apps.source_files = 'Sources/Castled/InApps/**/*.swift'
    # Additional configurations specific to InApps

    in_apps.subspec 'Helpers' do |in_apps_helpers|
      in_apps_helpers.source_files = 'Sources/Castled/InApps/Helpers/**/*.swift'
      # Additional configurations specific to InApps Helpers
    end

    in_apps.subspec 'Views' do |in_apps_views|
      in_apps_views.source_files = 'Sources/Castled/InApps/Views/**/*.swift'
      in_apps_views.resource_bundle = { 'ViewsBundle' => 'Sources/Castled/InApps/Views/Resources/**/*.{xcassets,storyboard,xib,js}' }

      in_apps_views.subspec 'Resources' do |views_resources|
        views_resources.source_files = 'Sources/Castled/InApps/Views/Resources/**/*.swift'
        views_resources.resource_bundle = { 'ViewsResourcesBundle' => 'Sources/Castled/InApps/Views/Resources/**/*.{xcassets,storyboard,xib,js}' }
      end

      in_apps_views.subspec 'Templates' do |views_templates|
        views_templates.source_files = 'Sources/Castled/InApps/Views/Templates/**/*.swift'
      end
    end
  end

  # Subspecs for different components
  spec.subspec 'Inbox' do |inbox|
    inbox.source_files = 'Sources/Castled/Inbox/**/*.swift'
    # Additional configurations specific to Inbox

    inbox.subspec 'Helpers' do |inbox_helpers|
      inbox_helpers.source_files = 'Sources/Castled/Inbox/Helpers/**/*.swift'
      # Additional configurations specific to Inbox Helpers
    end

    inbox.subspec 'Model' do |inbox_model|
      inbox_model.source_files = 'Sources/Castled/Inbox/Model/**/*.swift'
      # Additional configurations specific to Inbox Model
    end

    inbox.subspec 'ViewModel' do |inbox_view_model|
      inbox_view_model.source_files = 'Sources/Castled/Inbox/ViewModel/**/*.swift'
      # Additional configurations specific to Inbox ViewModel
    end

    inbox.subspec 'Views' do |inbox_views|
      inbox_views.source_files = 'Sources/Castled/Inbox/Views/**/*.swift'

      inbox_views.resource_bundle = { 'InboxViewsBundle' => 'Sources/Castled/Inbox/Views/Resources/**/*.{xcassets,storyboard,xib,js}' }
      # Additional configurations specific to Inbox Views

      inbox_views.subspec 'Resources' do |views_resources|
        views_resources.source_files = 'Sources/Castled/Inbox/Views/Resources/**/*.swift'
        inbox_views.resource_bundle = { 'InboxViewsResourcesBundle' => 'Sources/Castled/Inbox/Views/Resources/**/*.{xcassets,storyboard,xib,js}' }
        # Additional configurations specific to Inbox Views Resources
      end
    end
  end

  # Add more subspecs or configurations for other components as needed
end
