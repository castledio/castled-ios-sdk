//
//  CastledDemoSwiftUIApp.swift
//  CastledDemoSwiftUI
//
//  Created by antony on 04/07/2024.
//

import SwiftUI

@main
struct CastledDemoSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {}

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
