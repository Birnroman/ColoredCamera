//
//  PaywallView.swift
//  ColoredCamera
//
//  Created by Rum Gersy on 02.02.2025.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct PaywallView: View {
  
  @Binding var isPresented: Bool
  @EnvironmentObject var userViewModel: UserViewModel

  
  var body: some View {
    ZStack {
      Color(UIColor(cgColor: #colorLiteral(red: 0.9960784314, green: 0.9215686275, blue: 1, alpha: 1))).ignoresSafeArea()
      
      ScrollView {
        VStack {
//          Spacer()
          Text("Get PRO").font(.headline)
            .foregroundStyle(Color(UIColor(cgColor: #colorLiteral(red: 0.831372549, green: 0.2, blue: 0.8588235294, alpha: 1))))

          Text("Now you can take selfies anywhere.")
            .font(.largeTitle).fontWeight(.semibold)
            .multilineTextAlignment(.center)
          VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 12) {
              Circle().frame(width: 8, height: 8)
                .foregroundStyle(Color(UIColor(cgColor: #colorLiteral(red: 0.831372549, green: 0.2, blue: 0.8588235294, alpha: 1))))
                .padding(.top, 8)
              Text("Unlimited number of colors for background")
            }
            HStack(alignment: .top, spacing: 12) {
              Circle().frame(width: 8, height: 8)
                .foregroundStyle(Color(UIColor(cgColor: #colorLiteral(red: 0.831372549, green: 0.2, blue: 0.8588235294, alpha: 1))))
                .padding(.top, 8)
              Text("Unlimited shooting and saving to the gallery")
            }
            HStack(alignment: .top, spacing: 12) {
              Circle().frame(width: 8, height: 8)
                .foregroundStyle(Color(UIColor(cgColor: #colorLiteral(red: 0.831372549, green: 0.2, blue: 0.8588235294, alpha: 1))))
                .padding(.top, 8)
              Text("Ability to shoot both stills and video")
            }

          }
          .padding()
          Spacer()
        }
      }
      

      
      .padding()
      .originalTemplatePaywallFooter(
        condensed: true,
        purchaseCompleted: { customerInfo in
          isPresented = false
        }
      )


    }
  }
}



#Preview {
  PaywallView(isPresented: .constant(false))
}
