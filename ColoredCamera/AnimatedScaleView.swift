
import SwiftUI
import Foundation

struct AnimatedScaleView: View {
  @State var isScaledDown = false
  var body: some View {
    VStack {
      Spacer()
      RoundedRectangle(cornerRadius: 24)
        .frame(
          width: isScaledDown ? 100 : 200,
          height: isScaledDown ? 200 : 400
        )
        .animation(.easeInOut, value: isScaledDown)

      Spacer()
      Button {
        someFunction()
      } label: {
        Circle().frame(width: 80)
      }

    }
  }
  
  func someFunction() {
    isScaledDown = true
    DispatchQueue.global().async {
      sleep(2)
      DispatchQueue.main.async {
        isScaledDown = false
      }
    }
  }
}

#Preview {
  AnimatedScaleView()
}
