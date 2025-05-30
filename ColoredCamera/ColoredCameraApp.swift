//
//  ColoredCameraApp.swift
//  ColoredCamera
//
//  Created by Rum Gersy on 27.01.2025.
//

import SwiftUI
import RevenueCat

@main
struct ColoredCameraApp: App {
  
  @StateObject var userViewModel = UserViewModel()

  
  init() {
    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: "appl_twjyZgTgzpVATttrLnLmnaXgguu")
  }
  
  var body: some Scene {
    WindowGroup {
      ColorPickerExp()
        .preferredColorScheme(.light)
        .environmentObject(userViewModel)
      

    }
  }
}
