
import SwiftUI

struct ReviewCaptureView: View {
    var body: some View {
        ZStack {
            Image("photocover")
                .resizable()
                .scaledToFill()
                .overlay {
                    Rectangle()
                        .fill(Gradient(colors: [
                            .black.opacity(0),
                            .black.opacity(0),
                            .black.opacity(0),
                            .black]))
                }
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                }
                .padding()
                Spacer()
                Button {
                    
                } label: {
                    Text("Save to gallery")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(Color(hex: 0xEC197F), in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ReviewCaptureView()
}
