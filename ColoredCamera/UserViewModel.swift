import Foundation
import SwiftUI
import RevenueCat

class UserViewModel: ObservableObject {
  
  // Должно быть false
  @Published var isSubscriptionActive: Bool = false
  
  init() {
    
    checkSubscription()
    
  }
  
  func checkSubscription() {
    Purchases.shared.getCustomerInfo { (customerInfo, error) in
      
      if customerInfo?.entitlements.all["pro"]?.isActive == true {
        
        self.isSubscriptionActive = true
        
      }
    }
  }
  
}
