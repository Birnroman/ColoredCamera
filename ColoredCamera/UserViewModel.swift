import Foundation
import SwiftUI
import RevenueCat

class UserViewModel: ObservableObject {
  
  // Должно быть false
  @Published var isSubscriptionActive: Bool = false
  private var updatesListenerTask: Task<Void, Never>? // Для хранения задачи слушателя
  init() {
    
    checkSubscription()
    setupUpdatesListener()
  }
  
  deinit {
      updatesListenerTask?.cancel() // Важно: отменяем при деинициализации
  }
  
  private func setupUpdatesListener() {
      updatesListenerTask = Task { [weak self] in
          // Подписываемся на поток обновлений CustomerInfo
          for await customerInfo in Purchases.shared.customerInfoStream {
              self?.updateSubscriptionStatus(customerInfo: customerInfo)
          }
      }
  }
  
  private func updateSubscriptionStatus(customerInfo: CustomerInfo) {
      DispatchQueue.main.async { [weak self] in
          // Обновляем статус подписки на главном потоке
          self?.isSubscriptionActive = customerInfo.entitlements.all["pro"]?.isActive == true
      }
  }
  
  func checkSubscription() {
      Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
          guard let self = self, let customerInfo = customerInfo else { return }
          self.updateSubscriptionStatus(customerInfo: customerInfo)
      }
  }
  
  
}
