<p align="center">
  <a href="https://castled.io/#gh-light-mode-only">
    <img src="https://cdn.castled.io/logo/castled_logo_light_mode.png" width="318px" alt="Castled logo" />
  </a>
  <a href="https://castled.io/#gh-dark-mode-only">
    <img src="https://cdn.castled.io/logo/castled_logo_dark_mode.png" width="318px" alt="Castled logo" />
    <p align="center">Customer Engagement Platform for the Modern Data Stack</p>
  </a>
</p>

# Castled Swift SDK  
[![Version](https://img.shields.io/cocoapods/v/Castled.svg?style=flat)](https://cocoapods.org/pods/Castled)
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0+-blue.svg)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)](https://cocoapods.org/pods/Castled)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/cocoapods/l/Castled.svg?style=flat)](https://github.com/castledio/castled-ios-sdk/blob/main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/Castled.svg?style=flat)](https://docs.castled.io/developer-resources/sdk-integration/ios/installation)

## ⭐ Introduction

Castled iOS SDK provides integration capabilities for mobile applications running on iOS devices with the Castled Customer Engagement Platform. This SDK facilitates:
- Receiving push notifications.
- Displaying in-app messages and app inbox notifications.
- Updating user profiles.
- Collecting user events.

The following steps will guide iOS app developers on how to seamlessly integrate the SDK into their mobile applications.

## Requirements

- iOS 13.0 or later
- Xcode 14.0 or later

## 🎢 Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Castled into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Castled'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Castled as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/castledio/castled-ios-sdk", .upToNextMajor(from: "2.5.1"))
]
```
## 🎁 Examples

Explore our [examples project](https://github.com/castledio/castled-ios-sdk/tree/main/Example) which showcases multiple features' integrations.


## 📚 Documentation

For a comprehensive guide on SDK integration, please check out our [documentation](https://docs.castled.io/developer-resources/sdk-integration/ios/initialization "Castled Developer Documentation").
