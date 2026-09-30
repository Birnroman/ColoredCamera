
import AVKit
import SwiftUI

struct ReviewCaptureView: View {
    let media: CameraModel.CapturedMedia
    let onSave: () -> Void
    let onDiscard: () -> Void
    
    var body: some View {
        ZStack {
            // 1. Превью с ограничением геометрии и обрезкой лишнего контента
            GeometryReader { proxy in
                preview
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .overlay {
                Rectangle()
                    .fill(Gradient(colors: [
                        .black.opacity(0),
                        .black.opacity(0),
                        .black.opacity(0),
                        .black
                    ]))
            }
            
            // 2. Элементы управления
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                        .onTapGesture {
                            onDiscard()
                        }
                }
                .padding()
                .padding(.top, 24)
                
                Spacer()
                
                Button {
                    onSave()
                } label: {
                    Text("Save to gallery")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .foregroundStyle(.white)
                        .background(Color(hex: 0xEC197F), in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain) // Важно: buttonStyle лучше ставить на сам Button
                .padding(.horizontal)
            }
            .padding()
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var preview: some View {
        switch media.kind {
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        case .video(let url):
            VideoPlayer(player: AVPlayer(url: url))
                .scaledToFill()
        }
    }
}
