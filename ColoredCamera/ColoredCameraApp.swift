import SwiftUI
import RevenueCat

@main
struct ColoredCameraApp: App {
    
    @StateObject var userViewModel = UserViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_twjyZgTgzpVATttrLnLmnaXgguu")
    }
    
    var body: some Scene {
        WindowGroup {
            if UIDevice.current.userInterfaceIdiom == .pad {
                UnsopportedDevices()
            } else {
                Group {
                    if hasCompletedOnboarding {
                        ColorPickerExp()
                    } else {
                        Onboarding {
                            hasCompletedOnboarding = true
                        }
                    }
                }
                .preferredColorScheme(.light)
                .environmentObject(userViewModel)
            }
        }
    }
}
