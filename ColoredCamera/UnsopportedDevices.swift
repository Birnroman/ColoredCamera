import SwiftUI

struct UnsopportedDevices: View {
    var body: some View {
        ZStack {
            Color(hex: 0x34313C).ignoresSafeArea()
            Text("Unfortunately, we no longer support the iPad version. You can use the iPhone app instead.")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    UnsopportedDevices()
}
