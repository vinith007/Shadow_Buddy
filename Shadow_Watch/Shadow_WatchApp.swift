//
//  Shadow_WatchApp.swift
//  Shadow_Watch
//
//  Created by Vinith Bandoju on 2/7/24.
//

import SwiftUI
import FirebaseCore


@main
struct Shadow_WatchApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
